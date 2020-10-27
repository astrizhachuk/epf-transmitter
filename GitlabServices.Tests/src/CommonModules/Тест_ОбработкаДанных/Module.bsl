#Region Internal

// @unit-test:dev
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Процедура НачатьЗапускОбработкиДанных(Фреймворк) Экспорт
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОчиститьРегистрыСведений();
	
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ОбработкаДанных");
	ОтборЖурналаРегистрацииПредупреждение = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ОбработкаДанных", "Предупреждение");
	
	ОбработчикСобытия = Тест_ОбработчикиСобытийСервер.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	
	// ДанныеЗапроса
	JSON = "{
			|  ""checkout_sha"": ""какой-то коммит..."",
			|  ""project"": {
			|    ""id"": 1,
			|    ""http_url"": ""http://www.example.com/root/external-epf.git""
			|  },
			|  ""commits"": [
			|    {
			|      ""id"": ""какой-то коммит..."",
			|      ""timestamp"": ""2020-07-21T09:22:31+00:00"",
			|      ""added"": [
			|        "".ext-epf.json"",
			|        ""src/Внешняя Обработка 1.xml"",
			|        ""test3.epf""
			|      ],
			|      ""modified"": [
			|        ""Каталог 2/test2.epf"",
			|        ""Каталог 1/test1.epf""
			|      ],
			|      ""removed"": [
			|
			|      ]
			|    }
			|  ]
			|}";
				
	ПараметрыПреобразования = Новый Структура();
	ПараметрыПреобразования.Вставить( "ReadToMap", Истина );
	ПараметрыПреобразования.Вставить( "PropertiesWithDateValuesNames", "timestamp" );
	ДанныеЗапроса = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения(), , ПараметрыПреобразования);

	ЭталонRouting = "/home/usr1cv8/test/expectation-routing.json";	
	Текст = Новый ЧтениеТекста(ЭталонRouting, КодировкаТекста.UTF8);
	JSON = Текст.Прочитать();
	JSON = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения());
	JSON = JSON.Получить("httpResponse").Получить("body").Получить("string");
	Settings = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения());
	
	ДанныеЗапроса.Получить("commits")[0].Вставить("settings", Settings);

	МенеджерЗаписи = РегистрыСведений.ДанныеЗапросов.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.ОбработчикСобытия = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.Ключ = "какой-то коммит...";
	МенеджерЗаписи.Данные = Новый ХранилищеЗначения(ДанныеЗапроса);
	МенеджерЗаписи.Записать();
	
	// ОтправляемыеДанные
	ОтправляемыеДанные = Новый ТаблицаЗначений();
	ОтправляемыеДанные.Колонки.Добавить( "ПутьКФайлуRAW", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ИмяФайла", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ПолноеИмяФайла", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ДвоичныеДанные", Новый ОписаниеТипов("ДвоичныеДанные"));
	ОтправляемыеДанные.Колонки.Добавить( "Операция", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "Дата", Новый ОписаниеТипов("Дата") );
	ОтправляемыеДанные.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ОписаниеОшибки", Новый ОписаниеТипов("Строка"));
	
	НоваяСтрока = ОтправляемыеДанные.Добавить();
	НоваяСтрока.ПутьКФайлуRAW = "/api/v4/projects/1/repository/files/Каталог 1/test1.epf/raw?ref=какой-то коммит...";
	НоваяСтрока.ИмяФайла = "";
	НоваяСтрока.ПолноеИмяФайла = "Каталог 1/test1.epf";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{""name1"":""result1""}");
	НоваяСтрока.Операция = "modifed";
	НоваяСтрока.Дата = Дата(2020, 07, 21, 09, 22, 31);
	НоваяСтрока.CommitSHA = "какой-то коммит...";
	НоваяСтрока.ОписаниеОшибки = "тут какая-то ошибка";
	
	НоваяСтрока = ОтправляемыеДанные.Добавить();
	НоваяСтрока.ПутьКФайлуRAW = "/api/v4/projects/1/repository/files/Каталог 2/test2.epf/raw?ref=какой-то коммит...";
	НоваяСтрока.ИмяФайла = "test2.epf";
	НоваяСтрока.ПолноеИмяФайла = "Каталог 2/test2.epf";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{some_json_3}");
	НоваяСтрока.Операция = "modifed";
	НоваяСтрока.Дата = Дата(2020, 07, 21, 09, 22, 31);	
	НоваяСтрока.CommitSHA = "какой-то коммит...";
	НоваяСтрока.ОписаниеОшибки = "";
	
	МенеджерЗаписи = РегистрыСведений.ВнешниеФайлы.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.ОбработчикСобытия = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.Ключ = "какой-то коммит...";
	МенеджерЗаписи.Данные = Новый ХранилищеЗначения(ОтправляемыеДанные);
	МенеджерЗаписи.Записать();
	
	// when
	Результат = ОбработкаДанных.НачатьЗапускОбработкиДанных(ОбработчикСобытия.Ссылка, "какой-то коммит...");
	
	// then
	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, "[ какой-то коммит... ]: отправляемых файлов: 1");
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[1].Comment, "[ какой-то коммит... ]: запущенных заданий: 2");
	
	ЖурналРегистрацииПредупреждение = СобытияЖурналаРегистрации(ОтборЖурналаРегистрацииПредупреждение);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииПредупреждение[0].Comment, "[ какой-то коммит... ]: ошибка получения файла");
	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииПредупреждение[0].Comment, "тут какая-то ошибка");

КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Процедура НачатьЗапускОбработкиДанныхРучнойЗапуск(Фреймворк) Экспорт
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОбработчикСобытия = Тест_ОбработчикиСобытийСервер.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	// when
	Результат = ОбработкаДанных.НачатьЗапускОбработкиДанных(ОбработчикСобытия.Ссылка, "какой-то коммит...");
	// then
	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");

КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Процедура НачатьЗапускОбработкиДанныхWebhook(Фреймворк) Экспорт
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОбработчикСобытия = Тест_ОбработчикиСобытийСервер.ДобавитьОбработчикСобытий("ЮнитТест1", "Webhook");
	Данные = Новый Соответствие;
	Данные.Вставить("checkout_sha", "какой-то коммит...");
	// when
	Результат = ОбработкаДанных.НачатьЗапускОбработкиДанных(ОбработчикСобытия.Ссылка, Данные);
	// then
	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");

КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Процедура НачатьЗапускОбработкиДанныхWebhookОтсутствуетCheckoutSHA(Фреймворк) Экспорт
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ОбработкаДанных", "Ошибка");
	ОбработчикСобытия = Тест_ОбработчикиСобытийСервер.ДобавитьОбработчикСобытий("ЮнитТест1", "Webhook");
	Данные = Новый Соответствие;
	// when
	Результат = ОбработкаДанных.НачатьЗапускОбработкиДанных(ОбработчикСобытия.Ссылка, Данные);
	// then
	Фреймворк.ПроверитьРавенство(Результат, Неопределено);
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, "В обрабатываемых данных отсутствует checkout_sha");

КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Процедура НачатьЗапускОбработкиДанныхWebhookОшибочныйТипДанных(Фреймворк) Экспорт
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ОбработкаДанных", "Ошибка");
	ОбработчикСобытия = Тест_ОбработчикиСобытийСервер.ДобавитьОбработчикСобытий("ЮнитТест1", "Webhook");
	Данные = Новый Массив;
	// when
	Результат = ОбработкаДанных.НачатьЗапускОбработкиДанных(ОбработчикСобытия.Ссылка, Данные);
	// then
	Фреймворк.ПроверитьРавенство(Результат, Неопределено);
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, "Неподдерживаемый формат обрабатываемых данных");

КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Процедура НачатьЗапускОбработкиДанныхЕстьАктивноеЗадание(Фреймворк) Экспорт
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ОбработкаДанных", "Предупреждение");
	ОбработчикСобытия = Тест_ОбработчикиСобытийСервер.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	// when
	Результат = ОбработкаДанных.НачатьЗапускОбработкиДанных(ОбработчикСобытия.Ссылка, "какой-то коммит...");
	Результат = ОбработкаДанных.НачатьЗапускОбработкиДанных(ОбработчикСобытия.Ссылка, "какой-то коммит...");
	// then
	Фреймворк.ПроверитьРавенство(Результат, Неопределено);
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, "[ какой-то коммит... ]: фоновое задание уже запущено");

КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Процедура НачатьЗапускОбработкиДанныхОшибкаЗапускаЗадания(Фреймворк) Экспорт
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ОбработкаДанных", "Ошибка");
	ОбработчикСобытия = Тест_ОбработчикиСобытийСервер.ДобавитьОбработчикСобытий("ЮнитТест1", "Webhook");
	Данные = Новый Соответствие;
	Данные.Вставить("checkout_sha", "какой-то коммит...");
	Данные.Вставить("error", Новый HTTPСоединение("localhost"));
	// when
	Результат = ОбработкаДанных.НачатьЗапускОбработкиДанных(ОбработчикСобытия.Ссылка, Данные);
	// then
	Фреймворк.ПроверитьРавенство(Результат, Неопределено);
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, "[ какой-то коммит... ]: запуск задания обработки данных");

КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Процедура НачатьЗапускОбработкиДанныхДанныеЗапроса(Фреймворк) Экспорт
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОчиститьРегистрыСведений();
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ОбработкаДанных.Окончание");
	ОбработчикСобытия = Тест_ОбработчикиСобытийСервер.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	// when
	Результат = ОбработкаДанных.НачатьЗапускОбработкиДанных(ОбработчикСобытия.Ссылка, "какой-то коммит...");
	// then
	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, "[ какой-то коммит... ]: нет данных для отправки");
	
КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Процедура НачатьЗапускОбработкиДанныхОтправляемыеДанныеПусто(Фреймворк) Экспорт
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОчиститьРегистрыСведений();
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ОбработкаДанных.Окончание");
	ОбработчикСобытия = Тест_ОбработчикиСобытийСервер.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	
	Данные = Новый Соответствие();
	Данные.Вставить("Ключ", "Значение");

	МенеджерЗаписи = РегистрыСведений.ДанныеЗапросов.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.ОбработчикСобытия = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.Ключ = "какой-то коммит...";
	МенеджерЗаписи.Данные = Новый ХранилищеЗначения(Данные);
	МенеджерЗаписи.Записать();	
	
	// when
	Результат = ОбработкаДанных.НачатьЗапускОбработкиДанных(ОбработчикСобытия.Ссылка, "какой-то коммит...");
	// then
	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, "[ какой-то коммит... ]: нет данных для отправки");
	
КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Процедура НачатьЗапускОбработкиДанныхРучнойЗапускНетЗаписанныхДанных(Фреймворк) Экспорт
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОчиститьРегистрыСведений();
	ОтборЖРПодготовкаДанных = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ПодготовкаДанных");
	ОтборЖРЗагрузкаДанныхЗапроса = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ЗагрузкаДанныхЗапросаИзБазыДанных", "Предупреждение");
	ОтборЖРЗагрузкаВнешнихФайлов = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ЗагрузкаВнешнихФайловИзБазыДанных", "Предупреждение");
	ОтборЖРОбработкаДанных = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ОбработкаДанных.Окончание");
	ОбработчикСобытия = Тест_ОбработчикиСобытийСервер.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	ПараметрыСобытия = Новый Структура();
	ПараметрыСобытия.Вставить( "ОбработчикСобытия", ОбработчикСобытия.Ссылка );
	ПараметрыСобытия.Вставить( "CheckoutSHA", "какой-то коммит..." );
	// when
	ОбработкаДанных.НачатьЗапускОбработкиДанных(ОбработчикСобытия.Ссылка, "какой-то коммит..." );
	// then
	ЖРПодготовкаДанных = СобытияЖурналаРегистрации(ОтборЖРПодготовкаДанных);
	ЖРЗагрузкаДанныхЗапроса = СобытияЖурналаРегистрации(ОтборЖРЗагрузкаДанныхЗапроса);
	ЖРЗагрузкаВнешнихФайлов = СобытияЖурналаРегистрации(ОтборЖРЗагрузкаВнешнихФайлов);
	ЖРОбработкаДанных = СобытияЖурналаРегистрации(ОтборЖРОбработкаДанных);
	Фреймворк.ПроверитьВхождение(ЖРПодготовкаДанных[0].Comment, "[ какой-то коммит... ]: загрузка ранее сохраненных данных");
	Фреймворк.ПроверитьВхождение(ЖРЗагрузкаДанныхЗапроса[0].Comment, "[ какой-то коммит... ]: [ЗагрузкаДанныхЗапросаИзБазыДанных]: операция не выполнена");
	Фреймворк.ПроверитьВхождение(ЖРЗагрузкаВнешнихФайлов[0].Comment, "[ какой-то коммит... ]: [ЗагрузкаВнешнихФайловИзБазыДанных]: операция не выполнена");
	Фреймворк.ПроверитьВхождение(ЖРОбработкаДанных[0].Comment, "[ какой-то коммит... ]: нет данных для отправки");
	
КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Процедура НачатьЗапускОбработкиДанныхРучнойЗапускЕстьЗаписанныеДанные(Фреймворк) Экспорт
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОчиститьРегистрыСведений();
	ОтборЖРПодготовкаДанных = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ПодготовкаДанных");
	ОтборЖРЗагрузкаДанныхЗапроса = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ЗагрузкаДанныхЗапросаИзБазыДанных");
	ОтборЖРЗагрузкаВнешнихФайлов = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ЗагрузкаВнешнихФайловИзБазыДанных");
	ОтборЖРОбработкаДанных = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ОбработкаДанных");
	ОтборЖРОбработкаДанныхОкончание = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ОбработкаДанных.Окончание");
	ОбработчикСобытия = Тест_ОбработчикиСобытийСервер.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	
	// ДанныеЗапроса
	ЭталонRouting = "/home/usr1cv8/test/expectation-routing.json";	
	Текст = Новый ЧтениеТекста(ЭталонRouting, КодировкаТекста.UTF8);
	JSON = Текст.Прочитать();
	JSON = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения());
	JSON = JSON.Получить("httpResponse").Получить("body").Получить("string");
	Settings = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения());
	
	Commit = Новый Соответствие;
	Commit.Вставить("id", "какой-то коммит...");
	Commit.Вставить("settings", Settings);
	Commits = Новый Массив;
	Commits.Добавить(Commit);
	ДанныеЗапроса = Новый Соответствие;
	ДанныеЗапроса.Вставить("commits", Commits);

	МенеджерЗаписи = РегистрыСведений.ДанныеЗапросов.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.ОбработчикСобытия = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.Ключ = "какой-то коммит...";
	МенеджерЗаписи.Данные = Новый ХранилищеЗначения(ДанныеЗапроса);
	МенеджерЗаписи.Записать();
	
	// ОтправляемыеДанные
	ОтправляемыеДанные = Новый ТаблицаЗначений();
	ОтправляемыеДанные.Колонки.Добавить( "ИмяФайла", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ПолноеИмяФайла", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ДвоичныеДанные", Новый ОписаниеТипов("ДвоичныеДанные") );
	ОтправляемыеДанные.Колонки.Добавить( "Операция", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ОписаниеОшибки", Новый ОписаниеТипов("Строка") );
	
	НоваяСтрока = ОтправляемыеДанные.Добавить();
	НоваяСтрока.CommitSHA = "какой-то коммит...";
	НоваяСтрока.ИмяФайла = "test1.epf";
	НоваяСтрока.ПолноеИмяФайла = "Каталог 1/test1.epf";
	НоваяСтрока.Операция = "modifed";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{some_json_4}");
	НоваяСтрока.ОписаниеОшибки = "";
	
	МенеджерЗаписи = РегистрыСведений.ВнешниеФайлы.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.ОбработчикСобытия = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.Ключ = "какой-то коммит...";
	МенеджерЗаписи.Данные = Новый ХранилищеЗначения(ОтправляемыеДанные);
	МенеджерЗаписи.Записать();
	
	ПараметрыСобытия = Новый Структура();
	ПараметрыСобытия.Вставить( "ОбработчикСобытия", ОбработчикСобытия.Ссылка );
	ПараметрыСобытия.Вставить( "CheckoutSHA", "какой-то коммит..." );
	
	// when
	//ОбработкаДанных.ОбработатьДанные(ПараметрыСобытия, Неопределено);
	ОбработкаДанных.НачатьЗапускОбработкиДанных(ОбработчикСобытия.Ссылка, "какой-то коммит..." );

	// then
	ЖРПодготовкаДанных = СобытияЖурналаРегистрации(ОтборЖРПодготовкаДанных);
	ЖРЗагрузкаДанныхЗапроса = СобытияЖурналаРегистрации(ОтборЖРЗагрузкаДанныхЗапроса);
	ЖРЗагрузкаВнешнихФайлов = СобытияЖурналаРегистрации(ОтборЖРЗагрузкаВнешнихФайлов);
	ЖРОбработкаДанных = СобытияЖурналаРегистрации(ОтборЖРОбработкаДанных);
	ЖРОбработкаДанныхОкончание = СобытияЖурналаРегистрации(ОтборЖРОбработкаДанныхОкончание);
	Фреймворк.ПроверитьВхождение(ЖРПодготовкаДанных[0].Comment, "[ какой-то коммит... ]: загрузка ранее сохраненных данных");
	Фреймворк.ПроверитьВхождение(ЖРЗагрузкаДанныхЗапроса[0].Comment, "[ какой-то коммит... ]: [ЗагрузкаДанныхЗапросаИзБазыДанных]: операция выполнена успешно");
	Фреймворк.ПроверитьВхождение(ЖРЗагрузкаВнешнихФайлов[0].Comment, "[ какой-то коммит... ]: [ЗагрузкаВнешнихФайловИзБазыДанных]: операция выполнена успешно");
	Фреймворк.ПроверитьВхождение(ЖРОбработкаДанных[0].Comment, "[ какой-то коммит... ]: отправляемых файлов: 1");
	Фреймворк.ПроверитьВхождение(ЖРОбработкаДанных[1].Comment, "[ какой-то коммит... ]: запущенных заданий: 1");
	Фреймворк.ПроверитьВхождение(ЖРОбработкаДанныхОкончание[0].Comment, "[ какой-то коммит... ]: обработка данных");
	
КонецПроцедуры

// @unit-test:dev
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Процедура НачатьЗапускОбработкиДанныхЕстьАктивноеЗаданиеЗапускаФайла(Фреймворк) Экспорт
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОчиститьРегистрыСведений();
	ОтборЖурналаРегистрацииИнформация = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ОбработкаДанных");
	ОтборЖурналаРегистрацииПредупреждение = ОтборЖурналаРегистрации("ОбработчикиСобытий.Core.ОбработкаДанных", "Предупреждение");
	ОбработчикСобытия = Тест_ОбработчикиСобытийСервер.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	
	// ДанныеЗапроса
	JSON = "{
			|  ""checkout_sha"": ""какой-то коммит..."",
			|  ""project"": {
			|    ""id"": 1,
			|    ""http_url"": ""http://www.example.com/root/external-epf.git""
			|  },
			|  ""commits"": [
			|    {
			|      ""id"": ""какой-то коммит..."",
			|      ""timestamp"": ""2020-07-21T09:22:31+00:00"",
			|      ""added"": [
			|        "".ext-epf.json"",
			|        ""src/Внешняя Обработка 1.xml"",
			|        ""test3.epf""
			|      ],
			|      ""modified"": [
			|        ""Каталог 2/test2.epf"",
			|        ""Каталог 1/test1.epf""
			|      ],
			|      ""removed"": [
			|
			|      ]
			|    }
			|  ]
			|}";
	ПараметрыПреобразования = Новый Структура();
	ПараметрыПреобразования.Вставить( "ПрочитатьВСоответствие", Истина );
	ПараметрыПреобразования.Вставить( "ИменаСвойствСоЗначениямиДата", "timestamp" );
	ДанныеЗапроса = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения(), , ПараметрыПреобразования);

	ЭталонRouting = "/home/usr1cv8/test/expectation-routing.json";	
	Текст = Новый ЧтениеТекста(ЭталонRouting, КодировкаТекста.UTF8);
	JSON = Текст.Прочитать();
	JSON = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения());
	JSON = JSON.Получить("httpResponse").Получить("body").Получить("string");
	Settings = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения());

	ДанныеЗапроса.Получить("commits")[0].Вставить("settings", Settings);

	МенеджерЗаписи = РегистрыСведений.ДанныеЗапросов.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.ОбработчикСобытия = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.Ключ = "какой-то коммит...";
	МенеджерЗаписи.Данные = Новый ХранилищеЗначения(ДанныеЗапроса);
	МенеджерЗаписи.Записать();
	
	// ОтправляемыеДанные
	ОтправляемыеДанные = Новый ТаблицаЗначений();
	ОтправляемыеДанные.Колонки.Добавить( "ПутьКФайлуRAW", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ИмяФайла", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ПолноеИмяФайла", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ДвоичныеДанные", Новый ОписаниеТипов("ДвоичныеДанные"));
	ОтправляемыеДанные.Колонки.Добавить( "Операция", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "Дата", Новый ОписаниеТипов("Дата") );
	ОтправляемыеДанные.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ОписаниеОшибки", Новый ОписаниеТипов("Строка"));
	
	НоваяСтрока = ОтправляемыеДанные.Добавить();
	НоваяСтрока.ПутьКФайлуRAW = "/api/v4/projects/1/repository/files/Каталог 2/test2.epf/raw?ref=какой-то коммит...";
	НоваяСтрока.ИмяФайла = "test2.epf";
	НоваяСтрока.ПолноеИмяФайла = "Каталог 2/test2.epf";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{some_json_3}");
	НоваяСтрока.Операция = "modifed";
	НоваяСтрока.Дата = Дата(2020, 07, 21, 09, 22, 31);	
	НоваяСтрока.CommitSHA = "какой-то коммит...";
	НоваяСтрока.ОписаниеОшибки = "";
	
	// Попытка отправить файл два раза и в каждом файле два адреса отправки
	НоваяСтрока = ОтправляемыеДанные.Добавить();
	НоваяСтрока.ПутьКФайлуRAW = "/api/v4/projects/1/repository/files/Каталог 2/test2.epf/raw?ref=какой-то коммит...";
	НоваяСтрока.ИмяФайла = "test2.epf";
	НоваяСтрока.ПолноеИмяФайла = "Каталог 2/test2.epf";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{some_json_3}");
	НоваяСтрока.Операция = "modifed";
	НоваяСтрока.Дата = Дата(2020, 07, 21, 09, 22, 31);	
	НоваяСтрока.CommitSHA = "какой-то коммит...";
	НоваяСтрока.ОписаниеОшибки = "";
	
	МенеджерЗаписи = РегистрыСведений.ВнешниеФайлы.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.ОбработчикСобытия = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.Ключ = "какой-то коммит...";
	МенеджерЗаписи.Данные = Новый ХранилищеЗначения(ОтправляемыеДанные);
	МенеджерЗаписи.Записать();
	
	// when
	Результат = ОбработкаДанных.НачатьЗапускОбработкиДанных(ОбработчикСобытия.Ссылка, "какой-то коммит...");
	
	// then
	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");
	ЖурналРегистрацииИнформация = СобытияЖурналаРегистрации(ОтборЖурналаРегистрацииИнформация);
	ЖурналРегистрацииПредупреждение = СобытияЖурналаРегистрации(ОтборЖурналаРегистрацииПредупреждение);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииИнформация[0].Comment, "[ какой-то коммит... ]: отправляемых файлов: 2");
	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииИнформация[1].Comment, "[ какой-то коммит... ]: запущенных заданий: 2");
	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииПредупреждение[0].Comment, "Ключ задания: какой-то коммит...|http://mock-server:1080/receiver3|test2.epf");
	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииПредупреждение[1].Comment, "Ключ задания: какой-то коммит...|http://mock-server:1080/receiver1|test2.epf");
	
КонецПроцедуры

#EndRegion

#Region Private

Процедура УдалитьВсеОбработчикиСобытий()
	
	Тест_ОбщийМодульСервер.СправочникиУдалитьВсеДанные("ОбработчикиСобытий");

КонецПроцедуры

Процедура ОчиститьРегистрыСведений()
	
	Тест_ОбщийМодульСервер.РегистрыСведенийУдалитьВсеДанные("ДанныеЗапросов,ВнешниеФайлы");

КонецПроцедуры

Функция ОтборЖурналаРегистрации(Событие, Уровень = "Информация")
	
	Возврат Тест_ОбщийМодульСервер.ОтборЖурналаРегистрации(Событие, Уровень);
	
КонецФункции

Функция СобытияЖурналаРегистрации(Отбор, Секунд = 2)
	
	Возврат Тест_ОбщийМодульСервер.СобытияЖурналаРегистрации(Отбор, Секунд);
	
КонецФункции

#EndRegion
