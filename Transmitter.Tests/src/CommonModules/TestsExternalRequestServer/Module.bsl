// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FillDataTypeException(Framework) Export
	
	// given

	// when
	Try
		ExternalRequest = NewGitLabExternalRequest();
		ExternalRequest.Fill(New Array);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, NStr("ru = 'недопустимый тип данных';en = 'invalid data type'"));
	EndTry;

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FillDeserializationException(Framework) Export
	
	// given

	// when
	Try
		ExternalRequest = NewGitLabExternalRequest();
		ExternalRequest.Fill("<>");
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, "(ReadJSON)");
	EndTry;

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure Fill(Framework) Export
	
	// given
	T = NewTest();

	// when
	ExternalRequest = NewGitLabExternalRequest();
	ExternalRequest.Fill(T.JSON);

	// then
	AssertInstance(Framework, ExternalRequest, T);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure Load(Framework) Export
	
	// given
	T = NewTest();

	// when
	ExternalRequest = DataProcessors.ExternalRequest.Create();
	ExternalRequest.Load(T.Expectation);

	// then
	AssertInstance(Framework, ExternalRequest, T);
	AssertRoutes(Framework, ExternalRequest, T);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure Verify(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	ExternalRequest.Verify();

	// then
	AssertInstance(Framework, ExternalRequest, T);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure VerifyJSON(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	ExternalRequest.JSON = "";

	// when
	Try
		ExternalRequest.Verify();
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
Procedure VerifyProjectId(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	ExternalRequest.ProjectId = "";

	// when
	Try
		ExternalRequest.Verify();
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
Procedure VerifyCheckoutSHA(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	ExternalRequest.CheckoutSHA = "";

	// when
	Try
		ExternalRequest.Verify();
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_CHECKOUT_SHA);
	EndTry;

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure VerifyProjectURL(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	ExternalRequest.ProjectURL = "";

	// when
	Try
		ExternalRequest.Verify();
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
Procedure VerifyServerURL(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	ExternalRequest.ServerURL = "";

	// when
	Try
		ExternalRequest.Verify();
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
Procedure GetJSON(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	Result = ExternalRequest.GetJSON();

	// then
	Framework.AssertEqual(Result, T.JSON);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetProjectId(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	Result = ExternalRequest.GetProjectId();

	// then
	Framework.AssertEqual(Result, T.Expectation.ProjectId);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetProjectURL(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	Result = ExternalRequest.GetProjectURL();

	// then
	Framework.AssertEqual(Result, T.Expectation.ProjectURL);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetServerURL(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	Result = ExternalRequest.GetServerURL();

	// then
	Framework.AssertEqual(Result, T.Expectation.ServerURL);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCheckoutSHA(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	Result = ExternalRequest.GetCheckoutSHA();

	// then
	Framework.AssertEqual(Result, T.Expectation.CheckoutSHA);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCommits(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	Result = ExternalRequest.GetCommits();

	// then
	Framework.AssertTrue(Result.Count() > 0);
	Framework.AssertEqual(Result.Count(), T.Expectation.Commits.Count());

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCommitsException(Framework) Export
	
	// given
	ExternalRequest = NewGitLabExternalRequest();

	// when
	Try
		ExternalRequest.GetCommits();
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
Procedure GetCommit(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	Result = ExternalRequest.GetCommit(T.Expectation.Commits[0].Id);
	
	// then
	Framework.AssertEqual(Result.Id, T.Expectation.Commits[0].Id);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCommitException(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	Try
		ExternalRequest.GetCommit("");
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
Procedure GetModifiedFiles(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	Result = ExternalRequest.GetModifiedFiles();

	// then
	Framework.AssertEqual(Result[0].Id, T.Expectation.ModifiedFiles[0].Id);
	Framework.AssertEqual(Result[0].Date, T.Expectation.Commits[0].Date);
	Framework.AssertEqual(Result[0].FilePath, T.Expectation.ModifiedFiles[0].FilePath);
	
	Framework.AssertEqual(Result[1].Id, T.Expectation.ModifiedFiles[1].Id);
	Framework.AssertEqual(Result[1].Date, T.Expectation.Commits[1].Date);
	Framework.AssertEqual(Result[1].FilePath, T.Expectation.ModifiedFiles[1].FilePath);
	
	Framework.AssertEqual(Result[2].Id, T.Expectation.ModifiedFiles[2].Id);
	Framework.AssertEqual(Result[2].Date, T.Expectation.Commits[2].Date);
	Framework.AssertEqual(Result[2].FilePath, T.Expectation.ModifiedFiles[2].FilePath);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ToCollection(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	Result = ExternalRequest.ToCollection();

	// then
	AssertInstance(Framework, Result, T);
	AssertRoutes(Framework, Result, T);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetRouteJSON(Framework) Export
	
	// given
	T = NewTest();
	Routes = New Array();
	Routes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, T.Expectation.JSON, True));
	Routes.Add(Tests.NewRoute(T.Expectation.Commits[1].Id, T.Expectation.JSON, False));
	T.Expectation.Routes = Routes;
	
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	// when
	Result = ExternalRequest.GetRouteJSON(T.Expectation.Commits[0].Id, True);

	// then
	Framework.AssertEqual(Result, T.Expectation.JSON);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetRouteJSONNotFound(Framework) Export
	
	// given
	T = NewTest();
	Routes = New Array();
	Routes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, T.Expectation.JSON, True));
	Routes.Add(Tests.NewRoute(T.Expectation.Commits[1].Id, T.Expectation.JSON, False));
	T.Expectation.Routes = Routes;
	
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	// when
	Result = ExternalRequest.GetRouteJSON(T.Expectation.Commits[0].Id, False);

	// then
	Framework.AssertEqual(Result, "");
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure AddRoute(Framework) Export

	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	ExternalRequest.Routes.Clear();
	
	// when
	ExternalRequest.AddRoute(T.Expectation.Commits[0].Id, T.Expectation.JSON, True);
	ExternalRequest.AddRoute(T.Expectation.Commits[0].Id, T.Expectation.JSON);

	// then
	Framework.AssertEqual(ExternalRequest.Routes.Count(), 2);
	Framework.AssertEqual(ExternalRequest.Routes[0].Id, T.Expectation.Commits[0].Id);
	Framework.AssertEqual(ExternalRequest.Routes[0].JSON, T.Expectation.JSON);
	Framework.AssertTrue(ExternalRequest.Routes[0].IsCustom);
	Framework.AssertEqual(ExternalRequest.Routes[1].Id, T.Expectation.Commits[0].Id);
	Framework.AssertEqual(ExternalRequest.Routes[1].JSON, T.Expectation.JSON);
	Framework.AssertFalse(ExternalRequest.Routes[1].IsCustom);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure AddRouteReWrite(Framework) Export

	// given
	JSON = "{""key"": ""value""}";
	
	T = NewTest();
	Routes = New Array();
	Routes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, T.Expectation.JSON, False));
	Routes.Add(Tests.NewRoute(T.Expectation.Commits[1].Id, JSON, True));
	T.Expectation.Routes = Routes;
	
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	// when
	ExternalRequest.AddRoute(T.Expectation.Commits[0].Id, JSON);
	ExternalRequest.AddRoute(T.Expectation.Commits[1].Id, T.Expectation.JSON, True);
	
	// then
	Framework.AssertEqual(ExternalRequest.Routes.Count(), 2);
	Framework.AssertEqual(ExternalRequest.Routes[0].Id, T.Expectation.Commits[0].Id);
	Framework.AssertEqual(ExternalRequest.Routes[0].JSON, JSON);
	Framework.AssertFalse(ExternalRequest.Routes[0].IsCustom);
	Framework.AssertEqual(ExternalRequest.Routes[1].Id, T.Expectation.Commits[1].Id);
	Framework.AssertEqual(ExternalRequest.Routes[1].JSON, T.Expectation.JSON);
	Framework.AssertTrue(ExternalRequest.Routes[1].IsCustom);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure RemoveRoute(Framework) Export

	// given
	T = NewTest();
	Routes = New Array();
	Routes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, T.Expectation.JSON, False));
	Routes.Add(Tests.NewRoute(T.Expectation.Commits[1].Id, T.Expectation.JSON, False));
	T.Expectation.Routes = Routes;

	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	ExternalRequest.RemoveRoute(T.Expectation.Commits[0].Id);
	
	// then
	Framework.AssertEqual(ExternalRequest.Routes.Count(), 1);
	Framework.AssertEqual(ExternalRequest.Routes[0].Id, T.Expectation.Commits[1].Id);
	Framework.AssertEqual(ExternalRequest.Routes[0].JSON, T.Expectation.JSON);
	Framework.AssertFalse(ExternalRequest.Routes[0].IsCustom);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure RemoveRouteCustom(Framework) Export

	// given
	T = NewTest();
	Routes = New Array();
	Routes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, T.Expectation.JSON, True));
	Routes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, T.Expectation.JSON, False));
	T.Expectation.Routes = Routes;
	
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	// when
	ExternalRequest.RemoveRoute(T.Expectation.Commits[0].Id, True);
	
	// then
	Framework.AssertEqual(ExternalRequest.Routes.Count(), 1);
	Framework.AssertEqual(ExternalRequest.Routes[0].Id, T.Expectation.Commits[0].Id);
	Framework.AssertEqual(ExternalRequest.Routes[0].JSON, T.Expectation.JSON);
	Framework.AssertFalse(ExternalRequest.Routes[0].IsCustom);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetActualRoutesNoData(Framework) Export

	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	ExternalRequest.Routes.Clear();

	// when
	Result = ExternalRequest.GetActualRoutes();
	
	// then
	Framework.AssertEqual(Result.Count(), 0);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetActualRoutes(Framework) Export

	// given
	JSON1 = "{""key1"": ""value1""}";
	JSON2 = "{""key2"": ""value2""}";
	
	T = NewTest();
	Routes = New Array();
	Routes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, JSON1, True));
	Routes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, T.Expectation.JSON, False));
	Routes.Add(Tests.NewRoute(T.Expectation.Commits[1].Id, JSON2, False));
	T.Expectation.Routes = Routes;

	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	Result = ExternalRequest.GetActualRoutes();
	
	// then
	Framework.AssertEqual(Result.Count(), 2);
	Framework.AssertTrue(Result.Get(T.Expectation.Commits[0].Id).IsCustom);
	Framework.AssertEqual(Result.Get(T.Expectation.Commits[0].Id).Data.Get("key1"), "value1");
	Framework.AssertFalse(Result.Get(T.Expectation.Commits[1].Id).IsCustom);
	Framework.AssertEqual(Result.Get(T.Expectation.Commits[1].Id).Data.Get("key2"), "value2");

EndProcedure

#EndRegion

#Region Private

Function NewGitLabExternalRequest()
	
	Result = DataProcessors.ExternalRequest.Create();
	Result.Type = Enums.RequestSource.GitLab;
	
	Return Result;
	
EndFunction

Function NewModifiedFile(Val Commit, Val Position)
	
	Result = New Structure;
	Result.Insert("Id", Commit.Get("id"));
	Result.Insert("FilePath", Commit.Get("modified")[Position]);
	
	Return Result;
	
EndFunction

Procedure FillInstance(ExternalRequest, T)

	FillPropertyValues(ExternalRequest, T.Expectation);
	
	For Each Commit In T.Expectation.Commits Do
		NewCommit = ExternalRequest.Commits.Add();
		FillPropertyValues(NewCommit, Commit);
	EndDo;
	
	For Each ModifiedFile In T.Expectation.ModifiedFiles Do
		NewModifiedFile = ExternalRequest.ModifiedFiles.Add();
		FillPropertyValues(NewModifiedFile, ModifiedFile); 
	EndDo;
	
	For Each Route In T.Expectation.Routes Do
		NewRoute = ExternalRequest.Routes.Add();
		FillPropertyValues(NewRoute, Route); 
	EndDo;
	
EndProcedure

Function NewTest()
	
	Result = New Structure();
	Result.Insert("JSON", Tests.GetJSON("/test/requests/push-1b9949a2.json"));
	Result.Insert("JSONAsObject", Tests.JsonToObject(Result.JSON));
	
	Expectation = New Structure();
	Expectation.Insert("Type", Enums.RequestSource.GitLab);
	Expectation.Insert("JSON", Result.JSON);
	Expectation.Insert("ProjectId", String(Result.JSONAsObject.Get("project").Get("id")));
	Expectation.Insert("ProjectURL", Result.JSONAsObject.Get("project").Get("web_url"));
	Expectation.Insert("ServerURL", "http://mockserver:1080");
	Expectation.Insert("CheckoutSHA", Result.JSONAsObject.Get("checkout_sha"));
	
	Commits = New Array();
	Commits.Add(Tests.NewCommit(Result.JSONAsObject.Get("commits")[0].Get("id"), Result.JSONAsObject.Get("commits")[0].Get("timestamp")));
	Commits.Add(Tests.NewCommit(Result.JSONAsObject.Get("commits")[1].Get("id"), Result.JSONAsObject.Get("commits")[1].Get("timestamp")));
	Commits.Add(Tests.NewCommit(Result.JSONAsObject.Get("commits")[2].Get("id"), Result.JSONAsObject.Get("commits")[2].Get("timestamp")));
	Expectation.Insert("Commits", Commits);
	
	ModifiedFiles = New Array();
	ModifiedFiles.Add(NewModifiedFile(Result.JSONAsObject.Get("commits")[0], 3));
	ModifiedFiles.Add(NewModifiedFile(Result.JSONAsObject.Get("commits")[1], 3));
	ModifiedFiles.Add(NewModifiedFile(Result.JSONAsObject.Get("commits")[2], 2));
	Expectation.Insert("ModifiedFiles", ModifiedFiles);
	
	Routes = New Array();
	Routes.Add(Tests.NewRoute(Result.JSONAsObject.Get("commits")[0].Get("id"), "{}", False));
	Routes.Add(Tests.NewRoute(Result.JSONAsObject.Get("commits")[1].Get("id"), "{}", True));
	Expectation.Insert("Routes", Routes);
	
	Result.Insert("Expectation", Expectation);
	
	Return Result;
	
EndFunction

Procedure AssertInstance(Framework, Actual, T)
	
	Framework.AssertEqual(Actual.Type, T.Expectation.Type);
	Framework.AssertEqual(Actual.JSON, T.Expectation.JSON);
	Framework.AssertEqual(Actual.ProjectId, T.Expectation.ProjectId);
	Framework.AssertEqual(Actual.ProjectURL, T.Expectation.ProjectURL);
	Framework.AssertEqual(Actual.ServerURL, T.Expectation.ServerURL);
	Framework.AssertEqual(Actual.CheckoutSHA, T.Expectation.CheckoutSHA);
	Framework.AssertTrue(Actual.Commits.Count() > 0);
	Framework.AssertEqual(Actual.Commits.Count(), T.Expectation.Commits.Count());
	Framework.AssertEqual(Actual.ModifiedFiles.Count(), T.Expectation.ModifiedFiles.Count());
	Framework.AssertNotEqual(Actual.ModifiedFiles[0].Id, Actual.ModifiedFiles[1].Id);
	Framework.AssertNotEqual(Actual.ModifiedFiles[0].Id, Actual.ModifiedFiles[2].Id);
	Framework.AssertEqual(Actual.ModifiedFiles[0].FilePath, T.Expectation.ModifiedFiles[0].FilePath);
	Framework.AssertEqual(Actual.ModifiedFiles[1].FilePath, T.Expectation.ModifiedFiles[1].FilePath);
	Framework.AssertEqual(Actual.ModifiedFiles[2].FilePath, T.Expectation.ModifiedFiles[2].FilePath);
	
EndProcedure

Procedure AssertRoutes(Framework, Actual, T)
	
	Framework.AssertTrue(Actual.Routes.Count() > 0);
	Framework.AssertEqual(Actual.Routes.Count(), T.Expectation.Routes.Count());
	Framework.AssertEqual(Actual.Routes[0].Id, T.Expectation.Routes[0].Id);
	Framework.AssertEqual(Actual.Routes[1].Id, T.Expectation.Routes[1].Id);
	
EndProcedure

#EndRegion
