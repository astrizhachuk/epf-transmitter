// BSLLS-off
#Region Public

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure LoadEventsHistory(Фреймворк) Export
	
	LEVEL_MESSAGE = НСтр("ru = 'Информация';en = 'Information'");
	EVENT_OBJECT = НСтр( "ru = 'ОбработчикиСобытий';en = 'Webhooks'" );
	
	//given
	WebhookCleanUp();
	InformationRegistersCleanUp();
	ОбработчикСобытия = AddWebhook("ЮнитТест1", "ЮнитТест");
	ЗаписьЖурналаРегистрации(EVENT_OBJECT + ".Операция.Что", УровеньЖурналаРегистрации.Информация );
	ЗаписьЖурналаРегистрации(EVENT_OBJECT + ".Операция.Что.Что", УровеньЖурналаРегистрации.Информация, Метаданные.НайтиПоТипу(ТипЗнч(ОбработчикСобытия)), ОбработчикСобытия.Ссылка );
	ЗаписьЖурналаРегистрации(EVENT_OBJECT + ".Операция.Что.Что.200", УровеньЖурналаРегистрации.Информация, Метаданные.НайтиПоТипу(ТипЗнч(ОбработчикСобытия)), ОбработчикСобытия.Ссылка );
	UtilsServer.Pause(2);
	Filter = Новый Структура;
	Filter.Insert("StartDate", НачалоДня(ТекущаяДата()));
	Filter.Insert("EndDate", КонецДня(ТекущаяДата()));
	RecordsLoaded = 0;
	// when	
	Webhooks.LoadEventsHistory( ОбработчикСобытия, "EventsHistory", Filter, RecordsLoaded );
	// then
	Фреймворк.ПроверитьРавенство(ОбработчикСобытия.EventsHistory.Количество(), 2);
	Фреймворк.ПроверитьРавенство(ОбработчикСобытия.EventsHistory[0].Action, "Операция");
	Фреймворк.ПроверитьРавенство(ОбработчикСобытия.EventsHistory[1].Action, "Операция");
	Фреймворк.ПроверитьРавенство(ОбработчикСобытия.EventsHistory[0].Level, LEVEL_MESSAGE);
	Фреймворк.ПроверитьРавенство(ОбработчикСобытия.EventsHistory[1].Level, LEVEL_MESSAGE);
	Фреймворк.ПроверитьРавенство(ОбработчикСобытия.EventsHistory[0].Event, EVENT_OBJECT + ".Операция.Что.Что");
	Фреймворк.ПроверитьРавенство(ОбработчикСобытия.EventsHistory[1].Event, EVENT_OBJECT + ".Операция.Что.Что.200");
	Фреймворк.ПроверитьРавенство(ОбработчикСобытия.EventsHistory[0].EventPresentation, "Что.Что");
	Фреймворк.ПроверитьРавенство(ОбработчикСобытия.EventsHistory[1].EventPresentation, "Что.Что");
	Фреймворк.ПроверитьРавенство(ОбработчикСобытия.EventsHistory[0].HTTPStatusCode, 0);
	Фреймворк.ПроверитьРавенство(ОбработчикСобытия.EventsHistory[1].HTTPStatusCode, 200);
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure SaveQueryData(Фреймворк) Export
	
	// given
	WebhookCleanUp();
	InformationRegistersCleanUp();
	СекретныйКлюч = "ЮнитТест";
	ОбработчикСобытия = AddWebhook("ЮнитТест1", СекретныйКлюч);
	Данные = "Тест";
	// when	
	Webhooks.SaveQueryData(ОбработчикСобытия.Ссылка, "CheckoutSHA", Данные);
	// then
	НаборЗаписей = РегистрыСведений[ "QueryData" ].СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Webhook.Установить( ОбработчикСобытия.Ссылка );
	НаборЗаписей.Отбор.CheckoutSHA.Установить( "CheckoutSHA" );
	НаборЗаписей.Прочитать();
	Фреймворк.ПроверитьРавенство(НаборЗаписей.Количество(), 1);
	Фреймворк.ПроверитьРавенство(НаборЗаписей[0].Data.Получить(), "Тест");
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure SaveQueryDataWriteError(Фреймворк) Export
	
	RAISE_MESSAGE = НСтр("ru = 'Должно быть вызвано исключение.';en = 'Should raise an error.'");
	ERROR_WRITE_MESSAGE = НСтр("ru = 'Ошибка при вызове метода контекста (Write)';en = 'Error calling context method (Write)'");
	
	// given
	WebhookCleanUp();
	InformationRegistersCleanUp();
	Данные = "Тест";
	// when
	Попытка
		Webhooks.SaveQueryData(Catalogs.Webhooks.ПустаяСсылка(), "CheckoutSHA", Данные);
		ВызватьИсключение RAISE_MESSAGE;
	Исключение
		// then
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		Фреймворк.ПроверитьВхождение(ИнформацияОбОшибке.Описание, ERROR_WRITE_MESSAGE);
	КонецПопытки;
	
EndProcedure

// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure SaveRemoteFiles(Фреймворк) Export
	
	// given
	WebhookCleanUp();
	InformationRegistersCleanUp();
	СекретныйКлюч = "ЮнитТест";
	ОбработчикСобытия = AddWebhook("ЮнитТест1", СекретныйКлюч);
	Данные = "Тест";
	// when	
	Webhooks.SaveRemoteFiles(ОбработчикСобытия.Ссылка, "CheckoutSHA", Данные);
	// then
	НаборЗаписей = РегистрыСведений[ "RemoteFiles" ].СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Webhook.Установить( ОбработчикСобытия.Ссылка );
	НаборЗаписей.Отбор.CheckoutSHA.Установить( "CheckoutSHA" );
	НаборЗаписей.Прочитать();
	Фреймворк.ПроверитьРавенство(НаборЗаписей.Количество(), 1);
	Фреймворк.ПроверитьРавенство(НаборЗаписей[0].Data.Получить(), "Тест");
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure SaveRemoteFilesWriteError(Фреймворк) Export
	
	RAISE_MESSAGE = НСтр("ru = 'Должно быть вызвано исключение.';en = 'Should raise an error.'");
	ERROR_WRITE_MESSAGE = НСтр("ru = 'Ошибка при вызове метода контекста (Write)';en = 'Error calling context method (Write)'");
	
	// given
	WebhookCleanUp();
	InformationRegistersCleanUp();
	Данные = "Тест";
	// when
	Попытка
		Webhooks.SaveRemoteFiles(Catalogs.Webhooks.ПустаяСсылка(), "CheckoutSHA", Данные);
		ВызватьИсключение RAISE_MESSAGE;
	Исключение
		// then
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		Фреймворк.ПроверитьВхождение(ИнформацияОбОшибке.Описание, ERROR_WRITE_MESSAGE);
	КонецПопытки;
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure LoadRemoteFiles(Фреймворк) Export
	
	// given
	WebhookCleanUp();
	InformationRegistersCleanUp();
	СекретныйКлюч = "ЮнитТест";
	ОбработчикСобытия = AddWebhook("ЮнитТест1", СекретныйКлюч);
	
	Данные = Новый ТаблицаЗначений;
	Данные.Колонки.Добавить("Колонка");
	НоваяСтрока = Данные.Добавить();
	НоваяСтрока.Колонка = "Тест";
	
	МенеджерЗаписи = РегистрыСведений.RemoteFiles.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.CheckoutSHA = "CheckoutSHA";
	МенеджерЗаписи.Data = Новый ХранилищеЗначения(Данные);
	МенеджерЗаписи.Записать();
	
	// when	
	Результат = Webhooks.LoadRemoteFiles( ОбработчикСобытия.Ссылка, "CheckoutSHA" );
	// then
	Фреймворк.ПроверитьТип(Результат, "ТаблицаЗначений");
	Фреймворк.ПроверитьРавенство(Результат.Количество(), 1);
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure LoadRemoteFilesNoData(Фреймворк) Export
	
	// given
	WebhookCleanUp();
	InformationRegistersCleanUp();
	СекретныйКлюч = "ЮнитТест";
	ОбработчикСобытия = AddWebhook("ЮнитТест1", СекретныйКлюч);
	// when	
	Результат = Webhooks.LoadRemoteFiles( ОбработчикСобытия.Ссылка, "CheckoutSHA" );
	// then
	Фреймворк.ПроверитьТип(Результат, "ТаблицаЗначений");
	Фреймворк.ПроверитьРавенство(Результат.Количество(), 0);
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure LoadQueryData(Фреймворк) Export
	
	// given
	WebhookCleanUp();
	InformationRegistersCleanUp();
	СекретныйКлюч = "ЮнитТест";
	ОбработчикСобытия = AddWebhook("ЮнитТест1", СекретныйКлюч);
	
	Данные = Новый Соответствие();
	Данные.Вставить("CheckoutSHA", "Значение");
	
	МенеджерЗаписи = РегистрыСведений.QueryData.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.CheckoutSHA = "CheckoutSHA";
	МенеджерЗаписи.Data = Новый ХранилищеЗначения(Данные);
	МенеджерЗаписи.Записать();
	
	// when	
	Результат = Webhooks.LoadQueryData( ОбработчикСобытия.Ссылка, "CheckoutSHA" );
	// then
	Фреймворк.ПроверитьТип(Результат, "Соответствие");
	Фреймворк.ПроверитьРавенство(Результат.Количество(), 1);
	Фреймворк.ПроверитьРавенство(Результат.Получить("CheckoutSHA"), "Значение");
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure LoadQueryDataNoData(Фреймворк) Export
	
	// given
	WebhookCleanUp();
	InformationRegistersCleanUp();
	СекретныйКлюч = "ЮнитТест";
	ОбработчикСобытия = AddWebhook("ЮнитТест1", СекретныйКлюч);
	// when	
	Результат = Webhooks.LoadQueryData( ОбработчикСобытия.Ссылка, "CheckoutSHA" );
	// then
	Фреймворк.ПроверитьТип(Результат, "Соответствие");
	Фреймворк.ПроверитьРавенство(Результат.Количество(), 0);
	
EndProcedure

#EndRegion

#Region Internal

Function AddWebhook(Val Name = "", Val ProjectURL = "", Val SecretToken = "") Export
	
		Item = Catalogs.Webhooks.CreateItem();
		Item.DataExchange.Load = True;
		Item.Description = Name;
		Item.ProjectURL = ProjectURL;
		Item.SecretToken = SecretToken;
		Item.Write();
		
		Return Item;
	
EndFunction

#EndRegion

#Region Private

Procedure WebhookCleanUp()
	
	UtilsServer.CatalogCleanUp("Webhooks");

EndProcedure

Procedure InformationRegistersCleanUp()
	
	UtilsServer.InformationRegisterCleanUp("QueryData, RemoteFiles");

EndProcedure

Function NewWebhook(Val Name, Val ProjectURL, Val Token)

	Return TestsWebhooksServer.AddWebhook(Name, ProjectURL, Token);

EndFunction

#EndRegion