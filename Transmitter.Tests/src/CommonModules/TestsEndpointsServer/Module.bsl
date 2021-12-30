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
	Endpoint = New Structure();
	URL = "http://url";
	
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
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");

	FileName = "Файл" + TIME + ".epf";
	Data = GetBinaryDataFromString(TIME);

	// when
	Try
		Endpoints.SendFile(New Structure(), FileName, Data);
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
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	URL = "http://mockserver:1080";
	User = "User" + TIME;
	Password = "Password" + TIME;
	
	Constants.EndpointUserName.Set(User);
	Constants.EndpointUserPassword.Set(Password);
	Constants.DeliveryFileTimeout.Set(5);
	
	FileName = "Файл" + TIME + ".epf";
	FileNameEncoded = EncodeString(FileName, StringEncodingMethod.URLInURLEncoding);
	Data = TIME;
	StatusCode = 403;
	ResponseBody = "{""key"":""value""}";

	SetMockUploadFile(URL, User, Password, FileNameEncoded, Data, StatusCode, ResponseBody);

	EndpointURL = URL + "/epf/uploadFile";
	Endpoint = NewEndpoint(EndpointURL, User, Password);

	// when
	Try
		Endpoints.SendFile(Endpoint, FileName, GetBinaryDataFromString(Data));
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, EndpointURL);
		Framework.AssertStringContains(ErrorInfo.Description, FileName);
		Framework.AssertStringContains(ErrorInfo.Description, StatusCode);
		Framework.AssertStringContains(ErrorInfo.Description, ResponseBody);		
		
	EndTry;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SendFile200Ok(Framework) Export

	// given
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	URL = "http://mockserver:1080";
	User = "User" + TIME;
	Password = "Password" + TIME;
	Constants.EndpointUserName.Set(User);
	Constants.EndpointUserPassword.Set(Password);
	Constants.DeliveryFileTimeout.Set(5);
		
	FileName = "Файл" + TIME + ".epf";
	FileNameEncoded = EncodeString(FileName, StringEncodingMethod.URLInURLEncoding);
	Data = TIME;
	StatusCode = 200;
	ResponseBody = "{""key"":""value""}";

	SetMockUploadFile(URL, User, Password, FileNameEncoded, Data, StatusCode, ResponseBody);

	EndpointURL = URL + "/epf/uploadFile";
	Endpoint = NewEndpoint(EndpointURL, User, Password);

	// when
	Result = Endpoints.SendFile(Endpoint, FileName, GetBinaryDataFromString(Data));
	
	// then
	Framework.AssertStringContains(Result, EndpointURL);
	Framework.AssertStringContains(Result, FileName);
	Framework.AssertStringContains(Result, StatusCode);
	Framework.AssertStringContains(Result, ResponseBody);

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
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");

	CommitSHA = TIME;
	FileName = "Файл" + TIME + ".epf";
	
	EndpointURL = "http://" + TIME + "/epf/uploadFile";
	User = "User" + TIME;
	Password = "Password" + TIME;
	Endpoint = NewEndpoint(EndpointURL, User, Password);
		
	Routes = New Array;
	Routes.Add(Endpoint);
	
	File1 = NewFile(CommitSHA, FileName, Routes);
	File2 = NewFile(CommitSHA, FileName, Routes);
	
	Files = New Array;
	Files.Add(File1);
	Files.Add(File2);
	
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
	
	File1 = New Structure("CommitSHA, FileName, Routes, Data", Undefined, Undefined, Routes, Undefined);
	Files = New Array;
	Files.Add(File1);
	
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
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	User = "User" + TIME;
	Password = "Password" + TIME;
	Constants.EndpointUserName.Set(User);
	Constants.EndpointUserPassword.Set(Password);
	Constants.DeliveryFileTimeout.Set(5);
	
	URL = "http://mockserver:1080";
	
	FileName = "Файл" + TIME + ".epf";
	FileNameEncoded = EncodeString(FileName, StringEncodingMethod.URLInURLEncoding);
	Data = TIME;
	StatusCode = 200;
	ResponseBody = "{""key"":""value""}";

	SetMockUploadFile(URL, User, Password, FileNameEncoded, Data, StatusCode, ResponseBody);

	CommitSHA = TIME;
	
	EndpointURL = URL + "/epf/uploadFile";
	Routes = New Array;
	Routes.Add(EndpointURL);
	Routes.Add(EndpointURL);

	NotFoundURL = "http://mockserver:1080/NotFound";
	NotFoundStatusCode = 404;
	RoutesHasError = New Array;
	RoutesHasError.Add(NotFoundURL);

	File1 = NewFile(CommitSHA, FileName, RoutesHasError);
	File2 = NewFile(CommitSHA, FileName, Routes);
	Files = New Array;
	Files.Add(File1);
	Files.Add(File2);
	
	// when
	Jobs = Endpoints.BackgroundSendFiles(Files);

	Result1 = Jobs[0].BackgroundJob.WaitForExecutionCompletion(30);	
	Result2 = Jobs[1].BackgroundJob.WaitForExecutionCompletion(30);
	
	// then
	Framework.AssertStringContains(Result1.ErrorInfo.Description, NotFoundURL);
	Framework.AssertStringContains(Result1.ErrorInfo.Description, FileName);
	Framework.AssertStringContains(Result1.ErrorInfo.Description, NotFoundStatusCode);
	
	Framework.AssertEqual(Result2.State, BackgroundJobState.Completed);

EndProcedure

#EndRegion

#Region Private

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

#Region Data

Function NewEndpoint(Val URL, Val User, Val Password)
	
	Result = New Structure();	
	Result.Insert("URL", URL);
	Result.Insert("User", User);
	Result.Insert("Password", Password);
	Result.Insert("Timeout", 5);
	
	Return Result;
	
EndFunction

Function NewFile(Val String, FileName, Routes)

	Result = New Structure();	
	Result.Insert("CommitSHA", String);
	Result.Insert("FileName", FileName);
	Result.Insert("Routes", Routes);
	Result.Insert("Data", GetBinaryDataFromString(String));
	
	Return Result;
	
EndFunction

#EndRegion

#EndRegion
