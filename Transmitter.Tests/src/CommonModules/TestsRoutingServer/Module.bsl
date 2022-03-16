#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FillRoutesFromBinaryData(Framework) Export

	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	Constants.RoutingFileName.Set(T.FileRoutes.FileName);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, T.FileEPF, T.Expectation.Commits[0].Id, "added");
	Tests.AddFileMetadata(FilesMetadata, T.FileRoutes, T.Expectation.Commits[0].Id, "");
	Tests.AddFileMetadata(FilesMetadata, T.FileRoutes, T.Expectation.Commits[1].Id, "", , "any error");	

	// when
	Routing.FillRoutesFromBinaryData(ExternalRequest, FilesMetadata);

	// then
	Framework.AssertEqual(ExternalRequest.Routes.Count(), 1);
	Framework.AssertEqual(ExternalRequest.Routes[0].Id, T.Expectation.Commits[0].Id);
	Framework.AssertEqual(ExternalRequest.Routes[0].JSON, T.FileRoutes.Data);
	Framework.AssertFalse(ExternalRequest.Routes[0].IsCustom);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesNoRouteFile(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, T.FileEPF, T.Expectation.Commits[0].Id, "modifed");
	
	// when	
	Result = Routing.GetFilesByRoutes(ExternalRequest, FilesMetadata);
	
	// then
	Framework.AssertEqual(Result[0].CommitSHA, T.Expectation.Commits[0].Id);
	Framework.AssertEqual(Result[0].FileName, T.FileEPF.FileName);
	Framework.AssertEqual(Result[0].Routes, Undefined);
	Framework.AssertStringContains(GetStringFromBinaryData(Result[0].BinaryData), T.FileEPF.Data);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesSkipRouteFile(Framework) Export
	
	// given
	T = NewTest();
	
	WebServices = New Array;
	WebServices.Add(Tests.NewWebService("http://endpoint", True));
	EPF = New Array;
	EPF.Add(Tests.NewEPF(T.FileEPF.FilePath));
	Settings = Tests.NewRoutes(WebServices, EPF);

	NewRoutes = New Array();
	NewRoutes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, HTTPConnector.ObjectToJson(Settings), False));
	T.Expectation.Routes = NewRoutes;
		
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, T.FileRoutes, T.Expectation.Commits[0].Id, "");

	// when	
	Result = Routing.GetFilesByRoutes(ExternalRequest, FilesMetadata);
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesOneRouteBecauseExcludes(Framework) Export
	
	// given
	T = NewTest();
		
	URL1 = "http://endpoint1";
	URL2 = "http://endpoint2";
	URL3 = "http://endpoint3";
	WebServices = New Array;
	WebServices.Add(Tests.NewWebService(URL1, True));
	WebServices.Add(Tests.NewWebService(URL2, False));
	WebServices.Add(Tests.NewWebService(URL3, True));
	EPF = New Array;
	EPF.Add(Tests.NewEPF(T.FileEPF.FilePath, StrSplit(URL1 + "|" + URL2, "|", False)));
	
	Settings = Tests.NewRoutes(WebServices, EPF);
	
	NewRoutes = New Array();
	NewRoutes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, HTTPConnector.ObjectToJson(Settings), False));
	NewRoutes.Add(Tests.NewRoute(T.Expectation.Commits[1].Id, HTTPConnector.ObjectToJson(Settings), False));
	T.Expectation.Routes = NewRoutes;
	
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, T.FileEPF, T.Expectation.Commits[0].Id, "modifed");
	
	// when	
	Result = Routing.GetFilesByRoutes(ExternalRequest, FilesMetadata);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].CommitSHA, T.Expectation.Commits[0].Id);
	Framework.AssertEqual(Result[0].FileName, T.FileEPF.FileName);
	Framework.AssertEqual(Result[0].Routes.Count(), 1);
	Framework.AssertEqual(Result[0].Routes[0], URL3);
	Framework.AssertStringContains(GetStringFromBinaryData(Result[0].BinaryData), T.FileEPF.Data);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesTwoRoutes(Framework) Export
	
	// given
	T = NewTest();
	
	URL1 = "http://endpoint1";
	URL2 = "http://endpoint2";
	URL3 = "http://endpoint3";
	WebServices = New Array;
	WebServices.Add(Tests.NewWebService(URL1, True));
	WebServices.Add(Tests.NewWebService(URL2, False));
	WebServices.Add(Tests.NewWebService(URL3, True));
	EPF = New Array;
	EPF.Add(Tests.NewEPF(T.FileEPF.FilePath));
	
	Settings = Tests.NewRoutes(WebServices, EPF);

	NewRoutes = New Array();
	NewRoutes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, HTTPConnector.ObjectToJson(Settings), False));
	NewRoutes.Add(Tests.NewRoute(T.Expectation.Commits[1].Id, HTTPConnector.ObjectToJson(Settings), False));
	T.Expectation.Routes = NewRoutes;
	
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, T.FileEPF, T.Expectation.Commits[0].Id, "modifed");
	
	// when	
	Result = Routing.GetFilesByRoutes(ExternalRequest, FilesMetadata);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].CommitSHA, T.Expectation.Commits[0].Id);
	Framework.AssertEqual(Result[0].FileName, T.FileEPF.FileName);
	Framework.AssertEqual(Result[0].Routes.Count(), 2);
	Framework.AssertEqual(Result[0].Routes[0], URL3);
	Framework.AssertEqual(Result[0].Routes[1], URL1);
	Framework.AssertStringContains(GetStringFromBinaryData(Result[0].BinaryData), T.FileEPF.Data);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesNoFileInSettings(Framework) Export
	
	// given
	File1 = Tests.NewFile("каталог", "файл 1", "epf");
	File2 = Tests.NewFile("каталог", "файл 2", "epf");
	
	WebServices = New Array;
	WebServices.Add(Tests.NewWebService("http://endpoint", True));
	EPF = New Array;
	EPF.Add(Tests.NewEPF(File1.FilePath));
	Settings = Tests.NewRoutes(WebServices, EPF);
	
	T = NewTest();
	NewRoutes = New Array();
	NewRoutes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, HTTPConnector.ObjectToJson(Settings), False));
	T.Expectation.Routes = NewRoutes;
	
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, File2, T.Expectation.Commits[0].Id, "modifed");	
	
	// when	
	Result = Routing.GetFilesByRoutes(ExternalRequest, FilesMetadata);
	
	// then
	Framework.AssertEqual(Result[0].CommitSHA, T.Expectation.Commits[0].Id);
	Framework.AssertEqual(Result[0].FileName, File2.FileName);
	Framework.AssertEqual(Result[0].Routes, Undefined);
	Framework.AssertStringContains(GetStringFromBinaryData(Result[0].BinaryData), File2.Data);
	
EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure AddCustomRoute(Framework) Export
	
	// given
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	RequestHandler = Tests.NewExternalRequestHandler();
	Tests.AddRecord("ExternalRequests", RequestHandler, T.Expectation.CheckoutSHA, T.Expectation);
	
	// when
	Routing.AddCustomRoute(RequestHandler.Ref, T.Expectation.CheckoutSHA, T.Expectation.Commits[0].Id, "{}");
	Result = Tests.GetRecordSet("ExternalRequests", RequestHandler, T.Expectation.CheckoutSHA)[0].Data.Get();

	// then
	Framework.AssertTrue(Result.Routes.Count() = 1);
	Framework.AssertEqual(Result.Routes[0].Id, T.Expectation.Commits[0].Id);
	
EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure AddCustomRouteException(Framework) Export
	
	// given
	T = NewTest();

	RequestHandler = Tests.NewExternalRequestHandler();

	// when
	Try
		Routing.AddCustomRoute(RequestHandler.Ref, T.Expectation.CheckoutSHA, T.Expectation.Commits[0].Id, "text format");
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, "(ReadJSON)");
	EndTry;
	
EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure RemoveCustomRoute(Framework) Export
	
	// given
	JSON1 = "{""key1"": ""value1""}";
	JSON2 = "{""key2"": ""value2""}";
	
	T = NewTest();
	NewRoutes = New Array();
	NewRoutes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, JSON1, False));
	NewRoutes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, JSON2, True));
	T.Expectation.Routes = NewRoutes;
	
	RequestHandler = Tests.NewExternalRequestHandler();
	Tests.AddRecord("ExternalRequests", RequestHandler, T.Expectation.CheckoutSHA, T.Expectation);
	
	// when
	Result = Routing.RemoveCustomRoute(RequestHandler.Ref, T.Expectation.CheckoutSHA, T.Expectation.Commits[0].Id);
	Record = Tests.GetRecordSet("ExternalRequests", RequestHandler, T.Expectation.CheckoutSHA)[0].Data.Get();

	// then
	Framework.AssertTrue(Record.Routes.Count() = 1);
	Framework.AssertEqual(Result, JSON1);
	
EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure RemoveCustomRouteNotFound(Framework) Export
	
	// given
	JSON = "{""key1"": ""value1""}";
	
	T = NewTest();
	NewRoutes = New Array();
	NewRoutes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, JSON, False));
	T.Expectation.Routes = NewRoutes;
	
	RequestHandler = Tests.NewExternalRequestHandler();
	Tests.AddRecord("ExternalRequests", RequestHandler, T.Expectation.CheckoutSHA, T.Expectation);
	
	// when
	Result = Routing.RemoveCustomRoute(RequestHandler.Ref, T.Expectation.CheckoutSHA, T.Expectation.Commits[0].Id);
	Record = Tests.GetRecordSet("ExternalRequests", RequestHandler, T.Expectation.CheckoutSHA)[0].Data.Get();

	// then
	Framework.AssertTrue(Record.Routes.Count() = 1);
	Framework.AssertEqual(Result, JSON);
	
EndProcedure

#EndRegion

#Region Private

Function NewGitLabExternalRequest()
	
	Result = DataProcessors.ExternalRequest.Create();
	Result.Type = Enums.RequestSource.GitLab;
	
	Return Result;
	
EndFunction

Procedure FillInstance(ExternalRequest, T)

	FillPropertyValues(ExternalRequest, T.Expectation);
	
	For Each Commit In T.Expectation.Commits Do
		NewCommit = ExternalRequest.Commits.Add();
		FillPropertyValues(NewCommit, Commit);
	EndDo;
	
	For Each Route In T.Expectation.Routes Do
		NewRoute = ExternalRequest.Routes.Add();
		FillPropertyValues(NewRoute, Route); 
	EndDo;
	
EndProcedure

Function NewTest()
	
	Result = New Structure();
	
	Result.Insert("FileEPF", Tests.NewFile("каталог", "файл", "epf"));
	Result.Insert("FileRoutes", Tests.NewFile("", ".ext-epf", "json"));
	
	Expectation = New Structure();
	Expectation.Insert("Type", Enums.RequestSource.GitLab);
	Expectation.Insert("ProjectId", "1");
	Expectation.Insert("CheckoutSHA", Tests.RandomString());
	
	CurrentSessionDate = CurrentSessionDate();
	Commits = New Array();
	Commits.Add(Tests.NewCommit(Tests.RandomString(), CurrentSessionDate));
	Commits.Add(Tests.NewCommit(Tests.RandomString(), CurrentSessionDate + 1));
	Commits.Add(Tests.NewCommit(Tests.RandomString(), CurrentSessionDate + 2));
	Expectation.Insert("Commits", Commits);
	Expectation.Insert("ModifiedFiles", New Array());
	Expectation.Insert("Routes", New Array());
	
	Result.Insert("Expectation", Expectation);

	Return Result;
	
EndFunction	

#EndRegion
