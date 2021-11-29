#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetConnectionParams(Framework) Export

	// given
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	Constants.EndpointUserName.Set("UserName" + Right(TIME, 10));
	Constants.EndpointUserPassword.Set("UserPassword" + Right(TIME, 10));
	Constants.DeliveryFileTimeout.Set(Number(Right(TIME, 4)));
	// when
	Result = Endpoints.GetConnectionParams();
	// then
	Framework.AssertEqual(Result.Количество(), 4);
	Framework.AssertEqual(Result.URL, "");
	Framework.AssertEqual(Result.User, "UserName" + Right(TIME, 10));
	Framework.AssertEqual(Result.Password, "UserPassword" + Right(TIME, 10));	
	Framework.AssertEqual(Result.Timeout, Number(Right(TIME, 4)));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFileErrorWithoutEndpointAndEvent(Framework) Export
	
	// given
	MISSING_ENDPOINT_MESSAGE = NStr("ru = 'Отсутствуют параметры доставки файлов.';en = 'File delivery options are missing.'");

	// when
	Try
		Result = Endpoints.SendFile("test.epf", GetBinaryDataFromString("data"), New Structure());
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, MISSING_ENDPOINT_MESSAGE);
	EndTry;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFileErrorWithoutEndpoint(Framework) Export

	// given
	WebhookCleanUp();
	
	MISSING_ENDPOINT_MESSAGE = НСтр("ru = 'Отсутствуют параметры доставки файлов.';en = 'File delivery options are missing.'");
	
	Event = NewEvent(NewWebhook("Test", "Token").Ref, "0123456789abcdef");
	
	// when
	Try
		Result = Endpoints.SendFile("test.epf", GetBinaryDataFromString("data"), New Structure(), Event);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, MISSING_ENDPOINT_MESSAGE);
	КонецПопытки;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFile4xxError(Framework) Export

	// given
	WebhookCleanUp();
	
	URL = "http://mockserver:1080";
	User = "User1";
	Password = "Password1";
	FileName = "Файл.epf";
	FileNameEncoded = "%D0%A4%D0%B0%D0%B9%D0%BB.epf";
	Data = "data";
	StatusCode = 403;
	ResponseBody = "{""key"":""value""}";

	SetMockUploadFile(URL, User, Password, FileNameEncoded, Data, StatusCode, ResponseBody);

	Endpoint = NewEndpoint(URL + "/epf/uploadFile", User, Password);
	
	CheckoutSHA = "0123456789abcdef";		
	Event = NewEvent(NewWebhook("Test", "Token").Ref, CheckoutSHA);

	// when
	Try
		Result = Endpoints.SendFile(FileName, GetBinaryDataFromString(Data), Endpoint, Event);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, CheckoutSHA);
		Framework.AssertStringContains(ErrorInfo.Description, NStr("ru = 'Ошибка';en = 'Error'"));
		Framework.AssertStringContains(ErrorInfo.Description, StatusCode);
	EndTry;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFile200OkWithoutEventLog(Framework) Export

	// given	
	URL = "http://mockserver:1080";
	User = "User1";
	Password = "Password1";
	FileName = "Файл.epf";
	FileNameEncoded = "%D0%A4%D0%B0%D0%B9%D0%BB.epf";
	Data = "data";
	StatusCode = 200;
	ResponseBody = "{""key"":""value""}";

	SetMockUploadFile(URL, User, Password, FileNameEncoded, Data, StatusCode, ResponseBody);

	Endpoint = NewEndpoint(URL + "/epf/uploadFile", User, Password);

	// when
	Result = Endpoints.SendFile(FileName, GetBinaryDataFromString(Data), Endpoint);
	
	// then
	Framework.AssertStringContains(Result, URL);
	Framework.AssertStringContains(Result, FileName);
	Framework.AssertStringContains(Result, ResponseBody);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFile200OkWithEventLog(Framework) Export
	
	// given
	WebhookCleanUp();
	
	URL = "http://mockserver:1080";
	User = "User1";
	Password = "Password1";
	FileName = "Файл.epf";
	FileNameEncoded = "%D0%A4%D0%B0%D0%B9%D0%BB.epf";
	Data = "data";
	StatusCode = 200;
	ResponseBody = "{""key"":""value""}";

	SetMockUploadFile(URL, User, Password, FileNameEncoded, Data, StatusCode, ResponseBody);

	Endpoint = NewEndpoint(URL + "/epf/uploadFile", User, Password);

	CheckoutSHA = "0123456789abcdef";		
	Event = NewEvent(NewWebhook("Test", "Token").Ref, CheckoutSHA);

	// when
	Result = Endpoints.SendFile(FileName, GetBinaryDataFromString(Data), Endpoint, Event);
	
	// then
	Framework.AssertStringContains(Result, CheckoutSHA);
	Framework.AssertStringContains(Result, URL);
	Framework.AssertStringContains(Result, FileName);
	Framework.AssertStringContains(Result, ResponseBody);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFileBackgroundJobError(Framework) Export

	//given
	WebhookCleanUp();
	
	MISSING_ENDPOINT_MESSAGE = НСтр("ru = 'Отсутствуют параметры доставки файлов.';en = 'File delivery options are missing.'");
	
	FileName = "Файл.epf";
	Data = "data";
	
	Endpoint = New Structure();
	CheckoutSHA = "0123456789abcdef";		
	Event = NewEvent(NewWebhook("Test", "Token").Ref, CheckoutSHA);
	
	JobParams = NewJobParams(FileName, Data, Endpoint, Event);
	
	// when
	Job = BackgroundJobs.Execute("Endpoints.SendFile", JobParams);
	Result = Job.WaitForExecutionCompletion();

	// then
	Framework.AssertEqual(Result.State, BackgroundJobState.Failed);
	Framework.AssertStringContains(Result.ErrorInfo.Description, CheckoutSHA);
	Framework.AssertStringContains(Result.ErrorInfo.Description, MISSING_ENDPOINT_MESSAGE);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFileBackgroundJob200OkMultipleFiles(Framework) Export
	
	// given
	MISSING_ENDPOINT_MESSAGE = НСтр("ru = 'Отсутствуют параметры доставки файлов.';en = 'File delivery options are missing.'");
	
	WebhookCleanUp();
	
	URL = "http://mockserver:1080";
	User = "User1";
	Password = "Password1";
	FileName = "Файл.epf";
	FileNameEncoded = "%D0%A4%D0%B0%D0%B9%D0%BB.epf";
	Data = "data";
	StatusCode = 200;
	ResponseBody = "{""key"":""value""}";

	SetMockUploadFile(URL, User, Password, FileNameEncoded, Data, StatusCode, ResponseBody);

	Endpoint = NewEndpoint(URL + "/epf/uploadFile", User, Password);

	Webhook = NewWebhook("Test", "Token");
	CheckoutSHA = "0123456789abcdef";		
	Event = NewEvent(Webhook.Ref, CheckoutSHA);
	
	EventLogFilter = EventLogFilterByData(Webhook.Ref);

	JobParams = NewJobParams(FileName, Data, Endpoint, Event);
	
	// when
	// three files: two good, one bad
	Result = New Array();
	For Index = 1 To 3 Do
		If Index = 2 Then
			JobParams[2] = New Structure();
		Else
			JobParams[2] = Endpoint;
		EndIf;
		
		Job = BackgroundJobs.Execute("Endpoints.SendFile",
										JobParams,
										"Index" + Index,
										"Test.Endpoints.SendFile." + Index);
		Result.Добавить(Job.ОжидатьЗавершенияВыполнения(10));
	EndDo;
	Pause(3);
	EventLog = GetEventLog(EventLogFilter);

	// then
	Framework.AssertEqual(Result[0].State, BackgroundJobState.Completed);
	Framework.AssertEqual(Result[1].State, BackgroundJobState.Failed);
	Framework.AssertEqual(Result[2].State, BackgroundJobState.Completed);
	
	Framework.AssertStringContains(Result[1].ErrorInfo.Description, CheckoutSHA);
	Framework.AssertStringContains(Result[1].ErrorInfo.Description, MISSING_ENDPOINT_MESSAGE);

	Framework.AssertEqual(EventLog.Count(), 2);
	Framework.AssertStringContains(EventLog[0].Comment, CheckoutSHA);
	Framework.AssertStringContains(EventLog[0].Comment, URL);
	Framework.AssertStringContains(EventLog[0].Comment, FileName);
	Framework.AssertStringContains(EventLog[0].Comment, ResponseBody);
	
	Framework.AssertStringContains(EventLog[1].Comment, CheckoutSHA);
	Framework.AssertStringContains(EventLog[1].Comment, URL);
	Framework.AssertStringContains(EventLog[1].Comment, FileName);
	Framework.AssertStringContains(EventLog[1].Comment, ResponseBody);

EndProcedure

#EndRegion

#Region Private

Procedure Pause(Val Period)
	
	UtilsServer.Pause(Period);
	
EndProcedure

#Region EventLog

Function EventLogFilterByData(Data, Level = "Information")
	
	Return UtilsServer.EventLogFilterByData(Data, Level);
	
EndFunction

Function GetEventLog(Val Filter)
	
	Return UtilsServer.GetEventLog(Filter);
	
EndFunction

#EndRegion

#Region Data

Procedure WebhookCleanUp()
	
	UtilsServer.CatalogCleanUp("Webhooks");

EndProcedure

Function NewWebhook(Val Name, Val Token)

	Return TestsWebhooksServer.AddWebhook(Name, "empty", Token);

EndFunction

Function NewEndpoint(Val URL, Val User, Val Password)
	
	Result = New Structure();	
	Result.Insert("URL", URL);
	Result.Insert("User", User);
	Result.Insert("Password", Password);
	Result.Insert("Timeout", 5);
	
	Return Result;
	
EndFunction

Function NewEvent(Val Ref, Val CheckoutSHA)
	
	Result = New Structure();
	Result.Insert( "Webhook", Ref );
	Result.Insert( "CheckoutSHA", CheckoutSHA );
	
	Return Result;
	
EndFunction

Function NewJobParams(Val FileName, Val Data, Val Endpoint, Val Event)

	Result = New Array();
	Result.Add(FileName);
	Result.Add(GetBinaryDataFromString(Data));
	Result.Add(Endpoint);
	Result.Add(Event);
	
	Return Result;
	
EndFunction

Procedure SetMockUploadFile(Val URL, Val User, Val Password, Val FileName, Val Data, Val StatusCode, Val ResponseBody)
	
	Base64 = GetBase64StringFromBinaryData(GetBinaryDataFromString(User + ":" + Password));
	
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server(URL, , True)
		.Когда(
			Mock.Request()
				.WithMethod("POST")
				.WithPath("/epf/uploadFile")
				.Headers()
					.WithHeader("Authorization", "Basic " + Base64)
					.WithHeader("Name", FileName)
				.WithBody(Data)
		)
	    .Respond(
	        Mock.Response()
	        	.WithStatusCode(StatusCode)
	        	.WithBody(ResponseBody)
	    );
    Mock = Undefined;
    
EndProcedure

#EndRegion

#EndRegion
