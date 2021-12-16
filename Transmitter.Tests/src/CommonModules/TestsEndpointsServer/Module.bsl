// BSLLS-off
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
	Framework.AssertEqual(Result.Количество(), 3);
	Framework.AssertEqual(Result.User, "UserName" + Right(TIME, 10));
	Framework.AssertEqual(Result.Password, "UserPassword" + Right(TIME, 10));	
	Framework.AssertEqual(Result.Timeout, Number(Right(TIME, 4)));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SetURL(Framework) Export

	// given
	Options = New Structure();
	URL = "http://url";
	
	// when
	Endpoints.SetURL(Options, URL);
	
	// then
	Framework.AssertEqual(Options.URL, URL);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFileErrorWithoutEndpointAndOptions(Framework) Export
	
	// given

	// when
	Try
		Result = Endpoints.SendFile("test.epf", GetBinaryDataFromString("data"), New Structure());
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().ENDPOINT_OPTIONS_MISSING);
	EndTry;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFileErrorWithoutEndpoint(Framework) Export

	// given
	ExternalRequestHandlersCleanUp();
	
	Options = NewOptions(NewExternalRequestHandler("Test", "Token").Ref, "0123456789abcdef");
	
	// when
	Try
		Result = Endpoints.SendFile("test.epf", GetBinaryDataFromString("data"), New Structure(), Options);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().ENDPOINT_OPTIONS_MISSING);
	КонецПопытки;
	
EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFile4xxError(Framework) Export

	// given
	ExternalRequestHandlersCleanUp();
	
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
	Options = NewOptions(NewExternalRequestHandler("Test", "Token").Ref, CheckoutSHA);

	// when
	Try
		Result = Endpoints.SendFile(FileName, GetBinaryDataFromString(Data), Endpoint, Options);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, CheckoutSHA);
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
	ExternalRequestHandlersCleanUp();
	
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
	Options = NewOptions(NewExternalRequestHandler("Test", "Token").Ref, CheckoutSHA);

	// when
	Result = Endpoints.SendFile(FileName, GetBinaryDataFromString(Data), Endpoint, Options);
	
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
	ExternalRequestHandlersCleanUp();
	
	FileName = "Файл.epf";
	Data = "data";
	
	Endpoint = New Structure();
	CheckoutSHA = "0123456789abcdef";		
	Options = NewOptions(NewExternalRequestHandler("Test", "Token").Ref, CheckoutSHA);
	
	JobParams = NewJobParams(FileName, Data, Endpoint, Options);
	
	// when
	Job = BackgroundJobs.Execute("Endpoints.SendFile", JobParams);
	Result = Job.WaitForExecutionCompletion();

	// then
	Framework.AssertEqual(Result.State, BackgroundJobState.Failed);
	Framework.AssertStringContains(Result.ErrorInfo.Description, CheckoutSHA);
	Framework.AssertStringContains(Result.ErrorInfo.Description, Logs.Messages().ENDPOINT_OPTIONS_MISSING);

EndProcedure

// @unit-test:dev
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFileBackgroundJob200OkMultipleFiles(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	
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

	ExternalRequestHandler = NewExternalRequestHandler("Test", "Token");
	CheckoutSHA = "0123456789abcdef";		
	Options = NewOptions(ExternalRequestHandler.Ref, CheckoutSHA);
	
	EventLogFilter = EventLogFilterByData(ExternalRequestHandler.Ref);

	JobParams = NewJobParams(FileName, Data, Endpoint, Options);
	
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
		Result.Add(Job.WaitForExecutionCompletion(10));
	EndDo;
	Pause(3);
	EventLog = GetEventLog(EventLogFilter);

	// then
	Framework.AssertEqual(Result[0].State, BackgroundJobState.Completed);
	Framework.AssertEqual(Result[1].State, BackgroundJobState.Failed);
	Framework.AssertEqual(Result[2].State, BackgroundJobState.Completed);
	
	Framework.AssertStringContains(Result[1].ErrorInfo.Description, CheckoutSHA);
	Framework.AssertStringContains(Result[1].ErrorInfo.Description, Logs.Messages().ENDPOINT_OPTIONS_MISSING);

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
	
	Return UtilsServer.EventLogFilterByData(Data, Level, "BackgroundJob");
	
EndFunction

Function GetEventLog(Val Filter)
	
	Return UtilsServer.GetEventLog(Filter);
	
EndFunction

#EndRegion

#Region Data

Procedure ExternalRequestHandlersCleanUp()
	
	UtilsServer.CatalogCleanUp("ExternalRequestHandlers");

EndProcedure

Function NewExternalRequestHandler(Val Name, Val Token)

	Return TestsWebhooksServer.AddExternalRequestHandler(Name, "empty", Token);

EndFunction

Function NewEndpoint(Val URL, Val User, Val Password)
	
	Result = New Structure();	
	Result.Insert("URL", URL);
	Result.Insert("User", User);
	Result.Insert("Password", Password);
	Result.Insert("Timeout", 5);
	
	Return Result;
	
EndFunction

Function NewOptions(Val Ref, Val CheckoutSHA)
	
	Result = New Structure();
	Result.Insert( "ExternalRequestHandler", Ref );
	Result.Insert( "CheckoutSHA", CheckoutSHA );
	
	Return Result;
	
EndFunction

Function NewJobParams(Val FileName, Val Data, Val Endpoint, Val Options)

	Result = New Array();
	Result.Add(FileName);
	Result.Add(GetBinaryDataFromString(Data));
	Result.Add(Endpoint);
	Result.Add(Options);
	
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
					.WithHeader("name", FileName)
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
