#Region Internal

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Procedure BeginDataProcessing(Фреймворк) Export
	
	EVENT_MESSAGE = НСтр("ru = 'ОбработчикиСобытий.Core.ОбработкаДанных';en = 'Webhooks.Core.DataProcessing'");
	GET_FILE_ERROR_MESSAGE = НСтр( "ru = 'ошибка получения файла:';en = 'failed to get the file:'" );
	FILES_SENT_MESSAGE = НСтр( "ru = 'отправляемых файлов: ';en = 'files sent: '" );
	RUNNING_JOBS_MESSAGE = НСтр( "ru = 'запущенных заданий: ';en = 'running jobs: '" );
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОчиститьРегистрыСведений();
	
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации(EVENT_MESSAGE);
	ОтборЖурналаРегистрацииПредупреждение = ОтборЖурналаРегистрации(EVENT_MESSAGE, "Предупреждение");
	
	ОбработчикСобытия = TestsWebhooksServer.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	
	// ДанныеЗапроса
	JSON = "{
			|  ""checkout_sha"": ""0123456789abcdef"",
			|  ""project"": {
			|    ""id"": 1,
			|    ""http_url"": ""http://www.example.com/root/external-epf.git""
			|  },
			|  ""commits"": [
			|    {
			|      ""id"": ""0123456789abcdef"",
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
	ДанныеЗапроса = HTTPConnector.JsonВОбъект(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения(), , ПараметрыПреобразования);

	ЭталонRouting = "/home/usr1cv8/test/expectation-routing.json";	
	Текст = Новый ЧтениеТекста(ЭталонRouting, КодировкаТекста.UTF8);
	JSON = Текст.Прочитать();
	JSON = HTTPConnector.JsonВОбъект(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());
	JSON = JSON.Получить("httpResponse").Получить("body").Получить("string");
	Settings = HTTPConnector.JsonВОбъект(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());
	
	ДанныеЗапроса.Получить("commits")[0].Вставить("settings", Settings);

	МенеджерЗаписи = РегистрыСведений.QueryData.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.CheckoutSHA = "0123456789abcdef";
	МенеджерЗаписи.Data = Новый ХранилищеЗначения(ДанныеЗапроса);
	МенеджерЗаписи.Записать();
	
	// ОтправляемыеДанные
	ОтправляемыеДанные = Новый ТаблицаЗначений();
	ОтправляемыеДанные.Колонки.Добавить( "RAWFilePath", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "FileName", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "FilePath", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "BinaryData", Новый ОписаниеТипов("BinaryData"));
	ОтправляемыеДанные.Колонки.Добавить( "Action", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "Date", Новый ОписаниеТипов("Date") );
	ОтправляемыеДанные.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ErrorInfo", Новый ОписаниеТипов("Строка"));
	
	НоваяСтрока = ОтправляемыеДанные.Добавить();
	НоваяСтрока.RAWFilePath = "/api/v4/projects/1/repository/files/Каталог 1/test1.epf/raw?ref=0123456789abcdef";
	НоваяСтрока.FileName = "";
	НоваяСтрока.FilePath = "Каталог 1/test1.epf";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{""name1"":""result1""}");
	НоваяСтрока.Action = "modifed";
	НоваяСтрока.Date = Date(2020, 07, 21, 09, 22, 31);
	НоваяСтрока.CommitSHA = "0123456789abcdef";
	НоваяСтрока.ErrorInfo = "тут какая-то ошибка";
	
	НоваяСтрока = ОтправляемыеДанные.Добавить();
	НоваяСтрока.RAWFilePath = "/api/v4/projects/1/repository/files/Каталог 2/test2.epf/raw?ref=0123456789abcdef";
	НоваяСтрока.FileName = "test2.epf";
	НоваяСтрока.FilePath = "Каталог 2/test2.epf";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_3}");
	НоваяСтрока.Action = "modifed";
	НоваяСтрока.Date = Date(2020, 07, 21, 09, 22, 31);	
	НоваяСтрока.CommitSHA = "0123456789abcdef";
	НоваяСтрока.ErrorInfo = "";
	
	МенеджерЗаписи = РегистрыСведений.RemoteFiles.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.CheckoutSHA = "0123456789abcdef";
	МенеджерЗаписи.Data = Новый ХранилищеЗначения(ОтправляемыеДанные);
	МенеджерЗаписи.Записать();
	
	// when
	Результат = DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, "0123456789abcdef");
	
	// then
	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, "[ 0123456789abcdef ]: " + FILES_SENT_MESSAGE + "1");
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[1].Comment, "[ 0123456789abcdef ]: " + RUNNING_JOBS_MESSAGE + "2");
	
	ЖурналРегистрацииПредупреждение = СобытияЖурналаРегистрации(ОтборЖурналаРегистрацииПредупреждение);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииПредупреждение[0].Comment, "[ 0123456789abcdef ]: " + GET_FILE_ERROR_MESSAGE);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииПредупреждение[0].Comment, "тут какая-то ошибка");

EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Procedure BeginDataProcessingManualStart(Фреймворк) Export
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОбработчикСобытия = TestsWebhooksServer.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	// when
	Результат = DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, "0123456789abcdef");
	// then
	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");

EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Procedure BeginDataProcessingHandleRequest(Фреймворк) Export
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОбработчикСобытия = TestsWebhooksServer.ДобавитьОбработчикСобытий("ЮнитТест1", "Webhook");
	Данные = Новый Соответствие;
	Данные.Вставить("checkout_sha", "0123456789abcdef");
	// when
	Результат = DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, Данные);
	// then
	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");

EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Procedure BeginDataProcessingHandleRequestWithoutCheckoutSHA(Фреймворк) Export
	
	EVENT_MESSAGE = НСтр("ru = 'ОбработчикиСобытий.Core.ОбработкаДанных';en = 'Webhooks.Core.DataProcessing'");
	CHECKOUT_SHA_MISSING_MESSAGE = НСтр("ru = 'отсутствует ""checkout_sha"".';en = '""checkout_sha"" is missing.'");
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации(EVENT_MESSAGE, "Ошибка");
	ОбработчикСобытия = TestsWebhooksServer.ДобавитьОбработчикСобытий("ЮнитТест1", "Webhook");
	Данные = Новый Соответствие;
	// when
	Результат = DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, Данные);
	// then
	Фреймворк.ПроверитьРавенство(Результат, Неопределено);
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, CHECKOUT_SHA_MISSING_MESSAGE);

EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Procedure BeginDataProcessingHandleRequestErrorDataType(Фреймворк) Export
	
	EVENT_MESSAGE = НСтр("ru = 'ОбработчикиСобытий.Core.ОбработкаДанных';en = 'Webhooks.Core.DataProcessing'");
	UNSUPPORTED_FORMAT_MESSAGE = НСтр("ru = 'неподдерживаемый формат данных.';en = 'unsupported data format.'");
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации(EVENT_MESSAGE, "Ошибка");
	ОбработчикСобытия = TestsWebhooksServer.ДобавитьОбработчикСобытий("ЮнитТест1", "Webhook");
	Данные = Новый Массив;
	// when
	Результат = DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, Данные);
	// then
	Фреймворк.ПроверитьРавенство(Результат, Неопределено);
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, UNSUPPORTED_FORMAT_MESSAGE);

EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Procedure BeginDataProcessingHandleRequestIsActiveBackgroundJob(Фреймворк) Export
	
	EVENT_MESSAGE = НСтр("ru = 'ОбработчикиСобытий.Core.ОбработкаДанных';en = 'Webhooks.Core.DataProcessing'");
	JOB_WAS_STARTED_MESSAGE = НСтр("ru = 'фоновое задание уже запущено.';en = 'background job is already running.'");	
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации(EVENT_MESSAGE, "Предупреждение");
	ОбработчикСобытия = TestsWebhooksServer.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	// when
	Результат = DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, "0123456789abcdef");
	Результат = DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, "0123456789abcdef");
	// then
	Фреймворк.ПроверитьРавенство(Результат, Неопределено);
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, "[ 0123456789abcdef ]: " + JOB_WAS_STARTED_MESSAGE);

EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Procedure BeginDataProcessingHandleRequestErrorStartBackgroundLob(Фреймворк) Export
	
	EVENT_MESSAGE = НСтр("ru = 'ОбработчикиСобытий.Core.ОбработкаДанных';en = 'Webhooks.Core.DataProcessing'");
	JOB_RUNNING_ERROR_MESSAGE = НСтр("ru = 'ошибка запуска задания обработки данных:';en = 'an error occurred while starting the job:'");	
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации(EVENT_MESSAGE, "Ошибка");
	ОбработчикСобытия = TestsWebhooksServer.ДобавитьОбработчикСобытий("ЮнитТест1", "Webhook");
	Данные = Новый Соответствие;
	Данные.Вставить("checkout_sha", "0123456789abcdef");
	Данные.Вставить("error", Новый HTTPСоединение("localhost"));
	// when
	Результат = DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, Данные);
	// then
	Фреймворк.ПроверитьРавенство(Результат, Неопределено);
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, "[ 0123456789abcdef ]: " + JOB_RUNNING_ERROR_MESSAGE);

EndProcedure

// @unit-test:dev
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Procedure BeginDataProcessingHandleRequestWithoutData(Фреймворк) Export
	
	EVENT_MESSAGE = НСтр("ru = 'ОбработчикиСобытий.Core.ОбработкаДанных.Окончание';en = 'Webhooks.Core.DataProcessing.End'");
	NO_DATA_MESSAGE = НСтр( "ru = 'нет данных для отправки.';en = 'no data to send.'" );
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОчиститьРегистрыСведений();
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации(EVENT_MESSAGE);
	ОбработчикСобытия = TestsWebhooksServer.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	// when
	Результат = DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, "0123456789abcdef");
	// then
	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, "[ 0123456789abcdef ]: " + NO_DATA_MESSAGE);
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Procedure BeginDataProcessingHandleRequestQueryDataEmpty(Фреймворк) Export
	
	EVENT_MESSAGE = НСтр("ru = 'ОбработчикиСобытий.Core.ОбработкаДанных.Окончание';en = 'Webhooks.Core.DataProcessing.End'");
	NO_DATA_MESSAGE = НСтр( "ru = 'нет данных для отправки.';en = 'no data to send.'" );
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОчиститьРегистрыСведений();
	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации(EVENT_MESSAGE);
	ОбработчикСобытия = TestsWebhooksServer.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	
	Данные = Новый Соответствие();
	Данные.Вставить("Ключ", "Значение");

	МенеджерЗаписи = РегистрыСведений.QueryData.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.CheckoutSHA = "0123456789abcdef";
	МенеджерЗаписи.Data = Новый ХранилищеЗначения(Данные);
	МенеджерЗаписи.Записать();	
	
	// when
	Результат = DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, "0123456789abcdef");
	// then
	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");
	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, "[ 0123456789abcdef ]: " + NO_DATA_MESSAGE);
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Procedure BeginDataProcessingManualStartWithoutSavedData(Фреймворк) Export
	
	EVENT_MESSAGE = НСтр("ru = 'ОбработчикиСобытий.Core.';en = 'Webhooks.Core.'");
	DATA_PREPARATION_MESSAGE = НСтр( "ru = 'ПодготовкаДанных';en = 'DataPreparation'" );
	DATA_PROCESSING_MESSAGE_END = НСтр( "ru = 'ОбработкаДанных.Окончание';en = 'DataProcessing.End'" );
	LOAD_QUERY_MESSAGE = НСтр( "ru = 'ЗагрузкаЗапросаИзБазыДанных';en = 'LoadingRequestFromDatabase'" );
	LOAD_FILES_MESSAGE = НСтр( "ru = 'ЗагрузкаВнешнихФайловИзБазыДанных';en = 'LoadingFilesFromDatabase'" );
	
	OPERATION_FAILED_MESSAGE = НСтр( "ru = 'операция не выполнена.';en = 'operation failed.'" );
	LOADING_DATA_MESSAGE = НСтр( "ru = 'загрузка ранее сохраненных данных.';en = 'loading previously saved data.'" );
	NO_DATA_MESSAGE = НСтр( "ru = 'нет данных для отправки.';en = 'no data to send.'" );
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОчиститьРегистрыСведений();
	ОтборЖРПодготовкаДанных = ОтборЖурналаРегистрации(EVENT_MESSAGE + DATA_PREPARATION_MESSAGE);
	ОтборЖРЗагрузкаДанныхЗапроса = ОтборЖурналаРегистрации(EVENT_MESSAGE + LOAD_QUERY_MESSAGE, "Предупреждение");
	ОтборЖРЗагрузкаВнешнихФайлов = ОтборЖурналаРегистрации(EVENT_MESSAGE + LOAD_FILES_MESSAGE, "Предупреждение");
	ОтборЖРОбработкаДанных = ОтборЖурналаРегистрации(EVENT_MESSAGE + DATA_PROCESSING_MESSAGE_END);
	ОбработчикСобытия = TestsWebhooksServer.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	ПараметрыСобытия = Новый Структура();
	ПараметрыСобытия.Вставить( "Webhook", ОбработчикСобытия.Ссылка );
	ПараметрыСобытия.Вставить( "CheckoutSHA", "0123456789abcdef" );
	// when
	DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, "0123456789abcdef" );
	// then
	ЖРПодготовкаДанных = СобытияЖурналаРегистрации(ОтборЖРПодготовкаДанных);
	ЖРЗагрузкаДанныхЗапроса = СобытияЖурналаРегистрации(ОтборЖРЗагрузкаДанныхЗапроса);
	ЖРЗагрузкаВнешнихФайлов = СобытияЖурналаРегистрации(ОтборЖРЗагрузкаВнешнихФайлов);
	ЖРОбработкаДанных = СобытияЖурналаРегистрации(ОтборЖРОбработкаДанных);
	Фреймворк.ПроверитьВхождение(ЖРПодготовкаДанных[0].Comment, "[ 0123456789abcdef ]: " + LOADING_DATA_MESSAGE);
	Фреймворк.ПроверитьВхождение(ЖРЗагрузкаДанныхЗапроса[0].Comment, "[ 0123456789abcdef ]: [" + LOAD_QUERY_MESSAGE + "]: " + OPERATION_FAILED_MESSAGE);
	Фреймворк.ПроверитьВхождение(ЖРЗагрузкаВнешнихФайлов[0].Comment, "[ 0123456789abcdef ]: [" + LOAD_FILES_MESSAGE + "]: " + OPERATION_FAILED_MESSAGE);
	Фреймворк.ПроверитьВхождение(ЖРОбработкаДанных[0].Comment, "[ 0123456789abcdef ]: " + NO_DATA_MESSAGE);
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Procedure BeginDataProcessingManualStartWithSavedData(Фреймворк) Export
	
	EVENT_MESSAGE = НСтр("ru = 'ОбработчикиСобытий.Core.';en = 'Webhooks.Core.'");
	DATA_PREPARATION_MESSAGE = НСтр( "ru = 'ПодготовкаДанных';en = 'DataPreparation'" );
	DATA_PROCESSING_EVENT_MESSAGE = НСтр( "ru = 'ОбработкаДанных';en = 'DataProcessing'" );
	DATA_PROCESSING_EVENT_MESSAGE_END = НСтр( "ru = 'ОбработкаДанных.Окончание';en = 'DataProcessing.End'" );
	LOAD_QUERY_MESSAGE = НСтр( "ru = 'ЗагрузкаЗапросаИзБазыДанных';en = 'LoadingRequestFromDatabase'" );
	LOAD_FILES_MESSAGE = НСтр( "ru = 'ЗагрузкаВнешнихФайловИзБазыДанных';en = 'LoadingFilesFromDatabase'" );

	DATA_PROCESSING_MESSAGE = НСтр( "ru = 'обработка данных...';en = 'data processing...'" );
	OPERATION_SUCCEEDED_MESSAGE = НСтр( "ru = 'операция выполнена успешно.';en = 'the operation was successful.'" );
	LOADING_DATA_MESSAGE = НСтр( "ru = 'загрузка ранее сохраненных данных.';en = 'loading previously saved data.'" );
	FILES_SENT_MESSAGE = НСтр( "ru = 'отправляемых файлов: ';en = 'files sent: '" );
	RUNNING_JOBS_MESSAGE = НСтр( "ru = 'запущенных заданий: ';en = 'running jobs: '" );

	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОчиститьРегистрыСведений();
	ОтборЖРПодготовкаДанных = ОтборЖурналаРегистрации(EVENT_MESSAGE + DATA_PREPARATION_MESSAGE);
	ОтборЖРЗагрузкаДанныхЗапроса = ОтборЖурналаРегистрации(EVENT_MESSAGE + LOAD_QUERY_MESSAGE);
	ОтборЖРЗагрузкаВнешнихФайлов = ОтборЖурналаРегистрации(EVENT_MESSAGE + LOAD_FILES_MESSAGE);
	ОтборЖРОбработкаДанных = ОтборЖурналаРегистрации(EVENT_MESSAGE + DATA_PROCESSING_EVENT_MESSAGE);
	ОтборЖРОбработкаДанныхОкончание = ОтборЖурналаРегистрации(EVENT_MESSAGE + DATA_PROCESSING_EVENT_MESSAGE_END);
	ОбработчикСобытия = TestsWebhooksServer.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	
	// ДанныеЗапроса
	ЭталонRouting = "/home/usr1cv8/test/expectation-routing.json";	
	Текст = Новый ЧтениеТекста(ЭталонRouting, КодировкаТекста.UTF8);
	JSON = Текст.Прочитать();
	JSON = HTTPConnector.JsonВОбъект(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());
	JSON = JSON.Получить("httpResponse").Получить("body").Получить("string");
	Settings = HTTPConnector.JsonВОбъект(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());
	
	Commit = Новый Соответствие;
	Commit.Вставить("id", "0123456789abcdef");
	Commit.Вставить("settings", Settings);
	Commits = Новый Массив;
	Commits.Добавить(Commit);
	ДанныеЗапроса = Новый Соответствие;
	ДанныеЗапроса.Вставить("commits", Commits);

	МенеджерЗаписи = РегистрыСведений.QueryData.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.CheckoutSHA = "0123456789abcdef";
	МенеджерЗаписи.Data = Новый ХранилищеЗначения(ДанныеЗапроса);
	МенеджерЗаписи.Записать();
	
	// ОтправляемыеДанные
	ОтправляемыеДанные = Новый ТаблицаЗначений();
	ОтправляемыеДанные.Колонки.Добавить( "FileName", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "FilePath", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "BinaryData", Новый ОписаниеТипов("BinaryData") );
	ОтправляемыеДанные.Колонки.Добавить( "Action", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ErrorInfo", Новый ОписаниеТипов("Строка") );
	
	НоваяСтрока = ОтправляемыеДанные.Добавить();
	НоваяСтрока.CommitSHA = "0123456789abcdef";
	НоваяСтрока.FileName = "test1.epf";
	НоваяСтрока.FilePath = "Каталог 1/test1.epf";
	НоваяСтрока.Action = "modifed";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_4}");
	НоваяСтрока.ErrorInfo = "";
	
	МенеджерЗаписи = РегистрыСведений.RemoteFiles.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.CheckoutSHA = "0123456789abcdef";
	МенеджерЗаписи.Data = Новый ХранилищеЗначения(ОтправляемыеДанные);
	МенеджерЗаписи.Записать();
	
	ПараметрыСобытия = Новый Структура();
	ПараметрыСобытия.Вставить( "Webhook", ОбработчикСобытия.Ссылка );
	ПараметрыСобытия.Вставить( "CheckoutSHA", "0123456789abcdef" );
	
	// when
	DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, "0123456789abcdef" );

	// then
	ЖРПодготовкаДанных = СобытияЖурналаРегистрации(ОтборЖРПодготовкаДанных);
	ЖРЗагрузкаДанныхЗапроса = СобытияЖурналаРегистрации(ОтборЖРЗагрузкаДанныхЗапроса);
	ЖРЗагрузкаВнешнихФайлов = СобытияЖурналаРегистрации(ОтборЖРЗагрузкаВнешнихФайлов);
	ЖРОбработкаДанных = СобытияЖурналаРегистрации(ОтборЖРОбработкаДанных);
	ЖРОбработкаДанныхОкончание = СобытияЖурналаРегистрации(ОтборЖРОбработкаДанныхОкончание);
	Фреймворк.ПроверитьВхождение(ЖРПодготовкаДанных[0].Comment, "[ 0123456789abcdef ]: " + LOADING_DATA_MESSAGE);
	Фреймворк.ПроверитьВхождение(ЖРЗагрузкаДанныхЗапроса[0].Comment, "[ 0123456789abcdef ]: [" + LOAD_QUERY_MESSAGE + "]: " + OPERATION_SUCCEEDED_MESSAGE);
	Фреймворк.ПроверитьВхождение(ЖРЗагрузкаВнешнихФайлов[0].Comment, "[ 0123456789abcdef ]: [" + LOAD_FILES_MESSAGE + "]: " + OPERATION_SUCCEEDED_MESSAGE);
	Фреймворк.ПроверитьВхождение(ЖРОбработкаДанных[0].Comment, "[ 0123456789abcdef ]: " + FILES_SENT_MESSAGE + "1");
	Фреймворк.ПроверитьВхождение(ЖРОбработкаДанных[1].Comment, "[ 0123456789abcdef ]: " + RUNNING_JOBS_MESSAGE + "1");
	Фреймворк.ПроверитьВхождение(ЖРОбработкаДанныхОкончание[0].Comment, "[ 0123456789abcdef ]: " + DATA_PROCESSING_MESSAGE);
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
Procedure BeginDataProcessingManualStartFileSendingBackgroundJob(Фреймворк) Export
	
	EVENT_MESSAGE = НСтр("ru = 'ОбработчикиСобытий.Core.ОбработкаДанных';en = 'Webhooks.Core.DataProcessing'");
	
	FILES_SENT_MESSAGE = НСтр( "ru = 'отправляемых файлов: ';en = 'files sent: '" );
	RUNNING_JOBS_MESSAGE = НСтр( "ru = 'запущенных заданий: ';en = 'running jobs: '" );
	KEY_MESSAGE = НСтр( "ru = 'Ключ: ';en = 'Key: '" );
	
	// given
	УдалитьВсеОбработчикиСобытий();
	ОчиститьРегистрыСведений();
	ОтборЖурналаРегистрацииИнформация = ОтборЖурналаРегистрации(EVENT_MESSAGE);
	ОтборЖурналаРегистрацииПредупреждение = ОтборЖурналаРегистрации(EVENT_MESSAGE, "Предупреждение");
	ОбработчикСобытия = TestsWebhooksServer.ДобавитьОбработчикСобытий("ЮнитТест1", "РучнойЗапуск");
	
	// ДанныеЗапроса
	JSON = "{
			|  ""checkout_sha"": ""0123456789abcdef"",
			|  ""project"": {
			|    ""id"": 1,
			|    ""http_url"": ""http://www.example.com/root/external-epf.git""
			|  },
			|  ""commits"": [
			|    {
			|      ""id"": ""0123456789abcdef"",
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
	ДанныеЗапроса = HTTPConnector.JsonВОбъект(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения(), , ПараметрыПреобразования);

	ЭталонRouting = "/home/usr1cv8/test/expectation-routing.json";	
	Текст = Новый ЧтениеТекста(ЭталонRouting, КодировкаТекста.UTF8);
	JSON = Текст.Прочитать();
	JSON = HTTPConnector.JsonВОбъект(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());
	JSON = JSON.Получить("httpResponse").Получить("body").Получить("string");
	Settings = HTTPConnector.JsonВОбъект(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());

	ДанныеЗапроса.Получить("commits")[0].Вставить("settings", Settings);

	МенеджерЗаписи = РегистрыСведений.QueryData.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.CheckoutSHA = "0123456789abcdef";
	МенеджерЗаписи.Data = Новый ХранилищеЗначения(ДанныеЗапроса);
	МенеджерЗаписи.Записать();
	
	// ОтправляемыеДанные
	ОтправляемыеДанные = Новый ТаблицаЗначений();
	ОтправляемыеДанные.Колонки.Добавить( "RAWFilePath", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "FileName", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "FilePath", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "BinaryData", Новый ОписаниеТипов("BinaryData"));
	ОтправляемыеДанные.Колонки.Добавить( "Action", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "Date", Новый ОписаниеТипов("Date") );
	ОтправляемыеДанные.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	ОтправляемыеДанные.Колонки.Добавить( "ErrorInfo", Новый ОписаниеТипов("Строка"));
	
	НоваяСтрока = ОтправляемыеДанные.Добавить();
	НоваяСтрока.RAWFilePath = "/api/v4/projects/1/repository/files/Каталог 2/test2.epf/raw?ref=0123456789abcdef";
	НоваяСтрока.FileName = "test2.epf";
	НоваяСтрока.FilePath = "Каталог 2/test2.epf";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_3}");
	НоваяСтрока.Action = "modifed";
	НоваяСтрока.Date = Date(2020, 07, 21, 09, 22, 31);	
	НоваяСтрока.CommitSHA = "0123456789abcdef";
	НоваяСтрока.ErrorInfo = "";
	
	// Попытка отправить файл два раза и в каждом файле два адреса отправки
	НоваяСтрока = ОтправляемыеДанные.Добавить();
	НоваяСтрока.RAWFilePath = "/api/v4/projects/1/repository/files/Каталог 2/test2.epf/raw?ref=0123456789abcdef";
	НоваяСтрока.FileName = "test2.epf";
	НоваяСтрока.FilePath = "Каталог 2/test2.epf";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_3}");
	НоваяСтрока.Action = "modifed";
	НоваяСтрока.Date = Date(2020, 07, 21, 09, 22, 31);	
	НоваяСтрока.CommitSHA = "0123456789abcdef";
	НоваяСтрока.ErrorInfo = "";
	
	МенеджерЗаписи = РегистрыСведений.RemoteFiles.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
	МенеджерЗаписи.CheckoutSHA = "0123456789abcdef";
	МенеджерЗаписи.Data = Новый ХранилищеЗначения(ОтправляемыеДанные);
	МенеджерЗаписи.Записать();
	
	// when
	Результат = DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, "0123456789abcdef");
	
	// then
	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");
	ЖурналРегистрацииИнформация = СобытияЖурналаРегистрации(ОтборЖурналаРегистрацииИнформация);
	ЖурналРегистрацииПредупреждение = СобытияЖурналаРегистрации(ОтборЖурналаРегистрацииПредупреждение);
	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииИнформация[0].Comment, "[ 0123456789abcdef ]: " + FILES_SENT_MESSAGE + "2");
	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииИнформация[1].Comment, "[ 0123456789abcdef ]: " + RUNNING_JOBS_MESSAGE + "2");
	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииПредупреждение[0].Comment, KEY_MESSAGE + "0123456789abcdef|http://mock-server:1080/receiver3|test2.epf");
	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииПредупреждение[1].Comment, KEY_MESSAGE + "0123456789abcdef|http://mock-server:1080/receiver1|test2.epf");
	
EndProcedure

#EndRegion

#Region Private

Procedure УдалитьВсеОбработчикиСобытий()
	
	TestsCommonUseServer.СправочникиУдалитьВсеДанные("Webhooks");

EndProcedure

Procedure ОчиститьРегистрыСведений()
	
	TestsCommonUseServer.РегистрыСведенийУдалитьВсеДанные("QueryData,RemoteFiles");

EndProcedure

Function ОтборЖурналаРегистрации(Событие, Уровень = "Информация")
	
	Возврат TestsCommonUseServer.ОтборЖурналаРегистрации(Событие, Уровень);
	
EndFunction

Function СобытияЖурналаРегистрации(Отбор, Секунд = 2)
	
	Возврат TestsCommonUseServer.СобытияЖурналаРегистрации(Отбор, Секунд);
	
EndFunction

#EndRegion
