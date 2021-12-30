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
	ExternalRequestHandlersCleanUp();
	InformationRegistersCleanUp();
	ОбработчикСобытия = AddExternalRequestHandler("ЮнитТест1", "ЮнитТест");
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

#EndRegion

#Region Internal

Function AddExternalRequestHandler(Val Name = "", Val ProjectURL = "", Val SecretToken = "")
	
		Item = Catalogs.ExternalRequestHandlers.CreateItem();
		Item.DataExchange.Load = True;
		Item.Description = Name;
		Item.ProjectURL = ProjectURL;
		Item.SecretToken = SecretToken;
		Item.Write();
		
		Return Item;
	
EndFunction

#EndRegion

#Region Private

Procedure ExternalRequestHandlersCleanUp()
	
	UtilsServer.CatalogCleanUp("ExternalRequestHandlers");

EndProcedure

Procedure InformationRegistersCleanUp()
	
	UtilsServer.InformationRegisterCleanUp("QueryData, RemoteFiles");

EndProcedure

#EndRegion