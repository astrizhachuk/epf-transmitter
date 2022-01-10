// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCheckoutSHA(Framework) Export

	// given
	Data = New Map;
	Data.Insert("checkout_sha", "value");
	
	// when
	Result = ExternalRequests.GetCheckoutSHA(Data);
	
	// then
	Framework.AssertEqual(Result, "value");
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetProjectOrRaise(Framework) Export
	
	// given
	JSON = Tests.GetJSON("/test/requests/push.json");
	Data = HTTPConnector.JsonToObject(JSON);

	// when
	Result = ExternalRequests.GetProjectOrRaise(Data);
	
	// then
	Framework.AssertEqual(Result.Id, 1);
	Framework.AssertEqual(Result.ServerURL, "http://mockserver:1080");
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetProjectOrRaiseException(Framework) Export
	
	// given
	Data = New Map;

	// when
	Try
		ExternalRequests.GetProjectOrRaise(Data);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_POJECT_DESCRIPTION);
	EndTry;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCommitsOrRaise(Framework) Export
	
	// given
	JSON = Tests.GetJSON("/test/requests/push.json");
	Data = HTTPConnector.JsonToObject(JSON);

	// when
	Result = ExternalRequests.GetCommitsOrRaise(Data);
	
	// then
	Framework.AssertFilled(Result);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCommitsOrRaiseException(Framework) Export
	
	// given
	Data = New Map;

	// when
	Try
		ExternalRequests.GetCommitsOrRaise(Data);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_COMMITS);
	EndTry;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetRequestBody(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");
	
	ExternalRequestHandler = Tests.NewExternalRequestHandler();
	CheckoutSHA = Tests.RandomString();
	Data = "Data" + Tests.RandomString();
	
	Map = New Map();
	Map.Insert("Key", Data);
	
	Tests.AddRecord("ExternalRequests", ExternalRequestHandler, CheckoutSHA, Map);
	
	// when	
	Result = ExternalRequests.GetRequestBody(ExternalRequestHandler.Ref, CheckoutSHA);
	
	// then
	Framework.AssertType(Result, "Map");
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result.Get("Key"), Data);
		
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetRequestBodyNoData(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");
	
	// when	
	Result = ExternalRequests.GetRequestBody(Tests.NewExternalRequestHandler().Ref, Tests.RandomString());
	
	// then
	Framework.AssertNotFilled(Result);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure AppendRoutingSettingsNoData(Framework) Export

	// given
	Constants.RoutingFileName.Set(Tests.NewFileName(".ext-epf", "json"));

	// when
	Try
		ExternalRequests.AppendRoutingSettings(New Map, New ValueTable());
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_COMMITS);
	EndTry;	
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure AppendRoutingSettings(Framework) Export

	// given
	FileEPF = Tests.NewFile("каталог", "файл", "epf");
	FileSettings = Tests.NewFile("", ".ext-epf", "json");
	Constants.RoutingFileName.Set(FileSettings.FileName);
	
	Commit1 = Tests.NewCommit("commit1");
	Commit2 = Tests.NewCommit("commit2");
	Commits = New Array;
	Commits.Add(Commit1);
	Commits.Add(Commit2);
	
	Data = New Map;
	Data.Insert("commits", Commits);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, FileEPF, Commit1, "added");
	Tests.AddFileMetadata(FilesMetadata, FileSettings, Commit1, "");
	Tests.AddFileMetadata(FilesMetadata, FileSettings, Commit2, "", , "any error");	

	// when
	ExternalRequests.AppendRoutingSettings(Data, FilesMetadata);

	// then
	Framework.AssertEqual(Data.Get("commits")[0].Get("settings").Get("text"), FileSettings.FileName);
	Framework.AssertEqual(Data.Get("commits")[0].Get("settings").Get("json"), FileSettings.Data);
	Framework.AssertNotFilled(Data.Get("commits")[1].Get("settings"));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure Dump(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");
	
	ExternalRequestHandler = Tests.NewExternalRequestHandler();
	CheckoutSHA = Tests.RandomString();
	Data = "Data" + Tests.RandomString();
	
	// when	
	ExternalRequests.Dump(ExternalRequestHandler.Ref, CheckoutSHA, Data);
	Result = Tests.GetRecordSet("ExternalRequests", ExternalRequestHandler.Ref, CheckoutSHA);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Data.Get(), Data);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure DumpException(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");

	Data = New HTTPRequest();
	
	// when
	Try
		ExternalRequests.Dump(Tests.NewExternalRequestHandler().Ref, Tests.RandomString(), Data);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, "(ValueStorage)");
	EndTry;	
	
EndProcedure

#EndRegion
