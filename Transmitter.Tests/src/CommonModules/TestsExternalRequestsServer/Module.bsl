// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure CreateSourceTypeException(Framework) Export
	
	// given

	// when
	Try
		ExternalRequests.Create(New Array);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, NStr("ru = 'неизвестный тип источника запроса';en = 'unknown request source type'"));
	EndTry;

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure CreateFromJSONNoTypeException(Framework) Export
	
	// given

	// when
	Try
		ExternalRequests.Create("");
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, NStr("ru = 'неизвестный тип источника запроса';en = 'unknown request source type'"));
	EndTry;

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure CreateFromGitLabJSON(Framework) Export
	
	// given

	// when
	Result = ExternalRequests.Create("{}", "giTlAb");

	// then
	Framework.AssertEqual(Result.Type, Enums.RequestSource.GitLab);
	Framework.AssertNotFilled(Result.ProjectId);
	Framework.AssertNotFilled(Result.Commits);	
	Framework.AssertNotFilled(Result.ModifiedFiles);
	Framework.AssertNotFilled(Result.Routes);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure CreateFromInstance(Framework) Export
	
	// given
	T = NewTest();

	// when
	Result = ExternalRequests.Create(T.Expectation);

	// then
	Framework.AssertEqual(Result.Type, T.Expectation.Type);
	Framework.AssertFilled(Result.ProjectId);
	Framework.AssertFilled(Result.Commits);	
	Framework.AssertFilled(Result.ModifiedFiles);
	Framework.AssertFilled(Result.Routes);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetObjectFromIB(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests");
	
	T = NewTest();
	
	Tests.AddRecord("ExternalRequests", T.RequestHandler, T.Expectation.CheckoutSHA, T.Expectation);
	
	// when	
	Result = ExternalRequests.GetObjectFromIB(T.RequestHandler.Ref, T.Expectation.CheckoutSHA);
	
	// then
	Framework.AssertEqual(Result.Type, T.Expectation.Type);
	Framework.AssertFilled(Result.ProjectId);
	Framework.AssertFilled(Result.Commits);	
	Framework.AssertFilled(Result.ModifiedFiles);
	Framework.AssertFilled(Result.Routes);
		
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetObjectFromIBNoData(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests");
	
	T = NewTest();
	
	// when	
	Result = ExternalRequests.GetObjectFromIB(T.RequestHandler.Ref, T.Expectation.CheckoutSHA);
	
	// then
	Framework.AssertNotFilled(Result);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SaveObject(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests");
	
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	// when	
	ExternalRequests.SaveObject(T.RequestHandler.Ref, T.Expectation.CheckoutSHA, ExternalRequest);
	Result = Tests.GetRecordSet("ExternalRequests", T.RequestHandler, T.Expectation.CheckoutSHA)[0].Data.Get();
	
	// then
	Framework.AssertEqual(Result.Type, T.Expectation.Type);
	Framework.AssertFilled(Result.ProjectId);
	Framework.AssertFilled(Result.Commits);	
	Framework.AssertFilled(Result.ModifiedFiles);
	Framework.AssertFilled(Result.Routes);	
	
EndProcedure

#EndRegion

#Region Private

Function NewGitLabExternalRequest()
	
	Result = DataProcessors.ExternalRequest.Create();
	Result.Type = Enums.RequestSource.GitLab;
	
	Return Result;

EndFunction

Function NewModifiedFile(Val Id, Val FilePath)
	
	Result = New Structure;
	Result.Insert("Id", Id);
	Result.Insert("FilePath", FilePath);
	
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
	
	Result.Insert("RequestHandler", Tests.NewExternalRequestHandler());
	
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
	
	ModifiedFiles = New Array();
	ModifiedFiles.Add(NewModifiedFile(Commits[0].Id, "путь/file1.epf"));
	ModifiedFiles.Add(NewModifiedFile(Commits[1].Id, "путь/file2.epf"));
	ModifiedFiles.Add(NewModifiedFile(Commits[2].Id, "путь/file3.epf"));
	Expectation.Insert("ModifiedFiles", ModifiedFiles);

	Routes = New Array();
	Routes.Add(Tests.NewRoute(Commits[0].Id, "{}", False));
	Expectation.Insert("Routes", Routes);
	
	Result.Insert("Expectation", Expectation);

	Return Result;
	
EndFunction

#EndRegion
