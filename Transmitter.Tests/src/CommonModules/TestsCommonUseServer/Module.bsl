#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetVersion(Framework) Export

	// given
	// when
	Result = CommonUseServerCall.GetVersion();
	// then
	Framework.AssertEqual(Result, Metadata.Version);
	
EndProcedure

// @unit-test:fast
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure МокСерверДоступен(Фреймворк) Export
	
	// given
	URL = "http://mockserver:1080";
	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL, , Истина).ОжидатьOpenAPI("file:/tmp/endpoint.yml", """version"": ""200""");
	Мок = Неопределено;
	// when
	Результат = HTTPConnector.Get(URL + "/version");
	// then
	Фреймворк.ПроверитьРавенство(Результат.КодСостояния, 200);
	ТелоОтвета = HTTPConnector.AsText(Результат, КодировкаТекста.UTF8);
	Фреймворк.ПроверитьВхождение(ТелоОтвета, """message""");

EndProcedure

// @unit-test
Procedure AppendCollectionFromStream(Фреймворк) Export
	
	Поток = Новый ПотокВПамяти();
	ЗаписьТекста = Новый ЗаписьТекста(Поток);
	Значение = "Туточки текст потока";
	ЗаписьТекста.Записать(Значение);
   	ЗаписьТекста.Закрыть();

	Коллекция = Новый Структура("Ключ1", "Значение1");
	CommonUseServerCall.AppendCollectionFromStream(Коллекция, "Ключ2", Поток);
   	Поток.Закрыть();

   	Фреймворк.ПроверитьРавенство( Значение, Коллекция.Ключ2 );

EndProcedure

#EndRegion

#Region Internal



Function AsText(Знач Ответ, Знач Кодировка = Неопределено) Export
	
	Возврат HTTPConnector.AsText(Ответ, Кодировка);

EndFunction



Procedure РегистрыСведенийУдалитьВсеДанные( Знач ИменаРегистровСведений ) Export
	
	МассивИмен = СтрРазделить(ИменаРегистровСведений, ",");
	
	Для Каждого Элемент Из МассивИмен Цикл
		НаборЗаписей = РегистрыСведений[СокрЛП(Элемент)].СоздатьНаборЗаписей();
		НаборЗаписей.Записать();
	КонецЦикла;
	
EndProcedure

#EndRegion
