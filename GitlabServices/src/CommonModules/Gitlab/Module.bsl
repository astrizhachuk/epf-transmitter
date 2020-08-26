#Область ПрограммныйИнтерфейс

// Возвращает параметры соединения к серверу Gitlab по адресу и пользовательским настройкам подключения.
// 
// Параметры:
// 	Адрес - Строка - адрес к серверу Gitlab, например, "http://www.example.org";
//
// Возвращаемое значение:
// 	Структура - Описание:
// * Адрес - Строка - адрес к серверу GitLab;
// * Token - Строка - token доступа к серверу GitLab из текущих настроек сервисов;
// * Таймаут - Число - таймаут подключения к Gitlab из текущих настроек сервисов;
//
Функция ПараметрыСоединения( Знач Адрес ) Экспорт
	
	Перем ТекущиеНастройки;
	Перем Результат;
	
	ТекущиеНастройки = НастройкаСервисов.ТекущиеНастройки();
	
	Результат = Новый Структура();
	Результат.Вставить( "Адрес", Адрес );
	Результат.Вставить( "Token", ТекущиеНастройки.GitLabUserPrivateToken );
	Результат.Вставить( "Таймаут", ТекущиеНастройки.ТаймаутGitLab );
	
	Возврат Результат;
	
КонецФункции

// Получает с сервера GitLab файл и формирует его описание.
// 
// Параметры:
// 	ПараметрыСоединения - (См. Gitlab.ПараметрыСоединения)
// 	ПутьКФайлу - Строка - относительный путь к получаемому файлу в URL кодировке, например,
// 							"/api/v4/projects/1/repository/files/D0%BA%D0%B0%201.epf/raw?ref=ef3529e5486ff";
// 	
// Возвращаемое значение:
// 	Структура - описание:
// * ПутьКФайлуRAW - Строка - относительный путь к файлу в RAW формате;
// * ИмяФайла - Строка - имя файла в кодировке UTF-8;
// * ДвоичныеДанные - ДвоичныеДанные - данные файла;
// * ОписаниеОшибки - Строка - текст с описанием ошибки получения файла с сервера;
// 
Функция ПолучитьФайл( Знач ПараметрыСоединения, Знач ПутьКФайлу ) Экспорт

	Перем Адрес;
	Перем Заголовки;
	Перем ДополнительныеПараметры;
	Перем ИмяФайла;
	Перем Ответ;
	Перем Результат;
	
	Адрес = ПараметрыСоединения.Адрес + ПутьКФайлу;
	
	Результат = ОписаниеФайла();
	Результат.ПутьКФайлуRAW = ПутьКФайлу;

	Попытка

		Заголовки = Новый Соответствие();
		Заголовки.Вставить( "PRIVATE-TOKEN", ПараметрыСоединения.Token );
		
		ДополнительныеПараметры = Новый Структура();
		ДополнительныеПараметры.Вставить( "Заголовки", Заголовки );
		ДополнительныеПараметры.Вставить( "Таймаут", ПараметрыСоединения.Таймаут );
		
		Ответ = КоннекторHTTP.Get( Адрес, Неопределено, ДополнительныеПараметры );

		Если ( НЕ КодыСостоянияHTTPКлиентСерверПовтИсп.isOk(Ответ.КодСостояния) ) Тогда
			
			ВызватьИсключение КодыСостоянияHTTPКлиентСерверПовтИсп.НайтиИдентификаторПоКоду( Ответ.КодСостояния );
		
		КонецЕсли;
		
		ИмяФайла = Ответ.Заголовки.Получить( "X-Gitlab-File-Name" );
		
		Если ( ИмяФайла = Неопределено ) Тогда
			
			ВызватьИсключение НСтр("ru = 'Файл не найден.'");
			
		КонецЕсли;

		Если ( НЕ ЗначениеЗаполнено(Ответ.Тело) ) Тогда
			
			ВызватьИсключение НСтр("ru = 'Пустой файл.'");
			
		КонецЕсли;

		Результат.ИмяФайла = ИмяФайла;
		Результат.ДвоичныеДанные = Ответ.Тело;
		
	Исключение
	
		Результат.ОписаниеОшибки = СтрШаблон( НСтр("ru = 'Ошибка получения файла: %1'"),
										Адрес + Символы.ПС + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()) );
		
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

// Получает с сервера GitLab файлы и формирует их описание.
// 
// Параметры:
// 	ПараметрыСоединения - (См. Gitlab.ПараметрыСоединения)
// 	ПутиКФайлам - Массив из Строка - массив относительных путей к получаемым файлам в URL кодировке, например,
// 							"/api/v4/projects/1/repository/files/D0%BA%D0%B0%201.epf/raw?ref=ef3529e5486ff";
// 	
// Возвращаемое значение:
// 	Массив из Структура:
// * ПутьКФайлуRAW - Строка - относительный путь к файлу в RAW формате;
// * ИмяФайла - Строка - имя файла в кодировке UTF-8;
// * ДвоичныеДанные - ДвоичныеДанные - данные файла;
// * ОписаниеОшибки - Строка - текст с описанием ошибки получения файла с сервера;
// 
Функция ПолучитьФайлы( Знач ПараметрыСоединения, Знач ПутиКФайлам ) Экспорт
	
	Перем Результат;

	Результат = Новый Массив;
	
	Для Каждого ПутьКФайлу Из ПутиКФайлам Цикл
		
		Результат.Добавить( ПолучитьФайл(ПараметрыСоединения, ПутьКФайлу) );
		
	КонецЦикла;
	
	Возврат Результат;

КонецФункции

// TODO перепроверить описание
// TODO перенести в служебные процедуры и функции (убрать экспорт)
// Заполняет описание отправляемых файлов двоичными данными (RAW) с сервера GitLab.
// 
// Параметры:
// 	ОтправляемыеДанные - ТаблицаЗначений - описание:
// * Коммит - Строка - идентификатор коммита;
// * Дата - Дата - дата коммита;
// * ИмяФайла - Строка - имя файла;
// * ПолноеИмяФайла - Строка - имя файла вместе с директориями;
// * ПутьКФайлу - Строка - относительный путь к файлу RAW;
// * Операция - Строка - вид операции над файлом (A - добавлен, D - удален, M - изменен);
// * ДвоичныеДанные - ДвоичныеДанные - тело файла;
// * ОписаниеОшибки - Строка - описание ошибки при получении файла с сервера, если она была;
// 	ПараметрыСоединения - (См. Gitlab.ПараметрыСоединения):
//
Процедура ЗаполнитьОтправляемыеДанныеФайлами( ОтправляемыеДанные, Знач ПараметрыСоединения ) Экспорт

	Перем ПутиКФайлам;
	Перем Файл;
	Перем Файлы;

	ПутиКФайлам = ОтправляемыеДанные.ВыгрузитьКолонку( "ПутьКФайлу" );
	Файлы = ПолучитьФайлы( ПараметрыСоединения, ПутиКФайлам );
	
	Для каждого ОписаниеФайла Из Файлы Цикл
			
		Файл = ОтправляемыеДанные.Найти( ОписаниеФайла.ПутьКФайлуRAW, "ПутьКФайлу" );
		ЗаполнитьЗначенияСвойств( Файл, ОписаниеФайла );

	КонецЦикла;

КонецПроцедуры

Функция ПолучитьФайлыКОтправкеПоДаннымЗапроса( Знач ОбработчикСобытия, ДанныеЗапроса ) Экспорт
	
	Перем Результат;

	
	// TODO собрать таблицу всех экшенов по всем коммитам
	Результат = ДействияНадФайлами(ДанныеЗапроса );
	// TODO срез последних для модификаций
	ДанныеДляОтправки = НайтиИзмененныеФайлы(Результат);
	// TODO заполнить файлами с сервера 
	
	ПараметрыСоединения = ПараметрыСоединения("http://gitlab"); // заглушка
	ЗаполнитьОтправляемыеДанныеФайлами(ДанныеДляОтправки, ПараметрыСоединения);	


//	ИзмененияВРепозитории = ВыбратьТолькоПоследниеИзменения(ИзмененияВРепозитории);
//	
//	Коммиты = ДанныеТелаЗапроса.Получить("commits");
//	
//	Результат = ИзмененияВРепозитории.СкопироватьКолонки();
//	
//	//TODO убираем проход по коммитам, так как будем подготавивать готовую ТЗ для выгрузки с нужным срезом данных
//	Для каждого Коммит Из Коммиты Цикл
//		
//		Идентификатор     = Коммит.Получить("id");
//				//		ДанныеДляОтправки = ПолучитьДанныеДляОтправкиССервераGitLab(ИдентификаторWebhook,
//				//																		ПараметрыПроекта,
//				//																		ИзмененияВРепозитории,
//				//																		Идентификатор,
//				//																		PrivateToken,
//				//																		Таймаут);
//				//		
//				//		Для Каждого ДанныеДляОтправки Из ДанныеДляОтправки Цикл
//				//			Если ДанныеДляОтправки.ДвоичныеДанные = Неопределено ИЛИ ПустаяСтрока(ДанныеДляОтправки.ИмяФайла) Тогда
//				//				Продолжить;
//				//			КонецЕсли;
//				//			ЗаполнитьЗначенияСвойств(Результат.Добавить(), ДанныеДляОтправки);
//				//		КонецЦикла;
//
//
//		ДанныеДляОтправки = НайтиИзмененныеФайлы(ИзмененияВРепозитории, Идентификатор);
//		
//		ДополнительныеПараметры = Логирование.ДополнительныеДанные();
//		ДополнительныеПараметры.Объект = ИдентификаторWebhook;	
//	
//	
//		
//		//////
//		
//		ПараметрыСоединения = Gitlab.ПараметрыСоединения("http://gitlab"); // заглушка
//		Gitlab.ЗаполнитьОтправляемыеДанныеФайлами(ДанныеДляОтправки, ПараметрыСоединения);	
//		
//	КонецЦикла;
//	
//
//	ИзмененияВРепозитории = Неопределено;
//	
//	Возврат Результат;
	
	
	
	
	
	
	Возврат Результат;	
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Возвращает перекодированный в URL относительный путь к файлу в RAW формате. 
// 
// Параметры:
// 	ProjectId - Строка - id проекта;
// 	ПутьКФайлу - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
// 	Commit - Строка - сommit SHA;
// 
// Возвращаемое значение:
// 	Строка - перекодированный в URL относительный путь к файлу.
//
Функция ПутьКФайлуRAW( Знач ProjectId, Знач ПутьКФайлу, Знач Commit ) Экспорт
	
	Перем Шаблон;
	
	Шаблон = "/api/v4/projects/%1/repository/files/%2/raw?ref=%3";
	ПутьКФайлу = КодироватьСтроку( ПутьКФайлу, СпособКодированияСтроки.КодировкаURL );
	
	Возврат СтрШаблон(Шаблон, ProjectId, ПутьКФайлу, Commit);
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает перечень возможных действий над файлами в соответствии с REST API GitLab.
// 
// Возвращаемое значение:
// 	Массив - "added", "modified", "removed";
//
Функция ВозможныеДействияНадФайлами()
		
	Возврат GitlabПовтИсп.ВозможныеДействияНадФайлами();
	
КонецФункции

// Подготавливает таблицу значений с файлами для отправки. 
// 
// Параметры:
// Возвращаемое значение:
// 	ТаблицаЗначений - описание:
// * Коммит - Строка - идентификатор коммита;
// * Дата - Дата - дата коммита;
// * ИмяФайла - Строка - имя файла;
// * ПолноеИмяФайла - Строка - имя файла вместе с директориями;
// * ПутьКФайлу - Строка - относительный путь к файлу в формате URL;
// * Операция - Строка - вид операции над файлом (A - добавлен, D - удален, M - изменен);
// * ДвоичныеДанные - ДвоичныеДанные - тело файла;
Функция ОписаниеТаблицыДанныхДляОтправки()

	Перем ТаблицаЗначений;
	
	ТаблицаЗначений = Новый ТаблицаЗначений;
	ТаблицаЗначений.Колонки.Добавить("Коммит", Новый ОписаниеТипов("Строка"));
	ТаблицаЗначений.Колонки.Добавить("Дата", Новый ОписаниеТипов("Дата"));
	ТаблицаЗначений.Колонки.Добавить("ИмяФайла", Новый ОписаниеТипов("Строка"));
	ТаблицаЗначений.Колонки.Добавить("ПолноеИмяФайла", Новый ОписаниеТипов("Строка"));
	ТаблицаЗначений.Колонки.Добавить("ПутьКФайлу", Новый ОписаниеТипов("Строка"));
	ТаблицаЗначений.Колонки.Добавить("Операция", Новый ОписаниеТипов("Строка"));
	ТаблицаЗначений.Колонки.Добавить("ДвоичныеДанные", Новый ОписаниеТипов("ДвоичныеДанные"));
	ТаблицаЗначений.Колонки.Добавить("ОписаниеОшибки", Новый ОписаниеТипов("Строка"));

	Возврат ТаблицаЗначений;
	
КонецФункции







//// Ищет в таблице изменений файлов репозитория измененные двоичные файлы и подготавливает новую таблицу
//// для получения двоичных данных с сервера GitLab.
//// 
//// Параметры:
//// 	ИзмененияВРепозитории - (См. ВсеДействияНадДвоичнымиФайламиВнешнегоХранилища)
//// 	Коммит - Строка - идентификатор коммита.
//// Возвращаемое значение:
////	- ТаблицаЗначений - описание изменений:
//// 		* Коммит - Строка - идентификатор коммита;
//// 		* Дата - Дата - дата коммита;
//// 		* ПолноеИмяФайла - Строка - имя файла вместе с директориями, по которому осуществлялась операция;
//// 		* ИмяФайла - Строка - имя файла;
//// 		* ПутьКФайлу - Строка - относительный путь к файлу в формате URL;
//// 		* Операция - Строка - вид операции над файлом (A - добавлен, D - удален, M - изменен);
////		* ДвоичныеДанные - ДвоичныеДанные - тело файла.
//Функция НайтиИзмененныеФайлы(Знач ИзмененияВРепозитории, Знач Коммит)
//	
//	Перем ПараметрыОтбора;
//	Перем НайденныеСтроки;
//	Перем Результат;
//	
//	ПараметрыОтбора = Новый Структура("Коммит, Операция", Коммит, "modified");
//	НайденныеСтроки = ИзмененияВРепозитории.НайтиСтроки(ПараметрыОтбора);
//	
//	Результат = ИзмененияВРепозитории.Скопировать(НайденныеСтроки);
//	
//	Возврат Результат;
//	
//КонецФункции


// Получает параметры проекта репозитория из преобразованных в Соответствие данных тела запроса.
// 
// Параметры:
// 	ДанныеТелаЗапроса - (См. ПолучитьДанныеТелаЗапроса.ДанныеТелаЗапроса).
// Возвращаемое значение:
// 	Структура - Описание:
// * Идентификатор - Строка - идентификатор проекта.
// * СтруктураURI - (См. ОбщегоНазначенияКлиентСервер.СтруктураURI). 
Функция ПараметрыПроектаИзТелаЗапроса(Знач ДанныеТелаЗапроса)
	
	Перем ОписаниеПроекта;
	Перем ВебАдрес;
	Перем Идентификатор;
	Перем СтруктураURI;
	
	Перем Результат;
	
	Результат = Новый Структура;
	
	Если ДанныеТелаЗапроса = Неопределено Тогда
		Возврат Результат;
	КонецЕсли;
	
	ОписаниеПроекта = ДанныеТелаЗапроса.Получить("project");
	
	ВебАдрес      = ОписаниеПроекта.Получить("web_url");
	Идентификатор = Строка(ОписаниеПроекта.Получить("id"));
	Результат.Вставить("Идентификатор", Идентификатор);
	
	// TODO перепроверить вызов
	СтруктураURI = КоннекторHTTP.РазобратьURL(ВебАдрес);
	НачалоПуть = СтрНайти(ВебАдрес, СтруктураURI.Путь) - 1;
	URLСервера = ?(НачалоПуть >= 0, Лев(ВебАдрес, НачалоПуть), "" );
	СтруктураURI.Вставить( "URLСервера", URLСервера );
	Результат.Вставить("СтруктураURI", Новый ФиксированнаяСтруктура(СтруктураURI));
	
	Возврат Результат;
	
КонецФункции

// По расширению файла определяет является ли файл скомплилированным вариантом внешнего отчета или обработки.
// 
// Параметры:
// 	ПолноеИмяФайла - Строка - имя файла вместе с директориями;
// Возвращаемое значение:
// 	Булево - Истина - это скомпилированный вариант файла, иначе - Ложь.
Функция ЭтоСкомпилированныйФайл( Знач ПолноеИмяФайла )
	
	Возврат ( СтрЗаканчиваетсяНа(ПолноеИмяФайла, ".epf") ИЛИ СтрЗаканчиваетсяНа(ПолноеИмяФайла, ".erf") );
	
КонецФункции





// Заполняет таблицу изменений репозитория необходимыми данными, по которым с сервера GitLab будут забираться
// двоичные данные внешних отчетов/обработок.
// 
// Параметры:
// 	ДанныеЗапроса - (См. ПолучитьДанныеТелаЗапроса.ДанныеЗапроса).
// 	ПараметрыПроекта - (См. ПараметрыПроектаИзТелаЗапроса)
// Возвращаемое значение:
// 	ТаблицаЗначений - Описание:
// * Коммит - Строка - идентификатор коммита.
// * Дата - Дата - дата коммита.
// * ПолноеИмяФайла - Строка - имя файла вместе с директориями, по которому осуществлялась операция.
// * ПутьКФайлу - Строка - относительный путь к файлу в формате URL
// * Операция - Строка - вид операции над файлом (A - добавлен, D - удален, M - изменен).
Функция ДействияНадФайлами(Знач ДанныеЗапроса)
	
	ПараметрыПроекта = ПараметрыПроектаИзТелаЗапроса(ДанныеЗапроса);
	
	Коммиты = ДанныеЗапроса.Получить("commits");
	ТаблицаИзменений = ОписаниеТаблицыДанныхДляОтправки();
	
	Для каждого Коммит Из Коммиты Цикл

		Идентификатор =  Коммит.Получить("id");
		Дата = Коммит.Получить("timestamp");

		
		Для каждого Действие Из ВозможныеДействияНадФайлами() Цикл

			ПолныеИменаФайлов = Коммит.Получить(Действие);

			Для каждого ПолноеИмяФайла Из ПолныеИменаФайлов Цикл
				
				Если НЕ ЭтоСкомпилированныйФайл(ПолноеИмяФайла) Тогда
					Продолжить;					
				КонецЕсли;
								
				НоваяСтрока = ТаблицаИзменений.Добавить();
				НоваяСтрока.Коммит         = Идентификатор;
				НоваяСтрока.Дата           = Дата;
				НоваяСтрока.ПолноеИмяФайла = ПолноеИмяФайла;
				ПутьКФайлу  = Gitlab.ПутьКФайлуRAW(ПараметрыПроекта.Идентификатор, ПолноеИмяФайла, Идентификатор);
				НоваяСтрока.ПутьКФайлу = ПутьКФайлу;
				НоваяСтрока.Операция   = Действие;

			КонецЦикла;

		КонецЦикла;
		
	КонецЦикла;
	
	Возврат ТаблицаИзменений;
	
КонецФункции

Функция ОписаниеФайла()

	Перем Результат;
	
	Результат = Новый Структура();
	Результат.Вставить( "ПутьКФайлуRAW", "" );
	Результат.Вставить( "ИмяФайла", "" );
	Результат.Вставить( "ДвоичныеДанные", Неопределено );
	Результат.Вставить( "ОписаниеОшибки", "" );
	
	Возврат Результат;

КонецФункции

#КонецОбласти