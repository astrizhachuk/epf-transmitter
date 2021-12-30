#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartRunSuccess(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	ExternalRequestHandler = NewExternalRequestHandler("Test", "http://" + TIME);
	Data = New Map;
	Data.Insert("checkout_sha", TIME);
	
	// when
	Result = DataProcessing.Start(ExternalRequestHandler.Ref, Data);
	
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Active);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartException(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	ExternalRequestHandler = NewExternalRequestHandler("Test", "http://" + TIME);	
	Data = New Map;	
	Data.Insert("checkout_sha", TIME);
	Data.Insert("error", New HTTPConnection("localhost"));	

	// when
	Try
		DataProcessing.Start(ExternalRequestHandler.Ref, Data);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, "(Execute)");
	EndTry;

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartExceptionActiveJob(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	ExternalRequestHandler = NewExternalRequestHandler("Test", "http://" + TIME);
	Data = New Map;
	Data.Insert("checkout_sha", TIME);
	
	// when
	Result1 = DataProcessing.Start(ExternalRequestHandler.Ref, Data);
	Try
		DataProcessing.Start(ExternalRequestHandler.Ref, Data);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, "(Execute)");
	EndTry;	

	Framework.AssertTrue(Result1.State = BackgroundJobState.Active);	

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartSaveData(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	InformationRegisterCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");

	URL = "http://" + TIME;	
	ExternalRequestHandler = NewExternalRequestHandler("Test", URL);

	Data = New Map;
	Data.Insert("checkout_sha", TIME);
	Project = New Map;
	Project.Insert("id", 1);
	Project.Insert("web_url", URL);		
	Data.Insert("project", Project);
	Data.Insert("commits", New Map);
	
	// files to send to endpoints
	Files = NewFilesToSend();
	NewFile = Files.Add();
	NewFile.RAWFilePath = "/api/v4/projects/1/repository/files/Каталог 2/test2.epf/raw?ref=0123456789abcdef";
	NewFile.FileName = "test2.epf";
	NewFile.FilePath = "Каталог 2/test2.epf";
	NewFile.BinaryData = GetBinaryDataFromString("{some_json_3}");
	NewFile.Action = "modifed";
	NewFile.Date = Date(2020, 07, 21, 09, 22, 31);	
	NewFile.CommitSHA = "0123456789abcdef";
	NewFile.ErrorInfo = "";
	
	// when
	Result = DataProcessing.Start(ExternalRequestHandler.Ref, Data, Files)
							.WaitForExecutionCompletion(5);
	Filter = New Structure();
	Filter.Insert("Webhook", ExternalRequestHandler.Ref);
	Filter.Insert("CheckoutSHA", TIME);
	QueryData = InformationRegisters.QueryData.Get(Filter);
	Files = InformationRegisters.RemoteFiles.Get(Filter);
		
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Completed);
	Framework.AssertEqual(QueryData.Data.Get().Get("checkout_sha"), TIME);
	Framework.AssertEqual(Files.Data.Get()[0]["FileName"], "test2.epf");
		
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartProjectDataNotFound(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	ExternalRequestHandler = NewExternalRequestHandler("Test", "http://" + TIME);
	Data = New Map;
	Data.Insert("checkout_sha", TIME);
	Files = Undefined;
	
	// when
	Result = DataProcessing.Start(ExternalRequestHandler.Ref, Data, Files)
							.WaitForExecutionCompletion(5);

	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Failed);
	Framework.AssertStringContains(Result.ErrorInfo.Description, Logs.Messages().NO_POJECT_DESCRIPTION);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartCommitsNotFound(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	InformationRegisterCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	URL = "http://" + TIME;
	ExternalRequestHandler = NewExternalRequestHandler("Test", URL);
	
	Data = New Map;
	Data.Insert("checkout_sha", TIME);
	Project = New Map;
	Project.Insert("id", 1);
	Project.Insert("web_url", URL);		
	Data.Insert("project", Project);

	// when
	Result = DataProcessing.Start(ExternalRequestHandler.Ref, Data)
							.WaitForExecutionCompletion(5);
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Failed);
	Framework.AssertStringContains(Result.ErrorInfo.Description, Logs.Messages().NO_COMMITS);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartDownloadFromRemoteVCSErrors(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	URL = "http://" + TIME;
	ExternalRequestHandler = NewExternalRequestHandler("Test", URL);
	
	Data = New Map;
	Data.Insert("checkout_sha", TIME);
	Project = New Map;
	Project.Insert("id", 1);
	Project.Insert("web_url", URL);		
	Data.Insert("project", Project);
	Files = NewFiles("path/file 1.json|path/file 2.epf|path/file 3.ERF");
	Commits = New Array;
	Commits.Add(NewCommit("commit",
						Date(2020, 07, 21, 09, 22, 31),
						New Array,
						Files,
						New Array));
	Data.Insert("commits", Commits);

	// when
	Result = DataProcessing.Start(ExternalRequestHandler.Ref, Data)
							.WaitForExecutionCompletion(60);
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Completed);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ManualRunSuccess(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	InformationRegisterCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	ExternalRequestHandler = NewExternalRequestHandler("Test", "http://" + TIME);
	Data = New Map;
	Data.Insert("checkout_sha", TIME);
	
	AddRecord("QueryData", ExternalRequestHandler, TIME, Data);
	AddRecord("RemoteFiles", ExternalRequestHandler, TIME, New ValueTable());	

	// when
	Result = DataProcessing.Manual(ExternalRequestHandler.Ref, TIME);
	
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Active);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ManualRunErrorLoadDataRequestBodyNotFound(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	InformationRegisterCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	ExternalRequestHandler = NewExternalRequestHandler("Test", "http://" + TIME);
	CheckoutSHA = TIME;
	FilesToSend = NewFilesToSend();
	NewFile = FilesToSend.Add();
	NewFile.FileName = "test2.epf";
	AddRecord("RemoteFiles", ExternalRequestHandler, CheckoutSHA, FilesToSend);

	// when
	Result = DataProcessing.Manual(ExternalRequestHandler.Ref, "fake");
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ManualRunErrorLoadDataRemoteFilesNotFound(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	InformationRegisterCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	ExternalRequestHandler = NewExternalRequestHandler("Test", "http://" + TIME);
	CheckoutSHA = TIME;
	Data = New Map;
	Data.Insert("checkout_sha", TIME);
	AddRecord("QueryData", ExternalRequestHandler, CheckoutSHA, Data);

	// when
	Result = DataProcessing.Manual(ExternalRequestHandler.Ref, "fake");
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

// TODO потенциально дублирует тест ManualSuccess

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ManualLoadData(Framework) Export

	// given
	ExternalRequestHandlersCleanUp();
	InformationRegisterCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	ExternalRequestHandler = NewExternalRequestHandler("Test", "http://" + TIME);
	JSON = UtilsServer.GetJSON("/test/requests/push.json");
	Object = HTTPConnector.JsonToObject(JSON);
	CheckoutSHA = Object.Get("checkout_sha");	
	
	AddRecord("QueryData", ExternalRequestHandler, CheckoutSHA, Object);
	
	// files to send to endpoints
	FilesToSend = NewFilesToSend();
	NewFile = FilesToSend.Add();
	NewFile.RAWFilePath = "/api/v4/projects/1/repository/files/Каталог 2/test2.epf/raw?ref=0123456789abcdef";
	NewFile.FileName = "test2.epf";
	NewFile.FilePath = "Каталог 2/test2.epf";
	NewFile.BinaryData = GetBinaryDataFromString("{some_json_3}");
	NewFile.Action = "modifed";
	NewFile.Date = Date(2020, 07, 21, 09, 22, 31);	
	NewFile.CommitSHA = "0123456789abcdef";
	NewFile.ErrorInfo = "";
	
	AddRecord("RemoteFiles", ExternalRequestHandler, CheckoutSHA, FilesToSend);	
	
	// when
	Result = DataProcessing.Manual(ExternalRequestHandler.Ref, CheckoutSHA);
	
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Active);

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure RunLogs(Framework) Export
	
EndProcedure

#EndRegion

#Region Private

Function NewFiles(Files)

	Return UtilsServer.SplitString(Files);
	
EndFunction

#Region Data

Procedure ExternalRequestHandlersCleanUp()
	
	UtilsServer.CatalogCleanUp("ExternalRequestHandlers");

EndProcedure

Procedure InformationRegisterCleanUp()
	
	UtilsServer.InformationRegisterCleanUp("QueryData,RemoteFiles");

EndProcedure

Function NewExternalRequestHandler(Val Name, Val ProjectURL)

	Return UtilsServer.NewExternalRequestHandler(Name, ProjectURL, "empty");

EndFunction

Procedure AddRecord(Name, Handler, CheckoutSHA, Data)

	RecordManager = InformationRegisters[ Name ].CreateRecordManager();
	RecordManager.Webhook = Handler.Ref;
	RecordManager.CheckoutSHA = CheckoutSHA;
	RecordManager.Data = New ValueStorage(Data);
	RecordManager.Write();
	
EndProcedure

Function NewFilesToSend()
	
	Result = New ValueTable();
	Result.Columns.Add( "RAWFilePath", New TypeDescription("String") );
	Result.Columns.Add( "FileName", New TypeDescription("String") );
	Result.Columns.Add( "FilePath", New TypeDescription("String") );
	Result.Columns.Add( "BinaryData", New TypeDescription("BinaryData"));
	Result.Columns.Add( "Action", New TypeDescription("String") );
	Result.Columns.Add( "Date", New TypeDescription("Date") );
	Result.Columns.Add( "CommitSHA", New TypeDescription("String") );
	Result.Columns.Add( "ErrorInfo", New TypeDescription("String")); //TODO это не текст, а объект, чекнуть объявления
	
	Return Result;
	
EndFunction

#Region Request

Function NewCommit(Id, Date, Added, Modified, Removed)
	
	Return UtilsServer.NewCommit(Id, Date, Added, Modified, Removed);
	
EndFunction

#EndRegion

#EndRegion

#EndRegion


//// @unit-test
//// Параметры:
//// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//Procedure BeginDataProcessing(Фреймворк) Export
//	
//	EVENT_MESSAGE = НСтр("ru = 'ОбработчикиСобытий.Core.ОбработкаДанных';en = 'Webhooks.Core.DataProcessing'");
//	GET_FILE_ERROR_MESSAGE = НСтр( "ru = 'ошибка получения файла:';en = 'failed to get the file:'" );
//	FILES_SENT_MESSAGE = НСтр( "ru = 'отправляемых файлов: ';en = 'files sent: '" );
//	RUNNING_JOBS_MESSAGE = НСтр( "ru = 'запущенных заданий: ';en = 'running jobs: '" );
//	
//	// given
//	ExternalRequestHandlersCleanUp();
//	InformationRegisterCleanUp();
//	
//	ОтборЖурналаРегистрации = ОтборЖурналаРегистрации(EVENT_MESSAGE);
//	ОтборЖурналаРегистрацииПредупреждение = ОтборЖурналаРегистрации(EVENT_MESSAGE, "Предупреждение");
//	
//	ОбработчикСобытия = TestsExternalRequestsServer.NewExternalRequestHandler("ЮнитТест1", "РучнойЗапуск");
//	
//	// ДанныеЗапроса
//	JSON = "{
//			|  ""checkout_sha"": ""0123456789abcdef"",
//			|  ""project"": {
//			|    ""id"": 1,
//			|    ""http_url"": ""http://www.example.com/root/external-epf.git""
//			|  },
//			|  ""commits"": [
//			|    {
//			|      ""id"": ""0123456789abcdef"",
//			|      ""timestamp"": ""2020-07-21T09:22:31+00:00"",
//			|      ""added"": [
//			|        "".ext-epf.json"",
//			|        ""src/Внешняя Обработка 1.xml"",
//			|        ""test3.epf""
//			|      ],
//			|      ""modified"": [
//			|        ""Каталог 2/test2.epf"",
//			|        ""Каталог 1/test1.epf""
//			|      ],
//			|      ""removed"": [
//			|
//			|      ]
//			|    }
//			|  ]
//			|}";
//				
//	ПараметрыПреобразования = Новый Структура();
//	ПараметрыПреобразования.Вставить( "ReadToMap", Истина );
//	ПараметрыПреобразования.Вставить( "PropertiesWithDateValuesNames", "timestamp" );
//	ДанныеЗапроса = HTTPConnector.JsonToObject(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения(), , ПараметрыПреобразования);
//
//	ЭталонRouting = "/tmp/expectations/routing.json";	
//	Текст = Новый ЧтениеТекста(ЭталонRouting, КодировкаТекста.UTF8);
//	JSON = Текст.Прочитать();
//	JSON = HTTPConnector.JsonToObject(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());
//	JSON = JSON.Получить("httpResponse").Получить("body").Получить("string");
//	Settings = HTTPConnector.JsonToObject(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());
//	
//	ДанныеЗапроса.Получить("commits")[0].Вставить("settings", Settings);
//
//	МенеджерЗаписи = РегистрыСведений.QueryData.СоздатьМенеджерЗаписи();
//	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
//	МенеджерЗаписи.CheckoutSHA = "0123456789abcdef";
//	МенеджерЗаписи.Data = Новый ХранилищеЗначения(ДанныеЗапроса);
//	МенеджерЗаписи.Записать();
//	
//	// ОтправляемыеДанные
//	ОтправляемыеДанные = Новый ТаблицаЗначений();
//	ОтправляемыеДанные.Колонки.Добавить( "RAWFilePath", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "FileName", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "FilePath", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "BinaryData", Новый ОписаниеТипов("BinaryData"));
//	ОтправляемыеДанные.Колонки.Добавить( "Action", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "Date", Новый ОписаниеТипов("Date") );
//	ОтправляемыеДанные.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "ErrorInfo", Новый ОписаниеТипов("Строка")); //TODO это не текст, а объект, чекнуть объявления
//	
//	НоваяСтрока = ОтправляемыеДанные.Добавить();
//	НоваяСтрока.RAWFilePath = "/api/v4/projects/1/repository/files/Каталог 1/test1.epf/raw?ref=0123456789abcdef";
//	НоваяСтрока.FileName = "";
//	НоваяСтрока.FilePath = "Каталог 1/test1.epf";
//	НоваяСтрока.BinaryData = GetBinaryDataFromString("{""name1"":""result1""}");
//	НоваяСтрока.Action = "modifed";
//	НоваяСтрока.Date = Date(2020, 07, 21, 09, 22, 31);
//	НоваяСтрока.CommitSHA = "0123456789abcdef";
//	НоваяСтрока.ErrorInfo = "тут какая-то ошибка";
//	
//	НоваяСтрока = ОтправляемыеДанные.Добавить();
//	НоваяСтрока.RAWFilePath = "/api/v4/projects/1/repository/files/Каталог 2/test2.epf/raw?ref=0123456789abcdef";
//	НоваяСтрока.FileName = "test2.epf";
//	НоваяСтрока.FilePath = "Каталог 2/test2.epf";
//	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_3}");
//	НоваяСтрока.Action = "modifed";
//	НоваяСтрока.Date = Date(2020, 07, 21, 09, 22, 31);	
//	НоваяСтрока.CommitSHA = "0123456789abcdef";
//	НоваяСтрока.ErrorInfo = "";
//	
//	МенеджерЗаписи = РегистрыСведений.RemoteFiles.СоздатьМенеджерЗаписи();
//	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
//	МенеджерЗаписи.CheckoutSHA = "0123456789abcdef";
//	МенеджерЗаписи.Data = Новый ХранилищеЗначения(ОтправляемыеДанные);
//	МенеджерЗаписи.Записать();
//	
//	// when
//	Результат = DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, "0123456789abcdef");
//	
//	// then
//	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");
//	ЖурналРегистрации = СобытияЖурналаРегистрации(ОтборЖурналаРегистрации);
//	
//	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[0].Comment, "[ 0123456789abcdef ]: " + FILES_SENT_MESSAGE + "1");
//	Фреймворк.ПроверитьВхождение(ЖурналРегистрации[1].Comment, "[ 0123456789abcdef ]: " + RUNNING_JOBS_MESSAGE + "2");
//	
//	ЖурналРегистрацииПредупреждение = СобытияЖурналаРегистрации(ОтборЖурналаРегистрацииПредупреждение);
//	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииПредупреждение[0].Comment, "[ 0123456789abcdef ]: " + GET_FILE_ERROR_MESSAGE);
//	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииПредупреждение[0].Comment, "тут какая-то ошибка");
//
//EndProcedure
//
//
//
//
//
//// @unit-test
//// Параметры:
//// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//Procedure BeginDataProcessingManualStartWithSavedData(Фреймворк) Export
//	
//	EVENT_MESSAGE = НСтр("ru = 'ОбработчикиСобытий.Core.';en = 'Webhooks.Core.'");
//	DATA_PREPARATION_MESSAGE = НСтр( "ru = 'ПодготовкаДанных';en = 'DataPreparation'" );
//	DATA_PROCESSING_EVENT_MESSAGE = НСтр( "ru = 'ОбработкаДанных';en = 'DataProcessing'" );
//	DATA_PROCESSING_EVENT_MESSAGE_END = НСтр( "ru = 'ОбработкаДанных.Окончание';en = 'DataProcessing.End'" );
//	LOAD_QUERY_MESSAGE = НСтр( "ru = 'ЗагрузкаЗапросаИзБазыДанных';en = 'LoadingRequestFromDatabase'" );
//	LOAD_FILES_MESSAGE = НСтр( "ru = 'ЗагрузкаВнешнихФайловИзБазыДанных';en = 'LoadingFilesFromDatabase'" );
//
//	DATA_PROCESSING_MESSAGE = НСтр( "ru = 'обработка данных...';en = 'data processing...'" );
//	OPERATION_SUCCEEDED_MESSAGE = НСтр( "ru = 'операция выполнена успешно.';en = 'the operation was successful.'" );
//	LOADING_DATA_MESSAGE = НСтр( "ru = 'загрузка ранее сохраненных данных.';en = 'loading previously saved data.'" );
//	FILES_SENT_MESSAGE = НСтр( "ru = 'отправляемых файлов: ';en = 'files sent: '" );
//	RUNNING_JOBS_MESSAGE = НСтр( "ru = 'запущенных заданий: ';en = 'running jobs: '" );
//
//	
//	// given
//	ExternalRequestHandlersCleanUp();
//	InformationRegisterCleanUp();
//	ОтборЖРПодготовкаДанных = ОтборЖурналаРегистрации(EVENT_MESSAGE + DATA_PREPARATION_MESSAGE);
//	ОтборЖРЗагрузкаДанныхЗапроса = ОтборЖурналаРегистрации(EVENT_MESSAGE + LOAD_QUERY_MESSAGE);
//	ОтборЖРЗагрузкаВнешнихФайлов = ОтборЖурналаРегистрации(EVENT_MESSAGE + LOAD_FILES_MESSAGE);
//	ОтборЖРОбработкаДанных = ОтборЖурналаРегистрации(EVENT_MESSAGE + DATA_PROCESSING_EVENT_MESSAGE);
//	ОтборЖРОбработкаДанныхОкончание = ОтборЖурналаРегистрации(EVENT_MESSAGE + DATA_PROCESSING_EVENT_MESSAGE_END);
//	ОбработчикСобытия = TestsExternalRequestsServer.NewExternalRequestHandler("ЮнитТест1", "РучнойЗапуск");
//	
//	// ДанныеЗапроса
//	ЭталонRouting = "/tmp/expectations/routing.json";	
//	Текст = Новый ЧтениеТекста(ЭталонRouting, КодировкаТекста.UTF8);
//	JSON = Текст.Прочитать();
//	JSON = HTTPConnector.JsonToObject(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());
//	JSON = JSON.Получить("httpResponse").Получить("body").Получить("string");
//	Settings = HTTPConnector.JsonToObject(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());
//	
//	Commit = Новый Соответствие;
//	Commit.Вставить("id", "0123456789abcdef");
//	Commit.Вставить("settings", Settings);
//	Commits = Новый Массив;
//	Commits.Добавить(Commit);
//	ДанныеЗапроса = Новый Соответствие;
//	ДанныеЗапроса.Вставить("commits", Commits);
//
//	МенеджерЗаписи = РегистрыСведений.QueryData.СоздатьМенеджерЗаписи();
//	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
//	МенеджерЗаписи.CheckoutSHA = "0123456789abcdef";
//	МенеджерЗаписи.Data = Новый ХранилищеЗначения(ДанныеЗапроса);
//	МенеджерЗаписи.Записать();
//	
//	// ОтправляемыеДанные
//	ОтправляемыеДанные = Новый ТаблицаЗначений();
//	ОтправляемыеДанные.Колонки.Добавить( "FileName", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "FilePath", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "BinaryData", Новый ОписаниеТипов("BinaryData") );
//	ОтправляемыеДанные.Колонки.Добавить( "Action", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "ErrorInfo", Новый ОписаниеТипов("Строка") ); //TODO это не текст, а объект, чекнуть объявления
//	
//	НоваяСтрока = ОтправляемыеДанные.Добавить();
//	НоваяСтрока.CommitSHA = "0123456789abcdef";
//	НоваяСтрока.FileName = "test1.epf";
//	НоваяСтрока.FilePath = "Каталог 1/test1.epf";
//	НоваяСтрока.Action = "modifed";
//	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_4}");
//	НоваяСтрока.ErrorInfo = "";
//	
//	МенеджерЗаписи = РегистрыСведений.RemoteFiles.СоздатьМенеджерЗаписи();
//	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
//	МенеджерЗаписи.CheckoutSHA = "0123456789abcdef";
//	МенеджерЗаписи.Data = Новый ХранилищеЗначения(ОтправляемыеДанные);
//	МенеджерЗаписи.Записать();
//	
//	ПараметрыСобытия = Новый Структура();
//	ПараметрыСобытия.Вставить( "Webhook", ОбработчикСобытия.Ссылка );
//	ПараметрыСобытия.Вставить( "CheckoutSHA", "0123456789abcdef" );
//	
//	// when
//	DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, "0123456789abcdef" );
//
//	// then
//	ЖРПодготовкаДанных = СобытияЖурналаРегистрации(ОтборЖРПодготовкаДанных);
//	ЖРЗагрузкаДанныхЗапроса = СобытияЖурналаРегистрации(ОтборЖРЗагрузкаДанныхЗапроса);
//	ЖРЗагрузкаВнешнихФайлов = СобытияЖурналаРегистрации(ОтборЖРЗагрузкаВнешнихФайлов);
//	ЖРОбработкаДанных = СобытияЖурналаРегистрации(ОтборЖРОбработкаДанных);
//	ЖРОбработкаДанныхОкончание = СобытияЖурналаРегистрации(ОтборЖРОбработкаДанныхОкончание);
//	Фреймворк.ПроверитьВхождение(ЖРПодготовкаДанных[0].Comment, "[ 0123456789abcdef ]: " + LOADING_DATA_MESSAGE);
//	Фреймворк.ПроверитьВхождение(ЖРЗагрузкаДанныхЗапроса[0].Comment, "[ 0123456789abcdef ]: [" + LOAD_QUERY_MESSAGE + "]: " + OPERATION_SUCCEEDED_MESSAGE);
//	Фреймворк.ПроверитьВхождение(ЖРЗагрузкаВнешнихФайлов[0].Comment, "[ 0123456789abcdef ]: [" + LOAD_FILES_MESSAGE + "]: " + OPERATION_SUCCEEDED_MESSAGE);
//	Фреймворк.ПроверитьВхождение(ЖРОбработкаДанных[0].Comment, "[ 0123456789abcdef ]: " + FILES_SENT_MESSAGE + "1");
//	Фреймворк.ПроверитьВхождение(ЖРОбработкаДанных[1].Comment, "[ 0123456789abcdef ]: " + RUNNING_JOBS_MESSAGE + "1");
//	Фреймворк.ПроверитьВхождение(ЖРОбработкаДанныхОкончание[0].Comment, "[ 0123456789abcdef ]: " + DATA_PROCESSING_MESSAGE);
//	
//EndProcedure
//
//// @unit-test
//// Параметры:
//// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//Procedure BeginDataProcessingManualStartFileSendingBackgroundJob(Фреймворк) Export
//	
//	EVENT_MESSAGE = НСтр("ru = 'ОбработчикиСобытий.Core.ОбработкаДанных';en = 'Webhooks.Core.DataProcessing'");
//	
//	FILES_SENT_MESSAGE = НСтр( "ru = 'отправляемых файлов: ';en = 'files sent: '" );
//	RUNNING_JOBS_MESSAGE = НСтр( "ru = 'запущенных заданий: ';en = 'running jobs: '" );
//	KEY_MESSAGE = НСтр( "ru = 'Ключ: ';en = 'Key: '" );
//	
//	// given
//	ExternalRequestHandlersCleanUp();
//	InformationRegisterCleanUp();
//	ОтборЖурналаРегистрацииИнформация = ОтборЖурналаРегистрации(EVENT_MESSAGE);
//	ОтборЖурналаРегистрацииПредупреждение = ОтборЖурналаРегистрации(EVENT_MESSAGE, "Предупреждение");
//	ОбработчикСобытия = TestsExternalRequestsServer.NewExternalRequestHandler("ЮнитТест1", "РучнойЗапуск");
//	
//	// ДанныеЗапроса
//	JSON = "{
//			|  ""checkout_sha"": ""0123456789abcdef"",
//			|  ""project"": {
//			|    ""id"": 1,
//			|    ""http_url"": ""http://www.example.com/root/external-epf.git""
//			|  },
//			|  ""commits"": [
//			|    {
//			|      ""id"": ""0123456789abcdef"",
//			|      ""timestamp"": ""2020-07-21T09:22:31+00:00"",
//			|      ""added"": [
//			|        "".ext-epf.json"",
//			|        ""src/Внешняя Обработка 1.xml"",
//			|        ""test3.epf""
//			|      ],
//			|      ""modified"": [
//			|        ""Каталог 2/test2.epf"",
//			|        ""Каталог 1/test1.epf""
//			|      ],
//			|      ""removed"": [
//			|
//			|      ]
//			|    }
//			|  ]
//			|}";
//	ПараметрыПреобразования = Новый Структура();
//	ПараметрыПреобразования.Вставить( "ПрочитатьВСоответствие", Истина );
//	ПараметрыПреобразования.Вставить( "ИменаСвойствСоЗначениямиДата", "timestamp" );
//	ДанныеЗапроса = HTTPConnector.JsonToObject(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения(), , ПараметрыПреобразования);
//
//	ЭталонRouting = "/tmp/expectations/routing.json";	
//	Текст = Новый ЧтениеТекста(ЭталонRouting, КодировкаТекста.UTF8);
//	JSON = Текст.Прочитать();
//	JSON = HTTPConnector.JsonToObject(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());
//	JSON = JSON.Получить("httpResponse").Получить("body").Получить("string");
//	Settings = HTTPConnector.JsonToObject(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());
//
//	ДанныеЗапроса.Получить("commits")[0].Вставить("settings", Settings);
//
//	МенеджерЗаписи = РегистрыСведений.QueryData.СоздатьМенеджерЗаписи();
//	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
//	МенеджерЗаписи.CheckoutSHA = "0123456789abcdef";
//	МенеджерЗаписи.Data = Новый ХранилищеЗначения(ДанныеЗапроса);
//	МенеджерЗаписи.Записать();
//	
//	// ОтправляемыеДанные
//	ОтправляемыеДанные = Новый ТаблицаЗначений();
//	ОтправляемыеДанные.Колонки.Добавить( "RAWFilePath", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "FileName", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "FilePath", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "BinaryData", Новый ОписаниеТипов("BinaryData"));
//	ОтправляемыеДанные.Колонки.Добавить( "Action", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "Date", Новый ОписаниеТипов("Date") );
//	ОтправляемыеДанные.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
//	ОтправляемыеДанные.Колонки.Добавить( "ErrorInfo", Новый ОписаниеТипов("Строка")); //TODO это не текст, а объект, чекнуть объявления
//	
//	НоваяСтрока = ОтправляемыеДанные.Добавить();
//	НоваяСтрока.RAWFilePath = "/api/v4/projects/1/repository/files/Каталог 2/test2.epf/raw?ref=0123456789abcdef";
//	НоваяСтрока.FileName = "test2.epf";
//	НоваяСтрока.FilePath = "Каталог 2/test2.epf";
//	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_3}");
//	НоваяСтрока.Action = "modifed";
//	НоваяСтрока.Date = Date(2020, 07, 21, 09, 22, 31);	
//	НоваяСтрока.CommitSHA = "0123456789abcdef";
//	НоваяСтрока.ErrorInfo = "";
//	
//	// Попытка отправить файл два раза и в каждом файле два адреса отправки
//	НоваяСтрока = ОтправляемыеДанные.Добавить();
//	НоваяСтрока.RAWFilePath = "/api/v4/projects/1/repository/files/Каталог 2/test2.epf/raw?ref=0123456789abcdef";
//	НоваяСтрока.FileName = "test2.epf";
//	НоваяСтрока.FilePath = "Каталог 2/test2.epf";
//	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_3}");
//	НоваяСтрока.Action = "modifed";
//	НоваяСтрока.Date = Date(2020, 07, 21, 09, 22, 31);	
//	НоваяСтрока.CommitSHA = "0123456789abcdef";
//	НоваяСтрока.ErrorInfo = "";
//	
//	МенеджерЗаписи = РегистрыСведений.RemoteFiles.СоздатьМенеджерЗаписи();
//	МенеджерЗаписи.Webhook = ОбработчикСобытия.Ссылка;
//	МенеджерЗаписи.CheckoutSHA = "0123456789abcdef";
//	МенеджерЗаписи.Data = Новый ХранилищеЗначения(ОтправляемыеДанные);
//	МенеджерЗаписи.Записать();
//	
//	// when
//	Результат = DataProcessing.RunBackgroundJob(ОбработчикСобытия.Ссылка, "0123456789abcdef");
//	
//	// then
//	Фреймворк.ПроверитьТип(Результат, "ФоновоеЗадание");
//	ЖурналРегистрацииИнформация = СобытияЖурналаРегистрации(ОтборЖурналаРегистрацииИнформация);
//	ЖурналРегистрацииПредупреждение = СобытияЖурналаРегистрации(ОтборЖурналаРегистрацииПредупреждение);
//	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииИнформация[0].Comment, "[ 0123456789abcdef ]: " + FILES_SENT_MESSAGE + "2");
//	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииИнформация[1].Comment, "[ 0123456789abcdef ]: " + RUNNING_JOBS_MESSAGE + "2");
//	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииПредупреждение[0].Comment, KEY_MESSAGE + "0123456789abcdef|http://mockserver:1080/receiver3|test2.epf");
//	Фреймворк.ПроверитьВхождение(ЖурналРегистрацииПредупреждение[1].Comment, KEY_MESSAGE + "0123456789abcdef|http://mockserver:1080/receiver1|test2.epf");
//	
//EndProcedure