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
	JSON = Tests.GetJSON("/test/requests/push-1b9949a2.json");
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
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_PROJECT);
	EndTry;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCommitsOrRaise(Framework) Export
	
	// given
	JSON = Tests.GetJSON("/test/requests/push-1b9949a2.json");
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
Procedure GetCommitOrRaise(Framework) Export
	
	// given
	Commit = Tests.NewCommit("commit");
	Commits = New Array;
	Commits.Add(Commit);
	
	Result = New Map;
	Result.Insert("commits", Commits);

	// when
	Result = ExternalRequests.GetCommitOrRaise(Result, Commit.Get("id"));
	
	// then
	Framework.AssertEqual(Result.Get("id"), Commit.Get("id"));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCommitOrRaiseExceptionCommits(Framework) Export
	
	// given
	Data = New Map;

	// when
	Try
		ExternalRequests.GetCommitOrRaise(Data, "");
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
Procedure GetCommitOrRaiseExceptionCommit(Framework) Export
	
	// given
	Commits = New Array;
	Data = New Map;
	Data.Insert("commits", Commits);

	// when
	Try
		ExternalRequests.GetCommitOrRaise(Data, "");
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_COMMIT);
	EndTry;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFromIB(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests");
	
	ExternalRequestHandler = Tests.NewExternalRequestHandler();
	CheckoutSHA = Tests.RandomString();
	Data = "Data" + Tests.RandomString();
	
	Map = New Map();
	Map.Insert("Key", Data);
	
	Tests.AddRecord("ExternalRequests", ExternalRequestHandler, CheckoutSHA, Map);
	
	// when	
	Result = ExternalRequests.GetFromIB(ExternalRequestHandler.Ref, CheckoutSHA);
	
	// then
	Framework.AssertType(Result, "Map");
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result.Get("Key"), Data);
		
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFromIBNoData(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests");
	
	// when	
	Result = ExternalRequests.GetFromIB(Tests.NewExternalRequestHandler().Ref, Tests.RandomString());
	
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
Procedure AppendCustomRoutingSettingsNoData(Framework) Export

	// given
	Result = New Map;

	// when
	Try
		ExternalRequests.AppendCustomRoutingSettings(Result, "", "");
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
Procedure AppendCustomRoutingSettingsCommitNotFound(Framework) Export

	// given
	Commit = Tests.NewCommit("commit");
	Commits = New Array;
	Result = New Map;
	Result.Insert("commits", Commits);

	// when
	Try
		ExternalRequests.AppendCustomRoutingSettings(Result, Commit.Get("id"), "");
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_COMMIT);
	EndTry;	

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure AppendCustomRoutingSettings(Framework) Export

	// given
	Commit = Tests.NewCommit("commit");
	Commits = New Array;
	Commits.Add(Commit);
	
	Result = New Map;
	Result.Insert("commits", Commits);
	
	JSON = "{""key"": ""value""}";

	// when
	ExternalRequests.AppendCustomRoutingSettings(Result, Commit.Get("id"), JSON);
	
	// then
	Framework.AssertEqual(Result.Get("commits").Count(), 1);
	Framework.AssertFilled(Result.Get("commits")[0].Get("custom_settings"));	
	Framework.AssertEqual(Result.Get("commits")[0].Get("custom_settings").Get("json"), JSON);	
	Framework.AssertEqual(Result.Get("commits")[0].Get("custom_settings").Get("key"), "value");	
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure RemoveCustomRoutingSettingsNoData(Framework) Export

	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests");
	
	// when
	Try
		ExternalRequests.RemoveCustomRoutingSettings(Tests.NewExternalRequestHandler().Ref, "", "");
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_REQUEST_DATA);
	EndTry;	

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure RemoveCustomRoutingSettingsCommitNotFound(Framework) Export

	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests");
	
	ExternalRequestHandler = Tests.NewExternalRequestHandler();
	CheckoutSHA = Tests.RandomString();
	Data = New Map;
	Data.Insert("commits", New Array);
	
	Tests.AddRecord("ExternalRequests", ExternalRequestHandler, CheckoutSHA, Data);

	// when
	Try
		ExternalRequests.RemoveCustomRoutingSettings(ExternalRequestHandler.Ref, CheckoutSHA, "");
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_COMMIT);
	EndTry;	

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure RemoveCustomRoutingSettingsNoCustomSettings(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests");
	
	ExternalRequestHandler = Tests.NewExternalRequestHandler();
	
	CheckoutSHA = Tests.RandomString();
	
	Commit = Tests.NewCommit("commit");
	Default = New Map;
	Default.Insert("json", "{""key"": ""default""}");
	Commit.Insert("settings", Default);
	Commits = New Array;
	Commits.Add(Commit);
	
	Data = New Map;
	Data.Insert("commits", Commits);
	
	Tests.AddRecord("ExternalRequests", ExternalRequestHandler, CheckoutSHA, Data);

	// when
	Result = ExternalRequests.RemoveCustomRoutingSettings(ExternalRequestHandler.Ref, CheckoutSHA, Commit.Get("id"));
	
	// then
	Framework.AssertEqual(Result, Default.Get("json"));

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure RemoveCustomRoutingSettings(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests");
	
	ExternalRequestHandler = Tests.NewExternalRequestHandler();
	
	CheckoutSHA = Tests.RandomString();
	
	Commit1 = Tests.NewCommit("commit1");
	Default = New Map;
	Default.Insert("json", "{""key"": ""default""}");
	Custom = New Map;
	Custom.Insert("json", "{""key"": ""custom""}");
	Commit1.Insert("settings", Default);
	Commit1.Insert("custom_settings", Custom);
	Commit2 = Tests.NewCommit("commit2");
	Commit2.Insert("custom_settings", New Map);
	Commits = New Array;
	Commits.Add(Commit1);
	Commits.Add(Commit2);
	
	Data = New Map;
	Data.Insert("commits", Commits);
	
	Tests.AddRecord("ExternalRequests", ExternalRequestHandler, CheckoutSHA, Data);

	// when
	Result = ExternalRequests.RemoveCustomRoutingSettings(ExternalRequestHandler.Ref, CheckoutSHA, Commit1.Get("id"));
	StoredData = Tests.GetRecordSet("ExternalRequests", ExternalRequestHandler, CheckoutSHA);

	// then
	Framework.AssertEqual(Result, Default.Get("json"));
	Framework.AssertEqual(StoredData[0].Data.Get().Get("commits")[0].Get("custom_settings"), Undefined);	
	Framework.AssertType(StoredData[0].Data.Get().Get("commits")[1].Get("custom_settings"), "Map");	

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCustomSettingsJSONNoCustomSettings(Framework) Export
	
	// given
	Commit = Tests.NewCommit("commit");
	Default = New Map;
	Default.Insert("json", "{""key"": ""default""}");
	Commit.Insert("settings", Default);

	// when
	Result = ExternalRequests.GetCustomSettingsJSON(Commit);

	// then
	Framework.AssertEqual(Result, Undefined);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCustomSettingsJSONNoJSON(Framework) Export
	
	// given
	Commit = Tests.NewCommit("commit");
	Default = New Map;
	Default.Insert("json", "{""key"": ""default""}");
	Custom = New Map;
	Commit.Insert("settings", Default);
	Commit.Insert("custom_settings", Custom);

	// when
	Result = ExternalRequests.GetCustomSettingsJSON(Commit);

	// then
	Framework.AssertEqual(Result, Undefined);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCustomSettingsJSON(Framework) Export
	
	// given
	Commit = Tests.NewCommit("commit");
	Default = New Map;
	Default.Insert("json", "{""key"": ""default""}");
	Custom = New Map;
	Custom.Insert("json", "{""key"": ""custom""}");
	Commit.Insert("settings", Default);
	Commit.Insert("custom_settings", Custom);

	// when
	Result = ExternalRequests.GetCustomSettingsJSON(Commit);

	// then
	Framework.AssertEqual(Result, Custom.Get("json"));

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetDefaultSettingsJSONNoSettings(Framework) Export
	
	// given
	Commit = Tests.NewCommit("commit");
	Custom = New Map;
	Custom.Insert("json", "{""key"": ""custom""}");
	Commit.Insert("custom_settings", Custom);

	// when
	Result = ExternalRequests.GetDefaultSettingsJSON(Commit);

	// then
	Framework.AssertEqual(Result, Undefined);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetDefaultSettingsJSONNoJSON(Framework) Export
	
	// given
	Commit = Tests.NewCommit("commit");
	Default = New Map;
	Custom = New Map;
	Custom.Insert("json", "{""key"": ""custom""}");
	Commit.Insert("settings", Default);
	Commit.Insert("custom_settings", Custom);

	// when
	Result = ExternalRequests.GetDefaultSettingsJSON(Commit);

	// then
	Framework.AssertEqual(Result, Undefined);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetDefaultSettingsJSON(Framework) Export
	
	// given
	Commit = Tests.NewCommit("commit");
	Default = New Map;
	Default.Insert("json", "{""key"": ""default""}");
	Custom = New Map;
	Custom.Insert("json", "{""key"": ""custom""}");
	Commit.Insert("settings", Default);
	Commit.Insert("custom_settings", Custom);

	// when
	Result = ExternalRequests.GetDefaultSettingsJSON(Commit);

	// then
	Framework.AssertEqual(Result, Default.Get("json"));

EndProcedure

#EndRegion
