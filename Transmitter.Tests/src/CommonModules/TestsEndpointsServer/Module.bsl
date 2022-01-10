// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetConnectionParams(Framework) Export

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
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().ENDPOINT_OPTIONS_MISSING);
	КонецПопытки;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFile4xxError(Framework) Export

	// given
	Endpoint = NewEndpoint();
	
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
		Framework.AssertStringContains(ErrorInfo.Description, Endpoint.URL);
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
	
	Constants.EndpointUserName.Set(Endpoint.User);
	Constants.EndpointUserPassword.Set(Endpoint.Password);
	Constants.EndpointTimeout.Set(5);
		
	File = Tests.NewFile("", "Файл", "epf");
	
	StatusCode = 200;
	SetMockUploadFile(Endpoint, File, StatusCode);

	// when
	Result = Endpoints.SendFile(Endpoint, File.FileName, GetBinaryDataFromString(File.Data));
	
	// then
	Framework.AssertStringContains(Result, Endpoint.URL);
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
	Routes.Add(Endpoint.URL);
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
	Constants.EndpointTimeout.Set(5);
	
	File = Tests.NewFile("", "Файл", "epf");
	
	StatusCode = 200;
	SetMockUploadFile(Endpoint, File, StatusCode);

	Routes = New Array;
	Routes.Add(Endpoint.URL);
	Routes.Add(Endpoint.URL);

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
	Result.Insert("ServerURL", URL);	
	Result.Insert("URL", URL + "/epf/uploadFile");
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

#EndRegion
