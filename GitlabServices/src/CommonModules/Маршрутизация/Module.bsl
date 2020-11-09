#Region Internal

// TODO подумать об упрощении
// TODO подумать о возвращении отправки по доступным маршрутам, если файл не имеет описания в json

// Возвращает коллекцию файлов к отправке с адресами доставки.
// 
// Параметры:
// 	ОтправляемыеДанные - ТаблицаЗначений - описание:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * URLFilePath - String - relative URL path to the file (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
// 	ДанныеЗапроса - Соответствие - десериализованное из JSON тело запроса;
// Returns:
// 	Массив Из Структура:
// * FileName - String - file name; 
// * BinaryData - BinaryData - тело файла;
// * АдресаДоставки - Массив Из Строка - адреса доставки;
// * ErrorInfo - Строка - текст ошибки при формировании файла к отправке;
//
Функция РаспределитьОтправляемыеДанныеПоМаршрутам( Знач ОтправляемыеДанные, Знач ДанныеЗапроса ) Экспорт
	
	Var МаршрутыОтправкиФайлов;
	Var ОтправляемыйФайл;
	Var CommitSHA;
	Var Результат;
	
	ROUTING_SETTINGS_MISSING_MESSAGE = НСтр( "ru = '%1: отсутствуют настройки маршрутизации.';
										|en = '%1: there are no routing settings.'" );
										
	DELIVERY_ROUTE_MISSING_MESSAGE = НСтр( "ru = '%1: не задан маршрут доставки файла.';
										|en = '%1: file delivery route not specified.'" );
	
	МаршрутыОтправкиФайлов = МаршрутыОтправкиФайловПоДаннымЗапроса( ДанныеЗапроса );
	
	Результат = Новый Массив();
	
	Для Каждого ОписаниеФайла Из ОтправляемыеДанные Цикл
		
		Если ( ЭтоФайлНастроек(ОписаниеФайла) ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		ОтправляемыйФайл = ОтправляемыйФайл();
		
		ЗаполнитьЗначенияСвойств( ОтправляемыйФайл, ОписаниеФайла );
		
		Если ( НЕ ПустаяСтрока(ОтправляемыйФайл.ErrorInfo) ) Тогда
			
			Результат.Добавить(ОтправляемыйФайл);
			
			Продолжить;
			
		КонецЕсли;
			
		CommitSHA = МаршрутыОтправкиФайлов.Получить( ОписаниеФайла.CommitSHA );
	
		Если ( CommitSHA = Неопределено ) Тогда
			
			ОтправляемыйФайл.ErrorInfo = СтрШаблон( ROUTING_SETTINGS_MISSING_MESSAGE, ОписаниеФайла.CommitSHA );

		Иначе

			ОтправляемыйФайл.АдресаДоставки = CommitSHA.Получить( ОписаниеФайла.URLFilePath );
			
			Если ( ОтправляемыйФайл.АдресаДоставки = Неопределено ) Тогда

				ОтправляемыйФайл.ErrorInfo = СтрШаблон( DELIVERY_ROUTE_MISSING_MESSAGE, ОписаниеФайла.CommitSHA );
				
			КонецЕсли;

		КонецЕсли;
		
		Результат.Добавить( ОтправляемыйФайл );
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// AddRoutingFilesDescription adds a description of files with routing settings for download.
// 
// Parameters:
// 	RemoteFiles - ValueTable - description:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * URLFilePath - String - relative URL path to the file (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
// 	Commits - Map - deserialized commits from the GitLab request;
//	ProjectId - String - project id from the GitLab request;
//
Procedure AddRoutingFilesDescription( RemoteFiles, Val Commits, Val ProjectId ) Export
	
	Var FilePath;
	Var CommitSHA;
	Var RAWFilePath;
	Var NewDescription;
	
	If ( Commits = Undefined ) Then
		
		Return;
		
	EndIf;

	FilePath = ServicesSettings.CurrentSettings().RoutingFileName;
	
	For Each Commit In Commits Do

		NewDescription = RemoteFiles.Add();
		CommitSHA = Commit.Get( "id" );
		RAWFilePath = GitLab.RAWFilePath( ProjectId, FilePath, CommitSHA );
		NewDescription.RAWFilePath = RAWFilePath;
		NewDescription.URLFilePath = FilePath;
		NewDescription.Action = "";
		NewDescription.Date = Commit.Get( "timestamp" );
		NewDescription.CommitSHA = CommitSHA;
	
	EndDo;

EndProcedure

// Добавляет десериализованные из JSON настройки маршрутизации файлов в данные запроса.
// 
// Параметры:
// 	ДанныеЗапроса - Соответствие - десериализованное из JSON тело запроса;
// 	ДанныеДляОтправки - ТаблицаЗначений - описание:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * URLFilePath - String - relative URL path to the file (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
Процедура ДополнитьЗапросНастройкамиМаршрутизации( ДанныеЗапроса, Знач ДанныеДляОтправки ) Экспорт
	
	Var URLFilePath;
	Var Commits;
	Var ПараметрыОтбора;
	Var НайденныеНастройки;
	Var НастройкиМаршрутизации;

	URLFilePath = ServicesSettings.CurrentSettings().RoutingFileName;	
	Commits = ДанныеЗапроса.Получить( "commits" );
	
	Для каждого Commit Из Commits Цикл
		
		ПараметрыОтбора = Новый Структура();
		ПараметрыОтбора.Вставить( "CommitSHA", Commit.Получить( "id" ) );
		ПараметрыОтбора.Вставить( "URLFilePath", URLFilePath );
		ПараметрыОтбора.Вставить( "Action", "" );
		ПараметрыОтбора.Вставить( "ErrorInfo", "" );
		
		НайденныеНастройки = ДанныеДляОтправки.НайтиСтроки( ПараметрыОтбора );
		
		Если ( НЕ ЗначениеЗаполнено(НайденныеНастройки) ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Поток = НайденныеНастройки[0].BinaryData.ОткрытьПотокДляЧтения();
		НастройкиМаршрутизации = HTTPConnector.JsonВОбъект( Поток );
		CommonUseServerCall.AppendCollectionFromStream( НастройкиМаршрутизации, "json", Поток );
		
		Commit.Вставить( "settings", НастройкиМаршрутизации );
		
	КонецЦикла;
	
КонецПроцедуры
 
#EndRegion

#Region Private

// Возвращает описание отправляемого файла.
// 
// Returns:
// 	Структура - Описание:
// * FileName - String - file name; 
// * BinaryData - BinaryData - тело файла;
// * АдресаДоставки - Массив Из Строка - адреса доставки;
// * ErrorInfo - Строка - текст ошибки при формировании файла к отправке;
//
Функция ОтправляемыйФайл()
	
	Var Результат;
	
	Результат = Новый Структура();
	Результат.Вставить( "FileName", "" );
	Результат.Вставить( "АдресаДоставки", Неопределено );
	Результат.Вставить( "BinaryData", Неопределено );
	Результат.Вставить( "ErrorInfo", "" );
	
	Возврат Результат;
	
КонецФункции

Функция ЭтоФайлНастроек( Знач ОписаниеФайла )
	
	Возврат ПустаяСтрока( ОписаниеФайла.Action );
	
КонецФункции

// Формирует перечень доступных получателей файлов с адресами веб-сервисов по данным настроек маршрутизации.
// 
// Параметры:
// 	НастройкиМаршрутизации - Соответствие - настройки маршрутизации;
// 	  
// Returns:
// 	Соответствие - доступные сервисы доставки:
//	* Ключ - Строка - имя сервиса;
//	* Значение - Строка - адрес сервиса;
//
Функция ДоступныеСервисыДоставки( Знач НастройкиМаршрутизации )
	
	Var Результат;
	Var СервисыДоставки;
	Var ИмяСервиса;
	Var СервисВключен;
	Var Адрес;
	
	Результат = Новый Соответствие();
	
	СервисыДоставки = НастройкиМаршрутизации.Получить( "ws" );
	
	Если ( СервисыДоставки = Неопределено ) Тогда
		
		Возврат Результат;
		
	КонецЕсли;
	
	Для каждого Сервис Из СервисыДоставки Цикл
		
		ИмяСервиса = Сервис.Получить( "name" );
		
		Если ( ИмяСервиса = Неопределено ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		СервисВключен = Сервис.Получить( "enabled" );
		
		Если ( СервисВключен = Неопределено ИЛИ НЕ СервисВключен ) Тогда
			
			Продолжить;
			
		КонецЕсли;
			
		Адрес = Сервис.Получить( "address" );
		
		Если ( Адрес = Неопределено ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Результат.Вставить( ИмяСервиса, Адрес );

	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция АдресаДоставкиПоПравиламИсключения( Знач СервисыДоставки, Знач ИсключаемыеСервисы )
	
	Var Результат;
	
	Результат = Новый Массив();
	
	Для Каждого Элемент Из СервисыДоставки Цикл
		
		Если ( ИсключаемыеСервисы = Неопределено ИЛИ ИсключаемыеСервисы.Найти(Элемент.Ключ) = Неопределено ) Тогда
	
			Результат.Добавить( Элемент.Значение );
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Возвращает адреса доставки файлов по данным настройки маршрутизации.
// 
// Параметры:
// 	НастройкиМаршрутизации - Соответствие - преобразованные в коллекцию настройки маршрутизации;
// 	
// Returns:
// 	Соответствие - описание:
// 	*Ключ - Строка - полное имя файла;
// 	*Значение - Массив из Строка - перечень адресов доставки файла;
//
Функция АдресаДоставкиФайлов( Знач НастройкиМаршрутизации )
	
	Var СервисыДоставки;
	Var URLFilePath;
	Var ИсключаемыеСервисы;
	Var АдресаДоставки;
	Var Результат;
	
	СервисыДоставки = ДоступныеСервисыДоставки( НастройкиМаршрутизации );
	
	ПравилаДоставки = НастройкиМаршрутизации.Получить( "epf" );
	
	Результат = Новый Соответствие();
	
	Для каждого Правило Из ПравилаДоставки Цикл
		
		URLFilePath = Правило.Получить( "name" );
		
		Если ( URLFilePath = Неопределено ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		ИсключаемыеСервисы = Правило.Получить( "exclude" );
		АдресаДоставки = АдресаДоставкиПоПравиламИсключения( СервисыДоставки, ИсключаемыеСервисы );

		Результат.Вставить( URLFilePath, АдресаДоставки );
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Возвращает адреса доставки файлов из данных запроса согласно пользовательским настройкам маршрутизации
// или настройкам маршрутизации из файла настроек (См. ServicesSettings.RoutingFileName).
// Для пользовательских настроек приоритет выше, чем у настроек из файла. 
// 
// Параметры:
// 	ДанныеЗапроса - Соответствие - десериализованное из JSON тело запроса;
// 	
// Returns:
// 	Соответствие - описание:
// 	*Ключ - Строка - идентификатор commit;
// 	*Значение - Соответствие - описание;
// 	** Ключ - Строка - полное имя файла;
// 	** Значение - Массив из Строка - адреса к сервисам получения файла;
//
Функция МаршрутыОтправкиФайловПоДаннымЗапроса( ДанныеЗапроса )
	
	Var Commits;
	Var НастройкиМаршрутизации;
	Var Результат;
	
	Результат = Новый Соответствие();
	
	Commits = ДанныеЗапроса.Получить( "commits" );
	
	Для каждого Commit Из Commits Цикл
		
		НастройкиМаршрутизации = Commit.Получить( "user_settings" );
		
		Если ( НастройкиМаршрутизации = Неопределено ) Тогда
			
			НастройкиМаршрутизации = Commit.Получить( "settings" );
			
		КонецЕсли;
		
		Если ( НастройкиМаршрутизации = Неопределено ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Результат.Вставить( Commit.Получить( "id" ), АдресаДоставкиФайлов( НастройкиМаршрутизации ) );

	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции 

#EndRegion