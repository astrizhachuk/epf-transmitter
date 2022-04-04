// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartRunSuccess(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	// when
	Result = DataProcessing.Start(T.RequestHandler.Ref, ExternalRequest);
	
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Active);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartException(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	// when
	Try
		DataProcessing.Start(T.RequestHandler.Ref, ExternalRequest, New HTTPConnection("localhost"));
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Cause.Description, NStr("ru = 'Параметр фонового задания не поддерживает сериализацию'"));
	EndTry;

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartExceptionActiveJob(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	// when
	Result = DataProcessing.Start(T.RequestHandler.Ref, ExternalRequest);
	Try
		DataProcessing.Start(T.RequestHandler.Ref, ExternalRequest);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Cause.Description, NStr("ru = 'Задание с таким значением ключа уже выполняется'"));
	EndTry;	

	Framework.AssertTrue(Result.State = BackgroundJobState.Active);	

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartDumpData(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");
	
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, T.FileEPF, T.Expectation.Commits[0].Id, "modifed", T.Expectation.Commits[0].Date);

	// when
	Result = DataProcessing.Start(T.RequestHandler.Ref, ExternalRequest, FilesMetadata)
							.WaitForExecutionCompletion(30);
	
	Filter = New Structure();
	Filter.Insert("RequestHandler", T.RequestHandler.Ref);
	Filter.Insert("CheckoutSHA", T.Expectation.CheckoutSHA);
	
	ExternalRequestRegister = InformationRegisters.ExternalRequests.Get(Filter);
	FilesMetadataRegister = InformationRegisters.RemoteFiles.Get(Filter);
		
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Completed);
	Framework.AssertEqual(ExternalRequestRegister.Data.Get().CheckoutSHA, T.Expectation.CheckoutSHA);
	Framework.AssertTrue(ExternalRequestRegister.Data.Get().Commits.Count() > 0);
	Framework.AssertTrue(ExternalRequestRegister.Data.Get().ModifiedFiles.Count() > 0);
	Framework.AssertTrue(ExternalRequestRegister.Data.Get().Routes.Count() > 0);	
	Framework.AssertEqual(FilesMetadataRegister.Data.Get()[0]["FileName"], T.FileEPF.FileName);
		
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartDownloadFromRemoteVCSNoRouts(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	Constants.GitLabToken.Set(T.Connection.Token);

	// when
	Result = DataProcessing.Start(T.RequestHandler.Ref, ExternalRequest).WaitForExecutionCompletion(60);
	
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Failed);
	Framework.AssertStringContains(Result.ErrorInfo.Description, Logs.Messages().NO_UPLOAD_DATA);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ManualRunLoadDataErrorRequestBodyNotFound(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");

	// when
	Result = DataProcessing.Manual(Tests.NewExternalRequestHandler().Ref, Tests.RandomString());
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ManualRunLoadDataErrorRemoteFilesNotFound(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");
	
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	Tests.AddRecord("ExternalRequests", T.RequestHandler, T.Expectation.CheckoutSHA, ExternalRequest.ToCollection());

	// when
	Result = DataProcessing.Manual(T.RequestHandler.Ref, T.Expectation.CheckoutSHA);
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ManualRunLoadDataSuccess(Framework) Export

	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");
	
	T = NewTest();
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, T.FileEPF, T.Expectation.Commits[0].Id, "modifed", T.Expectation.Commits[0].Date);
	
	Tests.AddRecord("ExternalRequests", T.RequestHandler, T.Expectation.CheckoutSHA, ExternalRequest.ToCollection());
	Tests.AddRecord("RemoteFiles", T.RequestHandler, T.Expectation.CheckoutSHA, FilesMetadata);	
	
	// when
	Result = DataProcessing.Manual(T.RequestHandler.Ref, T.Expectation.CheckoutSHA);
	
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Active);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ManualRunCompleted(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");
	
	T = NewTest();
	
	EPF = New Array;
	EPF.Add(Tests.NewEPF(T.FileEPF.FilePath));
	WebServices = New Array;
	WebServices.Add(Tests.NewWebService("http://endpoint1", True));
	Settings = Tests.NewRoutes(WebServices, EPF);
	
	NewRoutes = New Array();
	NewRoutes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, HTTPConnector.ObjectToJson(Settings), False));
	T.Expectation.Routes = NewRoutes;
	
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, T.FileRoutes, T.Expectation.Commits[0].Id, "", T.Expectation.Commits[0].Date);
	Tests.AddFileMetadata(FilesMetadata, T.FileEPF, T.Expectation.Commits[0].Id, "modifed", T.Expectation.Commits[0].Date);
	
	Tests.AddRecord("ExternalRequests", T.RequestHandler, T.Expectation.CheckoutSHA, ExternalRequest.ToCollection());
	Tests.AddRecord("RemoteFiles", T.RequestHandler, T.Expectation.CheckoutSHA, FilesMetadata);	
	
	// when
	Result = DataProcessing.Manual(T.RequestHandler.Ref, T.Expectation.CheckoutSHA).WaitForExecutionCompletion(30);
	
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Completed);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetBackgroundsByCommit(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");
	
	T = NewTest();
	
	EPF = New Array;
	EPF.Add(Tests.NewEPF(T.FileEPF.FilePath));
	WebServices = New Array;
	WebServices.Add(Tests.NewWebService("http://endpoint1", True));
	Settings = Tests.NewRoutes(WebServices, EPF);
	
	NewRoutes = New Array();
	NewRoutes.Add(Tests.NewRoute(T.Expectation.Commits[0].Id, HTTPConnector.ObjectToJson(Settings), False));
	T.Expectation.Routes = NewRoutes;
	
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);

	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, T.FileRoutes, T.Expectation.Commits[0].Id, "", T.Expectation.Commits[0].Date);
	Tests.AddFileMetadata(FilesMetadata, T.FileEPF, T.Expectation.Commits[0].Id, "modifed", T.Expectation.Commits[0].Date);
	
	Tests.AddRecord("ExternalRequests", T.RequestHandler, T.Expectation.CheckoutSHA, ExternalRequest.ToCollection());
	Tests.AddRecord("RemoteFiles", T.RequestHandler, T.Expectation.CheckoutSHA, FilesMetadata);	
	
	DataProcessing.Manual(T.RequestHandler.Ref, T.Expectation.CheckoutSHA).WaitForExecutionCompletion(30);
	
	// when
	Result = DataProcessing.GetBackgroundsByCommit(T.Expectation.CheckoutSHA);
	
	// then
	Framework.AssertTrue(StrStartsWith(Result[0].Key, T.Expectation.CheckoutSHA));
	Framework.AssertTrue(StrStartsWith(Result[1].Key, T.Expectation.CheckoutSHA));
	
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
	Result.Insert("Connection", Tests.NewConnection(Tests.MockURL()));
	Result.Insert("FileRoutes", Tests.NewFile("", ".ext-epf", "json"));
	Result.Insert("FileEPF", Tests.NewFile("каталог", "файл", "epf"));
	Result.Insert("RequestHandler", Tests.NewExternalRequestHandler(, Result.Connection.URL));
	
	Expectation = New Structure();
	Expectation.Insert("Type", Enums.RequestSource.GitLab);
	Expectation.Insert("ProjectId", "1");
	Expectation.Insert("ProjectURL", Result.RequestHandler.ProjectURL);
	Expectation.Insert("CheckoutSHA", Tests.RandomString());
	
	CurrentSessionDate = CurrentSessionDate();
	Commits = New Array();
	Commits.Add(Tests.NewCommit(Expectation.CheckoutSHA, CurrentSessionDate));
	Commits.Add(Tests.NewCommit(Tests.RandomString(), CurrentSessionDate + 1));
	Expectation.Insert("Commits", Commits);
	
	ModifiedFiles = New Array();
	ModifiedFiles.Add(NewModifiedFile(Commits[0].Id, Result.FileEPF.FilePath));
	Expectation.Insert("ModifiedFiles", ModifiedFiles);
	
	Routes = New Array();
	Routes.Add(Tests.NewRoute(Commits[0].Id, "{}", False));
	Expectation.Insert("Routes", Routes);
	
	Result.Insert("Expectation", Expectation);

	Return Result;
	
EndFunction

#EndRegion
