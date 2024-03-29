// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetConnectionParams(Framework) Export
	
	// given
	
	// when
	Result = EndpointsClientServer.GetConnectionParams();
	
	// then
	Framework.AssertEqual(Result.Count(), 8);
	Framework.AssertEqual(Result.URL, "");
	Framework.AssertEqual(Result.BaseURL, "");
	Framework.AssertEqual(Result.Operation, "/status");
	Framework.AssertFalse(Result.UseGlobalSettings);
	Framework.AssertEqual(Result.User, "");
	Framework.AssertEqual(Result.Password, "");
	Framework.AssertEqual(Result.Timeout, Undefined);	

EndProcedure

// TODO кандидат на удаление?

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetEndpointParams(Framework) Export

	// given
	UserName = "UserName" + Tests.RandomString();
	UserPassword = "UserPassword" + Tests.RandomString();
	EndpointTimeout = Number(Right(Tests.RandomString(), 4));
		
	Constants.EndpointUserName.Set(UserName);
	Constants.EndpointUserPassword.Set(UserPassword);
	Constants.EndpointTimeout.Set(EndpointTimeout);
	
	// when
	Result = Endpoints.GetConnectionParams();
	
	// then
	Framework.AssertEqual(Result.Count(), 3);
	Framework.AssertEqual(Result.User, UserName);
	Framework.AssertEqual(Result.Password, UserPassword);	
	Framework.AssertEqual(Result.Timeout, EndpointTimeout);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SetURL(Framework) Export

	// given
	URL = "http://url";
	Endpoint = New Structure();
	
	// when
	Endpoints.SetURL(Endpoint, URL);
	
	// then
	Framework.AssertEqual(Endpoint.URL, URL);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFileErrorWithoutEndpoint(Framework) Export

	// given

	// when
	Try
		Endpoints.SendFile(New Structure(), Tests.NewFileName("Файл", "epf"), GetBinaryDataFromString("Data"));
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_ENDPOINT);
	EndTry;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFile4xxError(Framework) Export

	// given
	Endpoint = NewEndpoint();
	Endpoint.URL = Endpoint.UploadFileURL;
	
	Constants.EndpointUserName.Set(Endpoint.User);
	Constants.EndpointUserPassword.Set(Endpoint.Password);
	Constants.EndpointTimeout.Set(5);
	
	File = Tests.NewFile("", "Файл", "epf");

	StatusCode = 403;
	SetMockUploadFile(Endpoint, File, StatusCode);

	// when
	Try
		Endpoints.SendFile(Endpoint, File.FileName, GetBinaryDataFromString(File.Data));
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Endpoint.UploadFileURL);
		Framework.AssertStringContains(ErrorInfo.Description, File.FileName);
		Framework.AssertStringContains(ErrorInfo.Description, StatusCode);
		Framework.AssertStringContains(ErrorInfo.Description, File.Data);		
		
	EndTry;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFile200Ok(Framework) Export

	// given
	Endpoint = NewEndpoint();
	Endpoint.URL = Endpoint.UploadFileURL;
	
	Constants.EndpointUserName.Set(Endpoint.User);
	Constants.EndpointUserPassword.Set(Endpoint.Password);
	Constants.EndpointTimeout.Set(5);
		
	File = Tests.NewFile("", "Файл", "epf");
	
	StatusCode = 200;
	SetMockUploadFile(Endpoint, File, StatusCode);

	// when
	Result = Endpoints.SendFile(Endpoint, File.FileName, GetBinaryDataFromString(File.Data));
	
	// then
	Framework.AssertStringContains(Result, Endpoint.UploadFileURL);
	Framework.AssertStringContains(Result, File.FileName);
	Framework.AssertStringContains(Result, StatusCode);
	Framework.AssertStringContains(Result, File.Data);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure BackgroundSendFilesEmptyFiles(Framework) Export

	// given
	Files = New Array;

	// when
	Result = Endpoints.BackgroundSendFiles(Files);

	// then
	Framework.AssertNotFilled(Result);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure BackgroundSendFilesActiveJob(Framework) Export

	// given
	Endpoint = NewEndpoint();
	CommitSHA = Tests.RandomString();
	Routes = New Array;
	Routes.Add(Endpoint.UploadFileURL);
	File = Tests.NewFile("", "Файл", "epf");
	
	FileToSend1 = NewFileToSend(CommitSHA, File, Routes);
	FileToSend2 = NewFileToSend(CommitSHA, File, Routes);
	
	Files = New Array;
	Files.Add(FileToSend1);
	Files.Add(FileToSend2);
	
	// when
	Result = Endpoints.BackgroundSendFiles(Files);

	// then
	Framework.AssertFilled(Result);
	
	Framework.AssertFilled(Result[0].BackgroundJob);
	Framework.AssertNotFilled(Result[0].ErrorInfo);
	
	Framework.AssertNotFilled(Result[1].BackgroundJob);
	Framework.AssertFilled(Result[1].ErrorInfo);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure BackgroundSendFilesJobError(Framework) Export

	// given
	Routes = New Array;
	Routes.Add(Undefined);
	
	File = New Structure("CommitSHA, FileName, Routes, BinaryData", Undefined, Undefined, Routes, Undefined);
	Files = New Array;
	Files.Add(File);
	
	// when
	Result = Endpoints.BackgroundSendFiles(Files);

	// then
	Framework.AssertNotFilled(Result[0].BackgroundJob);
	Framework.AssertFilled(Result[0].ErrorInfo);
		
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure BackgroundSendFilesMixedResult(Framework) Export
	
	// given
	Endpoint = NewEndpoint();
	
	Constants.EndpointUserName.Set(Endpoint.User);
	Constants.EndpointUserPassword.Set(Endpoint.Password);
	Constants.EndpointTimeout.Set(Endpoint.Timeout);
	
	File = Tests.NewFile("", "Файл", "epf");
	
	StatusCode = 200;
	SetMockUploadFile(Endpoint, File, StatusCode);

	Routes = New Array;
	Routes.Add(Endpoint.UploadFileURL);
	Routes.Add(Endpoint.UploadFileURL);

	NotFoundURL = Endpoint.ServerURL + "/NotFound";
	NotFoundStatusCode = 404;
	RoutesHasError = New Array;
	RoutesHasError.Add(NotFoundURL);
	
	CommitSHA = Tests.RandomString();
	FileToSend1 = NewFileToSend(CommitSHA, File, RoutesHasError);
	FileToSend2 = NewFileToSend(CommitSHA, File, Routes);
	
	Files = New Array;
	Files.Add(FileToSend1);
	Files.Add(FileToSend2);
	
	// when
	Jobs = Endpoints.BackgroundSendFiles(Files);

	Result1 = Jobs[0].BackgroundJob.WaitForExecutionCompletion(30);	
	Result2 = Jobs[1].BackgroundJob.WaitForExecutionCompletion(30);
	
	// then
	Framework.AssertStringContains(Result1.ErrorInfo.Description, NotFoundURL);
	Framework.AssertStringContains(Result1.ErrorInfo.Description, File.FileName);
	Framework.AssertStringContains(Result1.ErrorInfo.Description, NotFoundStatusCode);
	
	Framework.AssertTrue(Result2.State = BackgroundJobState.Completed);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetServiceStatusException(Framework) Export
	
	// given
	Endpoint = NewEndpoint();
	
	Constants.EndpointUserName.Set(Endpoint.User);
	Constants.EndpointUserPassword.Set(Endpoint.Password);
	Constants.EndpointTimeout.Set(Endpoint.Timeout);
	
	StatusCode = 200;
	Body = "{""message"":""загрузка файлов включена""}";
	SetMockStatus(Endpoint, Body, StatusCode);
	
	Connection = New Structure();
	Connection.Insert( "URL", "" );
	Connection.Insert( "BaseURL", "" );
	Connection.Insert( "RootURL", "" );
	Connection.Insert( "Operation", "/status" );
	Connection.Insert( "UseGlobalSettings", False );
	Connection.Insert( "User", Endpoint.User );
	Connection.Insert( "Password", Endpoint.Password );
	Connection.Insert( "Timeout", Undefined );
	
	// when
	Result = EndpointsServerCall.GetServiceStatus(Connection);
	
	// then
	Framework.AssertEqual(Result.StatusCode, -1);
	Framework.AssertStringContains(Result.ResponseBody, "or missing URL");

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetServiceStatusURL(Framework) Export
	
	// given
	Endpoint = NewEndpoint();
	
	Constants.EndpointUserName.Set(Endpoint.User);
	Constants.EndpointUserPassword.Set(Endpoint.Password);
	Constants.EndpointTimeout.Set(Endpoint.Timeout);
	
	StatusCode = 200;
	Body = "{""message"":""загрузка файлов включена""}";
	SetMockStatus(Endpoint, Body, StatusCode);
	
	Connection = New Structure();
	Connection.Insert( "URL", Endpoint.ServiceStatusURL );
	Connection.Insert( "BaseURL", "" );
	Connection.Insert( "RootURL", "" );
	Connection.Insert( "Operation", "/status" );
	Connection.Insert( "UseGlobalSettings", False );
	Connection.Insert( "User", Endpoint.User );
	Connection.Insert( "Password", Endpoint.Password );
	Connection.Insert( "Timeout", Undefined );
	
	// when
	Result = EndpointsServerCall.GetServiceStatus(Connection);
	
	// then
	Framework.AssertEqual(Result.StatusCode, StatusCode);
	Framework.AssertEqual(Result.ResponseBody, Body);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetServiceStatusConcat(Framework) Export
	
	// given
	Endpoint = NewEndpoint();
	
	Constants.EndpointUserName.Set(Endpoint.User);
	Constants.EndpointUserPassword.Set(Endpoint.Password);
	Constants.EndpointTimeout.Set(Endpoint.Timeout);
	
	StatusCode = 200;
	Body = "{""message"":""загрузка файлов включена""}";
	SetMockStatus(Endpoint, Body, StatusCode);
	
	Connection = New Structure();
	Connection.Insert( "URL", "" );
	Connection.Insert( "BaseURL", Endpoint.ServerURL );
	Connection.Insert( "RootURL", "/epf" );
	Connection.Insert( "Operation", "/status" );
	Connection.Insert( "UseGlobalSettings", False );
	Connection.Insert( "User", Endpoint.User );
	Connection.Insert( "Password", Endpoint.Password );
	Connection.Insert( "Timeout", Undefined );
	
	// when
	Result = EndpointsServerCall.GetServiceStatus(Connection);
	
	// then
	Framework.AssertEqual(Result.StatusCode, StatusCode);
	Framework.AssertEqual(Result.ResponseBody, Body);

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetServiceStatusURLInlineAuth(Framework) Export
	
	// given
	Endpoint = NewEndpoint();
	
	Constants.EndpointUserName.Set(Endpoint.User);
	Constants.EndpointUserPassword.Set(Endpoint.Password);
	Constants.EndpointTimeout.Set(Endpoint.Timeout);
	
	StatusCode = 200;
	Body = "{""message"":""загрузка файлов включена""}";
	SetMockStatus(Endpoint, Body, StatusCode);
	
	Connection = New Structure();
	Connection.Insert( "URL", "http://" + Endpoint.User + ":" + Endpoint.Password + "@mockserver:1080/epf/status" );
	Connection.Insert( "BaseURL", "" );
	Connection.Insert( "RootURL", "/epf" );
	Connection.Insert( "Operation", "/status" );
	Connection.Insert( "UseGlobalSettings", False );
	Connection.Insert( "User", "" );
	Connection.Insert( "Password", "" );
	Connection.Insert( "Timeout", Undefined );
	
	// when
	Result = EndpointsServerCall.GetServiceStatus(Connection);
	
	// then
	Framework.AssertEqual(Result.StatusCode, StatusCode);
	Framework.AssertEqual(Result.ResponseBody, Body);

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetServiceStatusBaseURLInlineAuth(Framework) Export
	
	// given
	Endpoint = NewEndpoint();
	
	Constants.EndpointUserName.Set(Endpoint.User);
	Constants.EndpointUserPassword.Set(Endpoint.Password);
	Constants.EndpointTimeout.Set(Endpoint.Timeout);
	
	StatusCode = 200;
	Body = "{""message"":""загрузка файлов включена""}";
	SetMockStatus(Endpoint, Body, StatusCode);
	
	Connection = New Structure();
	Connection.Insert( "URL", "" );
	Connection.Insert( "BaseURL", "http://" + Endpoint.User + ":" + Endpoint.Password + "@mockserver:1080" );
	Connection.Insert( "RootURL", "/epf" );
	Connection.Insert( "Operation", "/status" );
	Connection.Insert( "UseGlobalSettings", False );
	Connection.Insert( "User", "" );
	Connection.Insert( "Password", "" );
	Connection.Insert( "Timeout", Undefined );
	
	// when
	Result = EndpointsServerCall.GetServiceStatus(Connection);
	
	// then
	Framework.AssertEqual(Result.StatusCode, StatusCode);
	Framework.AssertEqual(Result.ResponseBody, Body);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetServiceStatusGlobalSettingsFailedAuth(Framework) Export
	
	// given
	Endpoint = NewEndpoint();
	
	Constants.EndpointUserName.Set(Endpoint.User);
	Constants.EndpointUserPassword.Set(Endpoint.Password);
	Constants.EndpointTimeout.Set(Endpoint.Timeout);
	
	StatusCode = 200;
	Body = "{""message"":""загрузка файлов включена""}";
	SetMockStatus(Endpoint, , StatusCode);
	
	Connection = New Structure();
	Connection.Insert( "URL", Endpoint.ServiceStatusURL );
	Connection.Insert( "BaseURL", "" );
	Connection.Insert( "RootURL", "" );
	Connection.Insert( "Operation", "/status" );
	Connection.Insert( "UseGlobalSettings", False );
	Connection.Insert( "User", Tests.RandomString() );
	Connection.Insert( "Password", Tests.RandomString() );
	Connection.Insert( "Timeout", 0 );
	
	// when
	Result = EndpointsServerCall.GetServiceStatus(Connection);
	
	// then
	Framework.AssertEqual(Result.StatusCode, 404);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetServiceStatusGlobalSettings(Framework) Export
	
	// given
	Endpoint = NewEndpoint();
	
	Constants.EndpointUserName.Set(Endpoint.User);
	Constants.EndpointUserPassword.Set(Endpoint.Password);
	Constants.EndpointTimeout.Set(Endpoint.Timeout);
	
	StatusCode = 200;
	Body = "{""message"":""загрузка файлов включена""}";
	SetMockStatus(Endpoint, Body, StatusCode);
	
	Connection = New Structure();
	Connection.Insert( "URL", Endpoint.ServiceStatusURL );
	Connection.Insert( "BaseURL", "" );
	Connection.Insert( "RootURL", "" );
	Connection.Insert( "Operation", "/status" );
	Connection.Insert( "UseGlobalSettings", True );
	Connection.Insert( "User", Tests.RandomString() );
	Connection.Insert( "Password", Tests.RandomString() );
	Connection.Insert( "Timeout", 0 );
	
	// when
	Result = EndpointsServerCall.GetServiceStatus(Connection);
	
	// then
	Framework.AssertEqual(Result.StatusCode, StatusCode);
	Framework.AssertEqual(Result.ResponseBody, Body);

EndProcedure

#EndRegion

#Region Private

Function NewFileToSend(Val CommitSHA, File, Routes)

	Result = New Structure();	
	Result.Insert("CommitSHA", CommitSHA);
	Result.Insert("FileName", File.FileName);
	Result.Insert("Routes", Routes);
	Result.Insert("BinaryData", GetBinaryDataFromString(File.Data));
	
	Return Result;
	
EndFunction

Function NewEndpoint()
	
	URL = "http://mockserver:1080";
	
	Result = New Structure();
	Result.Insert("URL");	
	Result.Insert("ServerURL", URL);	
	Result.Insert("UploadFileURL", URL + "/epf/uploadFile");
	Result.Insert("ServiceStatusURL", URL + "/epf/status");
	Result.Insert("User", "User" + Tests.RandomString());
	Result.Insert("Password", "Password" + Tests.RandomString());
	Result.Insert("Timeout", 5);
	
	Return Result;
	
EndFunction

Procedure SetMockUploadFile(Val Endpoint, Val File, Val StatusCode)
	
	Base64 = GetBase64StringFromBinaryData(GetBinaryDataFromString(Endpoint.User + ":" + Endpoint.Password));
	
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server(Endpoint.ServerURL, , True)
		.When(
			Mock.Request()
				.WithMethod("POST")
				.WithPath("/epf/uploadFile")
				.Headers()
					.WithHeader("Authorization", "Basic " + Base64)
					.WithHeader("name", File.FileNameEncoded)
		)
	    .Respond(
	        Mock.Response()
	        	.WithStatusCode(StatusCode)
				.WithHeader("Content-Type", "text/plain; charset=utf-8")
	        	.WithBody(File.Data)
	    );
    
EndProcedure

Procedure SetMockStatus(Val Endpoint, Val Body = "", Val StatusCode)
	
	Base64 = GetBase64StringFromBinaryData(GetBinaryDataFromString(Endpoint.User + ":" + Endpoint.Password));
	
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server(Endpoint.ServerURL, , True)
		.When(
			Mock.Request()
				.WithMethod("GET")
				.WithPath("/epf/status")
				.Headers()
					.WithHeader("Authorization", "Basic " + Base64)
		)
	    .Respond(
	        Mock.Response()
	        	.WithStatusCode(StatusCode)
				.WithHeader("Content-Type", "application/json; charset=utf-8")
	        	.WithBody(Body)
    );
    
EndProcedure

#EndRegion
