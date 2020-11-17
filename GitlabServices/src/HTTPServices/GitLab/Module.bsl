#Region Private

#Область HTTPМетоды

Функция ServicesGET( Запрос )
	
	Var ОписаниеСервиса;
	Var Ответ;
	
	Ответ = Новый HTTPСервисОтвет( HTTPStatusCodesClientServerCached.FindCodeById("OK") );
	
	ОписаниеСервиса = HTTPServices.ServiceDescriptionByName( "gitlab" );
	
	ТелоОтвета = Новый Структура();
	ТелоОтвета.Вставить( "version", Метаданные.Версия );
	ТелоОтвета.Вставить( "services", ОписаниеСервиса );
	
	Ответ.Заголовки.Вставить( "Content-Type", "application/json" );
	Ответ.УстановитьТелоИзСтроки( HTTPConnector.ОбъектВJson(ТелоОтвета) );
	
	Возврат Ответ;
	
КонецФункции

Функция WebhooksPOST( Запрос )
	
	Var ОбработчикСобытия;
	Var ДанныеЗапроса;
	Var Ответ;
	Var LoggingOptions;
	
	EVENT_MESSAGE_BEGIN = НСтр( "ru = 'WebService.ОбработкаЗапроса.Начало';en = 'WebService.QueryProcessing.Begin'" );
	EVENT_MESSAGE_END = НСтр( "ru = 'WebService.ОбработкаЗапроса.Окончание';en = 'WebService.QueryProcessing.End'" );
	
	RECEIVED_REQUEST_MESSAGE = НСтр( "ru = 'Получен запрос с сервера GitLab.';
									|en = 'Received a request from the GitLab server.'" );
	
	PROCESSED_REQUEST_MESSAGE = НСтр( "ru = 'Запрос с сервера GitLab обработан.';
									|en = 'The request from the GitLab server has been processed.'" );
	
	Ответ = Новый HTTPСервисОтвет( HTTPStatusCodesClientServerCached.FindCodeById("OK") );
	
	Логирование.Информация( EVENT_MESSAGE_BEGIN, RECEIVED_REQUEST_MESSAGE );
	
	ОбработчикСобытия = Неопределено;
	ПроверитьСекретныйКлюч( Запрос, Ответ, ОбработчикСобытия );
	ОпределитьДоступностьФункциональностиЗагрузкиИзВнешнегоРепозитория( Ответ );
	ПроверитьЗаголовкиЗапросаWebhooksPOST( ОбработчикСобытия, Запрос, Ответ );

	ДанныеЗапроса = Неопределено;
	ДесериализоватьТелоЗапроса( ОбработчикСобытия, Запрос, Ответ, ДанныеЗапроса );
	ПроверитьНаличиеОбязательныхДанныхВТелеЗапроса( ОбработчикСобытия, ДанныеЗапроса, Ответ );
	
	LoggingOptions = Логирование.ДополнительныеПараметры( , Ответ );
	
	Если ( HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда

		Логирование.Информация( EVENT_MESSAGE_END, PROCESSED_REQUEST_MESSAGE, LoggingOptions );
		
		DataProcessing.RunBackgroundJob( ОбработчикСобытия, ДанныеЗапроса );
		
	КонецЕсли;

	Возврат Ответ;
	
КонецФункции

#EndRegion

Процедура ПроверитьСекретныйКлюч( Знач Запрос, Ответ, ОбработчикСобытия )

	Var Token;
	Var LoggingOptions;
	
	EVENT_MESSAGE = НСтр( "ru = 'WebService.ОбработкаЗапроса';en = 'WebService.QueryProcessing'" );
	KEY_NOT_FOUND_MESSAGE = НСтр( "ru = 'Секретный ключ не найден.';
									|en = 'The Secret Key is not found.'" );

	
	Если ( НЕ HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Token = Запрос.Заголовки.Получить( "X-Gitlab-Token" );
	ОбработчикСобытия = Webhooks.FindByToken( Token );

	Если ( НЕ ЗначениеЗаполнено(ОбработчикСобытия) ) Тогда
		
		Ответ = Новый HTTPСервисОтвет( HTTPStatusCodesClientServerCached.FindCodeById("FORBIDDEN") );
		
		LoggingOptions = Логирование.ДополнительныеПараметры( , Ответ );
		Логирование.Предупреждение( EVENT_MESSAGE, KEY_NOT_FOUND_MESSAGE, LoggingOptions );
										 
	КонецЕсли;

КонецПроцедуры

Процедура ОпределитьДоступностьФункциональностиЗагрузкиИзВнешнегоРепозитория( Ответ )
	
	Var LoggingOptions;
	
	EVENT_MESSAGE = НСтр( "ru = 'WebService.ОбработкаЗапроса';en = 'WebService.QueryProcessing'" );
	LOADING_DISABLED_MESSAGE = НСтр( "ru = 'Загрузка из внешнего хранилища отключена.';
									|en = 'Loading of the files is disabled.'" );
	
	Если ( НЕ HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Если ( НЕ ПолучитьФункциональнуюОпцию("HandleRequests") ) Тогда
		
		Ответ = Новый HTTPСервисОтвет( HTTPStatusCodesClientServerCached.FindCodeById("LOCKED") );
		Ответ.Причина = LOADING_DISABLED_MESSAGE;
		
		LoggingOptions = Логирование.ДополнительныеПараметры( , Ответ );
		Логирование.Предупреждение( EVENT_MESSAGE, LOADING_DISABLED_MESSAGE, LoggingOptions );

	КонецЕсли;

КонецПроцедуры

// Проверяет что запрос пришел от репозитория для хранения внешних отчетов и обработок.
// 
// Параметры:
// 	Запрос - Запрос - HTTP-запрос;
//
// Returns:
// 	Булево - Истина, если это репозиторий для внешних отчетов и обработок, иначе - Ложь.
//
Функция ЭтоРепозиторийВнешнихОтчетовИОбработок( Знач Запрос )
	
	Var ТипВнешнегоХранилища;
	
	ТипВнешнегоХранилища = Запрос.ПараметрыURL.Получить( "ТипВнешнегоХранилища" );
	Возврат ( ТипВнешнегоХранилища <> Неопределено И ТипВнешнегоХранилища = "epf" );
	
КонецФункции

// Проверяет является ли запрос событием "Push Hook" и end-point выбран push.
// 
// Параметры:
// 	Запрос - HTTPСервисЗапрос - HTTP-запрос;
//
// Returns:
// 	Булево - Истина - запрос является Push Hook, иначе - Ложь.
//
Функция ЭтоСобытиеPush( Знач Запрос )
	
	Var Событие;
	Var ИмяМетода;
	
	Событие = Запрос.Заголовки.Получить( "X-Gitlab-Event" );
	ИмяМетода = Запрос.ПараметрыURL.Получить( "ИмяМетода" );
	
	Возврат ( ЗначениеЗаполнено(Событие) И (Событие = "Push Hook") И (ИмяМетода = "push") );
	
КонецФункции

Процедура ПроверитьЗаголовкиЗапросаWebhooksPOST( Знач ОбработчикСобытия, Знач Запрос, Ответ )
	
	Var LoggingOptions;
	
	EVENT_MESSAGE = НСтр( "ru = 'WebService.ОбработкаЗапроса';en = 'WebService.QueryProcessing'" );
	ONLY_EPF_MESSAGE = НСтр( "ru = ''Сервис доступен только для внешних отчетов и обработок.';
									|en = 'The service is available only for external reports and processing.'" );
	ONLY_PUSH_MESSAGE = НСтр( "ru = 'Сервис обрабатывает только события ""Push Hook"".';
									|en = 'Service only handles events ""Push Hook"".'" );
	
	Если ( НЕ HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда
		
		Возврат;
		
	КонецЕсли;

	LoggingOptions = Логирование.ДополнительныеПараметры( ОбработчикСобытия );

	Если ( НЕ ЭтоРепозиторийВнешнихОтчетовИОбработок(Запрос) ) Тогда

		Ответ = Новый HTTPСервисОтвет( HTTPStatusCodesClientServerCached.FindCodeById("BAD_REQUEST") );
		Логирование.Предупреждение( EVENT_MESSAGE, ONLY_EPF_MESSAGE, LoggingOptions );
												 
		Возврат;
	
	КонецЕсли;
	
	Если ( НЕ ЭтоСобытиеPush(Запрос) ) Тогда
		
		Ответ = Новый HTTPСервисОтвет( HTTPStatusCodesClientServerCached.FindCodeById("BAD_REQUEST") );
		Логирование.Предупреждение( EVENT_MESSAGE, ONLY_PUSH_MESSAGE, LoggingOptions );
												 
		Возврат;
	
	КонецЕсли;
	
КонецПроцедуры

// Десериализует тело HTTP запроса из формата JSON.
// 
// Параметры:
// 	ОбработчикСобытия - СправочникСсылка.Webhooks - ссылка на элемент справочника с обработчиками событий;
// 	Запрос - HTTPСервисЗапрос - HTTP-запрос;
// 	Ответ - HTTPСервисОтвет - HTTP-ответ;
// 	ДанныеЗапроса - Соответствие - (исходящий параметр) десериализованное из JSON тело запроса;
// 									исходный текст тела запроса добавляется в структуру с ключом "json".
//
Процедура ДесериализоватьТелоЗапроса( Знач ОбработчикСобытия, Знач Запрос, Знач Ответ, ДанныеЗапроса = Неопределено )
	
	Var Поток;
	Var ПараметрыПреобразования;
	Var LoggingOptions;
	
	EVENT_MESSAGE_BEGIN = НСтр( "ru = 'WebService.Десериализация.Начало';en = 'WebService.Unmarshalling.Begin'" );
	EVENT_MESSAGE = НСтр( "ru = 'WebService.Десериализация';en = 'WebService.Unmarshalling'" );
	EVENT_MESSAGE_END = НСтр( "ru = 'WebService.Десериализация.Окончание';en = 'WebService.Unmarshalling.End'" );
	
	UNMARSHALLING_MESSAGE = НСтр( "ru = 'десериализация запроса...';en = 'unmarshalling from a request...'" );
	
	Если ( НЕ HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда
		
		Возврат;
		
	КонецЕсли;
	
	LoggingOptions = Логирование.ДополнительныеПараметры( ОбработчикСобытия );
	Логирование.Информация( EVENT_MESSAGE_BEGIN, UNMARSHALLING_MESSAGE, LoggingOptions );
	
	Попытка
		
		Поток = Запрос.ПолучитьТелоКакПоток();
		
		ПараметрыПреобразования = Новый Структура();
		ПараметрыПреобразования.Вставить( "ПрочитатьВСоответствие", Истина );
		ПараметрыПреобразования.Вставить( "ИменаСвойствСоЗначениямиДата", "timestamp" );
		
		ДанныеЗапроса = HTTPConnector.JsonВОбъект( Поток, , ПараметрыПреобразования );
		CommonUseServerCall.AppendCollectionFromStream( ДанныеЗапроса, "json", Поток );
		
		Поток.Закрыть();
		
		Логирование.Информация( EVENT_MESSAGE_END, UNMARSHALLING_MESSAGE, LoggingOptions );

	Исключение
		
		Поток.Закрыть();
		Логирование.Ошибка( EVENT_MESSAGE, ИнформацияОбОшибке().Описание, LoggingOptions );
		
		ВызватьИсключение;
		
	КонецПопытки;
	
КонецПроцедуры

Функция ПроверяемыеЭлементы( Знач ДанныеЗапроса )
	
	Var Проект;
	Var Коммиты;
	Var Результат;
	
	Результат = Новый Соответствие();
	Результат.Вставить( "тело запроса" , ДанныеЗапроса ); //TODO что за шляпа "тело запроса", непонятно, может root?		
	Результат.Вставить( "checkout_sha" , ДанныеЗапроса.Получить("checkout_sha") );
	
	Проект = ДанныеЗапроса.Получить("project");
	Результат.Вставить( "project" , Проект );
	
	Если ( Проект <> Неопределено ) Тогда
		
		Результат.Вставить( "project/web_url" , Проект.Получить("web_url") );
		Результат.Вставить( "project/id" , Проект.Получить("id") );
		
	КонецЕсли;
	
	Коммиты = ДанныеЗапроса.Получить("commits");
	Результат.Вставить( "commits" , Коммиты );
	
	Если ( Коммиты <> Неопределено ) Тогда
		
		Для Индекс = 0 По Коммиты.ВГраница() Цикл
			
			Результат.Вставить( "commits[" + Строка(Индекс) + "]/id", Коммиты[Индекс].Получить("id") );
			
		КонецЦикла;
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Проверяет сериализованные данные тела запроса на наличие обязательных данных.
// 
// Параметры:
// 	ОбработчикСобытия - СправочникСсылка.Webhooks - ссылка на элемент справочника с обработчиками событий;
// 	ДанныеЗапроса - Соответствие - сериализованные данные HTTP-запроса;
// 	Ответ - HTTPСервисОтвет - HTTP-ответ;
//
Процедура ПроверитьНаличиеОбязательныхДанныхВТелеЗапроса( Знач ОбработчикСобытия, Знач ДанныеЗапроса, Ответ )
	
	Var ТекстСообщения;
	Var LoggingOptions;
	
	EVENT_MESSAGE_BEGIN = НСтр( "ru = 'WebService.ПроверкаЗапроса.Начало';en = 'WebService.RequestValidation.Begin'" );
	EVENT_MESSAGE = НСтр( "ru = 'WebService.ПроверкаЗапроса';en = 'WebService.RequestValidation'" );
	EVENT_MESSAGE_END = НСтр( "ru = 'WebService.ПроверкаЗапроса.Окончание';en = 'WebService.RequestValidation.End'" );

	VALIDATION_MESSAGE = НСтр( "ru = 'проверка данных запроса...';en = 'query data validation...'" );
	MISSING_DATA_MESSAGE = НСтр( "ru = 'В данных запроса отсутствует %1.';en = '%1 is missing in the request data.'" );
	
	Если ( НЕ HTTPStatusCodesClientServerCached.isOk(Ответ.КодСостояния) ) Тогда
		
		Возврат;
		
	КонецЕсли;
	
	LoggingOptions = Логирование.ДополнительныеПараметры( ОбработчикСобытия );
	Логирование.Информация( EVENT_MESSAGE_BEGIN, VALIDATION_MESSAGE, LoggingOptions );
	
	Коллекция = ПроверяемыеЭлементы( ДанныеЗапроса );
	
	Для Каждого Элемент Из Коллекция Цикл
		
		Если ( Элемент.Значение = Неопределено ) Тогда
			
			Ответ = Новый HTTPСервисОтвет(HTTPStatusCodesClientServerCached.FindCodeById("BAD_REQUEST"));
			
			ТекстСообщения = СтрШаблон( MISSING_DATA_MESSAGE, Элемент.Ключ );
			Логирование.Ошибка( EVENT_MESSAGE, ТекстСообщения, LoggingOptions );
			
			Возврат;		
			
		КонецЕсли;		
		
	КонецЦикла;
	
	Логирование.Информация( EVENT_MESSAGE_END, VALIDATION_MESSAGE, LoggingOptions );
	
КонецПроцедуры

#EndRegion