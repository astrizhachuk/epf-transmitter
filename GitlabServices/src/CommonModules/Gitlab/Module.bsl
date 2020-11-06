#Region Public

// ConnectionParams returns the connection parameters to the GitLab server.
// 
// Parameters:
// 	URL - String - URL to GitLab server, for example: "http://www.example.org";
//
// Returns:
// Structure - description:
// * URL - String - URL to GitLab server;
// * Token - String - access token to the server from the current settings;
// * Timeout - Number - the connection timeout from the current settings, sec (0 - timeout is not set);
//
Function ConnectionParams( Val URL ) Export
	
	Var CurrentSettings;
	Var Result;
	
	CurrentSettings = ServicesSettings.CurrentSettings();
	
	Result = New Structure();
	Result.Insert( "URL", URL );
	Result.Insert( "Token", CurrentSettings.TokenGitLab );
	Result.Insert( "Timeout", CurrentSettings.TimeoutGitLab );
	
	Return Result;
	
EndFunction

// RemoteFilesEmpty returns an empty remote files collection.
// 
// Returns:
//	ValueTable - description:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * URLFilePath - String - relative URL path to the file (with the filename);
// * BinaryData - BinaryData - file binary data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
Function RemoteFilesEmpty() Export
	
	Var Result;
	
	Result = GitLabCached.RemoteFilesEmpty();
	Result.Clear(); // ValueTable is cached, so we exclude returning a filled values.

	Return Result;
	
EndFunction

// Получает с сервера GitLab файл и формирует его описание.
// 
// Параметры:
// 	ConnectionParams - (См. GitLab.ConnectionParams)
// 	RAWFilePath - Строка - закодированный в URL кодировке относительный путь к получаемому файлу, например,
// 							"/api/v4/projects/1/repository/files/D0%BA%D0%B0%201.epf/raw?ref=ef3529e5486ff";
// 	
// Returns:
// 	Структура - описание:
// * RAWFilePath - Строка - относительный путь к RAW файлу;
// * FileName - Строка - имя файла в кодировке UTF-8;
// * BinaryData - BinaryData - данные файла;
// * ErrorInfo - Строка - текст с описанием ошибки получения файла с сервера;
//
Функция GetRemoteFile( Знач ПараметрыСоединения, Знач RAWFilePath ) Экспорт

	Var Адрес;
	Var Заголовки;
	Var ДополнительныеПараметры;
	Var FileName;
	Var Ответ;
	Var ИнформацияОбОшибке;
	Var ТекстСообщения;
	Var Результат;
	
	Адрес = ПараметрыСоединения.URL + RAWFilePath;
	
	Результат = ОписаниеПолучаемогоФайла();
	Результат.RAWFilePath = RAWFilePath;

	Попытка

		Заголовки = Новый Соответствие();
		Заголовки.Вставить( "PRIVATE-TOKEN", ПараметрыСоединения.Token );
		
		ДополнительныеПараметры = Новый Структура();
		ДополнительныеПараметры.Вставить( "Заголовки", Заголовки );
		ДополнительныеПараметры.Вставить( "Таймаут", ПараметрыСоединения.Timeout );
		
		Ответ = HTTPConnector.Get( Адрес, Неопределено, ДополнительныеПараметры );

		Если ( НЕ HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда
			
			ВызватьИсключение HTTPStatusCodesClientServerCached.FindIdByCode( Ответ.КодСостояния );
		
		КонецЕсли;
		
		FileName = Ответ.Заголовки.Получить( "X-Gitlab-File-Name" );
		
		Если ( FileName = Неопределено ) Тогда
			
			ВызватьИсключение НСтр("ru = 'Файл не найден.';en = 'File not found.'");
			
		КонецЕсли;

		Если ( НЕ ЗначениеЗаполнено(Ответ.Тело) ) Тогда
			
			ВызватьИсключение НСтр("ru = 'Пустой файл.';en = 'File is empty.'");
			
		КонецЕсли;

		Результат.FileName = FileName;
		Результат.BinaryData = Ответ.Тело;
		
	Исключение
	
		ТекстСообщения = НСтр( "ru = 'Ошибка получения файла: %1';en = 'Error getting file: %1'" );
		ИнформацияОбОшибке = Адрес + Символы.ПС + ОбработкаОшибок.ПодробноеПредставлениеОшибки( ИнформацияОбОшибке() );
		Результат.ErrorInfo = СтрШаблон( ТекстСообщения, ИнформацияОбОшибке );
		
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

// Получает с сервера GitLab файлы и формирует их описание.
// 
// Параметры:
// 	ConnectionParams - (См. GitLab.ConnectionParams)
// 	ПутиКФайлам - Массив из Строка - массив закодированных в URL кодировке относительных путей к получаемым файлам,
//					например, "/api/v4/projects/1/repository/files/D0%BA%D0%B0%201.epf/raw?ref=ef3529e5486ff";
// 	
// Returns:
// 	Массив из Структура:
// * RAWFilePath - Строка - относительный путь к RAW файлу;
// * FileName - Строка - имя файла в кодировке UTF-8;
// * BinaryData - BinaryData - данные файла;
// * ErrorInfo - Строка - текст с описанием ошибки получения файла с сервера;
// 
Функция GetRemoteFiles( Знач ПараметрыСоединения, Знач ПутиКФайлам ) Экспорт
	
	Var Результат;

	Результат = Новый Массив;
	
	Для Каждого RAWFilePath Из ПутиКФайлам Цикл
		
		Результат.Добавить( GetRemoteFile(ПараметрыСоединения, RAWFilePath) );
		
	КонецЦикла;
	
	Возврат Результат;

КонецФункции

// Возвращает описание файлов и сами файлы, которые необходимо распределить по информационным базам получателям.
// 
// Параметры:
// 	ОбработчикСобытия - СправочникСсылка.ОбработчикиСобытий - ссылка на элемент справочника с обработчиками событий;
// 	ДанныеЗапроса - Соответствие - десериализованное из JSON тело запроса;
//
// Returns:
// 	ТаблицаЗначений - описание:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * URLFilePath - String - relative URL path to the file (with the filename);
// * BinaryData - BinaryData - file binary data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
Функция ПолучитьФайлыКОтправкеПоДаннымЗапроса( Знач ОбработчикСобытия, ДанныеЗапроса ) Экспорт
	
	Var ПараметрыЛогирования;
	Var ПараметрыПроекта;
	Var ПараметрыСоединения;
	Var Результат;
	
	EVENT_MESSAGE_BEGIN = НСтр( "ru = 'Core.ПолучениеФайловGitLab.Начало';en = 'Core.ReceivingFilesGitLab.Begin'" );
	EVENT_MESSAGE = НСтр( "ru = 'Core.ПолучениеФайловGitLab';en = 'Core.ReceivingFilesGitLab'" );
	EVENT_MESSAGE_END = НСтр( "ru = 'Core.ПолучениеФайловGitLab.Окончание';en = 'Core.ReceivingFilesGitLab.End'" );
	
	RECEIVING_MESSAGE = НСтр("ru = 'получение файлов с сервера...';en = 'receiving files from the server...'");
	
	ПараметрыЛогирования = Логирование.ДополнительныеПараметры( ОбработчикСобытия ); 
	Логирование.Информация( EVENT_MESSAGE_BEGIN, RECEIVING_MESSAGE, ПараметрыЛогирования );	

	ПараметрыПроекта = ОписаниеПроекта( ДанныеЗапроса );
	Результат = ДействияНадФайламиПоДаннымЗапроса( ДанныеЗапроса, ПараметрыПроекта );
	Результат = ОписаниеФайловСрезПоследних( Результат );
	Маршрутизация.СформироватьОписаниеФайловМаршрутизации( Результат, ДанныеЗапроса, ПараметрыПроекта );

	ПараметрыСоединения = ConnectionParams( ПараметрыПроекта.АдресСервера );
	
	ЗаполнитьОтправляемыеДанныеФайлами( Результат, ПараметрыСоединения );	

	Для Каждого ОписаниеФайла Из Результат Цикл
		
		Если ( НЕ ПустаяСтрока(ОписаниеФайла.ErrorInfo) ) Тогда
			
			Логирование.Ошибка( EVENT_MESSAGE, ОписаниеФайла.ErrorInfo, ПараметрыЛогирования );
			
		КонецЕсли;
			
	КонецЦикла;
	
	Логирование.Информация( EVENT_MESSAGE_END, RECEIVING_MESSAGE, ПараметрыЛогирования );	

	Возврат Результат;	
	
КонецФункции

// Возвращает десериализованный из JSON ответ сервера GitLab с описанием всех Merge Request проекта.
// Информация о проекте и адресе сервера GitLab определяется из данных запроса.
// 
// Параметры:
// 	QueryData - Соответствие - десериализованное из JSON тело запроса;
// Returns:
//   Массив, Соответствие, Структура - ответ, десериализованный из JSON. 
//
Function GetMergeRequestsByQueryData( Val QueryData ) Export
	
	Var ProjectParams;
	Var ConnectionParams;
	Var Headers;
	Var URL;
	Var AdditionalParams;
	
	ProjectParams = ОписаниеПроекта( QueryData );
	ConnectionParams = ConnectionParams( ProjectParams.АдресСервера );
	
	Headers = New Map();
	Headers.Insert( "PRIVATE-TOKEN", ConnectionParams.Token );
		
	AdditionalParams = New Structure();
	AdditionalParams.Insert( "Заголовки", Headers );
	AdditionalParams.Insert( "Таймаут", ConnectionParams.Timeout );
	
	URL = ConnectionParams.URL + MergeRequestsPath( ProjectParams.Идентификатор );

	Return HTTPConnector.GetJson( URL, Undefined, AdditionalParams );
	
EndFunction

#EndRegion

#Region Internal

// Возвращает перекодированный в URL относительный путь к RAW файлу. 
// 
// Параметры:
// 	ProjectId - Строка - id проекта;
// 	URLFilePath - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
// 	Commit - Строка - сommit SHA;
// 
// Returns:
// 	Строка - перекодированный в URL относительный путь к файлу.
//
Функция RAWFilePath( Знач ProjectId, Знач URLFilePath, Знач Commit ) Экспорт
	
	Var Шаблон;
	
	Шаблон = "/api/v4/projects/%1/repository/files/%2/raw?ref=%3";
	URLFilePath = КодироватьСтроку( URLFilePath, СпособКодированияСтроки.КодировкаURL );
	
	Возврат СтрШаблон( Шаблон, ProjectId, URLFilePath, Commit );
	
КонецФункции

#EndRegion

#Region Private

// Возвращает описание проекта GitLab по данным запроса.
// 
// Параметры:
// 	ДанныеЗапроса - Соответствие - десериализованное из JSON тело запроса;
//
// Returns:
// 	Структура - Описание:
// * Идентификатор - Строка - числовой идентификатор проекта (репозитория);
// * АдресСервера - Строка - адрес сервера вместе со схемой обращения к серверу;
// 
Функция ОписаниеПроекта( Знач ДанныеЗапроса )
	
	Var ОписаниеПроекта;
	Var URL;
	Var НачалоОтносительногоПути;
	Var АдресСервера;
	Var Результат;
	
	ОписаниеПроекта = ДанныеЗапроса.Получить( "project" );

	URL = ОписаниеПроекта.Получить( "http_url" );
	НачалоОтносительногоПути = СтрНайти( URL, "/", , , 3 ) - 1;
	
	АдресСервера = "";
	
	Если ( НачалоОтносительногоПути > 0 ) Тогда
		
		АдресСервера = Лев( URL, НачалоОтносительногоПути );
		
	КонецЕсли;	
			
	Результат = Новый Структура();
	Результат.Вставить( "Идентификатор", Строка(ОписаниеПроекта.Получить("id")) );
	Результат.Вставить( "АдресСервера", АдресСервера );	

	Возврат Результат;
	
КонецФункции

Function MergeRequestsPath( Val ProjectId )
	
	Return StrTemplate( "/api/v4/projects/%1/merge_requests", ProjectId );
	
EndFunction

// PossibleFileActions returns a list of possible actions on files in accordance with the GitLab REST API.
// 
// Returns:
// 	Массив - "added", "modified", "removed";
//
Функция PossibleFileActions()
		
	Возврат GitLabCached.PossibleFileActions();
	
КонецФункции

// Возвращает результат проверки, что файл является скомпилированным файлом внешнего отчета или обработки.
// 
// Параметры:
// 	URLFilePath - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
//
// Returns:
// 	Булево - Истина - это скомпилированный файл, иначе - Ложь;
//
Функция ЭтоСкомпилированныйФайл( Знач URLFilePath )
	
	Возврат ( СтрЗаканчиваетсяНа(URLFilePath, ".epf") ИЛИ СтрЗаканчиваетсяНа(URLFilePath, ".erf") );
	
КонецФункции

Функция ОписаниеФайловСрезПоследних( Знач ОписаниеФайлов, Знач Action = "modified" )
	
	Var Результат;
	Var ПараметрыОтбора;
	Var НайденныеСтроки;
	
	Результат = ОписаниеФайлов.СкопироватьКолонки();
	ПолныеИменаФайлов = CommonUseClientServer.CollapseArray( ОписаниеФайлов.ВыгрузитьКолонку("URLFilePath") );
	
	Если ( НЕ ЗначениеЗаполнено(ПолныеИменаФайлов) ) Тогда
		
		Возврат Результат;
	
	КонецЕсли;
	
	ОписаниеФайлов.Сортировать( "Date Убыв" );
	
	ПараметрыОтбора = Новый Структура( "URLFilePath, Action" );
	ПараметрыОтбора.Action = Action;
			
	Для каждого URLFilePath Из ПолныеИменаФайлов Цикл

		ПараметрыОтбора.URLFilePath = URLFilePath;
		НайденныеСтроки = ОписаниеФайлов.НайтиСтроки( ПараметрыОтбора );

		Если ( НЕ ЗначениеЗаполнено(НайденныеСтроки) ) Тогда

			Продолжить;
								
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств( Результат.Добавить(), НайденныеСтроки[0] );
		
	КонецЦикла;

	Возврат Результат;
	
КонецФункции

Функция ДействияНадФайламиПоДаннымЗапроса( Знач ДанныеЗапроса, Знач ПараметрыПроекта )
	
	Var Commits;
	Var CommitSHA;
	Var Date;
	Var ПолныеИменаФайлов;
	Var RAWFilePath;
	Var НоваяСтрока;
	Var Результат;
	
	Commits = ДанныеЗапроса.Получить( "commits" );
	Результат = RemoteFilesEmpty();
	
	Для каждого Commit Из Commits Цикл

		CommitSHA = Commit.Получить( "id" );
		Date = Commit.Получить( "timestamp" );
		
		Для каждого Action Из PossibleFileActions() Цикл

			ПолныеИменаФайлов = Commit.Получить( Action );

			Для каждого URLFilePath Из ПолныеИменаФайлов Цикл
				
				Если ( НЕ ЭтоСкомпилированныйФайл(URLFilePath) ) Тогда
					
					Продолжить;

				КонецЕсли;

				НоваяСтрока = Результат.Добавить();
				RAWFilePath = RAWFilePath( ПараметрыПроекта.Идентификатор, URLFilePath, CommitSHA );
				НоваяСтрока.RAWFilePath = RAWFilePath;
				НоваяСтрока.URLFilePath = URLFilePath;
				НоваяСтрока.Action = Action;
				НоваяСтрока.Date = Date;
				НоваяСтрока.CommitSHA = CommitSHA;

			КонецЦикла;

		КонецЦикла;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Процедура ЗаполнитьОтправляемыеДанныеФайлами( ОтправляемыеДанные, Знач ПараметрыСоединения )

	Var ПутиКФайлам;
	Var Файл;
	Var Файлы;

	ПутиКФайлам = ОтправляемыеДанные.ВыгрузитьКолонку( "RAWFilePath" );
	Файлы = GetRemoteFiles( ПараметрыСоединения, ПутиКФайлам );
	
	Для каждого ОписаниеФайла Из Файлы Цикл
			
		Файл = ОтправляемыеДанные.Найти( ОписаниеФайла.RAWFilePath, "RAWFilePath" );
		ЗаполнитьЗначенияСвойств( Файл, ОписаниеФайла );

	КонецЦикла;

КонецПроцедуры

Функция ОписаниеПолучаемогоФайла()

	Var Результат;
	
	Результат = Новый Структура();
	Результат.Вставить( "RAWFilePath", "" );
	Результат.Вставить( "FileName", "" );
	Результат.Вставить( "BinaryData", Неопределено );
	Результат.Вставить( "ErrorInfo", "" );
	
	Возврат Результат;

КонецФункции

#EndRegion