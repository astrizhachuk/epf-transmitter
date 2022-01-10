#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartRunSuccess(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	
	Data = New Map;
	Data.Insert("checkout_sha", Tests.RandomString());
	
	// when
	Result = DataProcessing.Start(Tests.NewExternalRequestHandler().Ref, Data);
	
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

	Data = New Map;	
	Data.Insert("checkout_sha", Tests.RandomString());
	Data.Insert("error", New HTTPConnection("localhost"));	

	// when
	Try
		DataProcessing.Start(Tests.NewExternalRequestHandler().Ref, Data);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, "(Execute)");
	EndTry;

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartExceptionActiveJob(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	
	RequestHandler = Tests.NewExternalRequestHandler();
	
	Data = New Map;
	Data.Insert("checkout_sha", Tests.RandomString());
	
	// when
	Result = DataProcessing.Start(RequestHandler.Ref, Data);
	Try
		DataProcessing.Start(RequestHandler.Ref, Data);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, "(Execute)");
	EndTry;	

	Framework.AssertTrue(Result.State = BackgroundJobState.Active);	

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartSaveData(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");
	
	CheckoutSHA = Tests.RandomString();
	RequestHandler = Tests.NewExternalRequestHandler();
	File = Tests.NewFile("Каталог 2", "test2", "epf");

	Data = New Map;
	Data.Insert("checkout_sha", CheckoutSHA);
	Data.Insert("project", Tests.NewProject(1, RequestHandler.ProjectURL));
	Data.Insert("commits", New Map);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, File, CheckoutSHA, "modifed", Date(2020, 07, 21, 09, 22, 31));

	// when
	Result = DataProcessing.Start(RequestHandler.Ref, Data, FilesMetadata)
							.WaitForExecutionCompletion(30);
	
	Filter = New Structure();
	Filter.Insert("RequestHandler", RequestHandler.Ref);
	Filter.Insert("CheckoutSHA", CheckoutSHA);
	ExternalRequest = InformationRegisters.ExternalRequests.Get(Filter);
	FilesMetadata = InformationRegisters.RemoteFiles.Get(Filter);
		
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Completed);
	Framework.AssertEqual(ExternalRequest.Data.Get().Get("checkout_sha"), CheckoutSHA);
	Framework.AssertEqual(FilesMetadata.Data.Get()[0]["FileName"], File.FileName);
		
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartProjectDataNotFound(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");

	Data = New Map;
	Data.Insert("checkout_sha", Tests.RandomString());
	Files = Undefined;
	
	// when
	Result = DataProcessing.Start(Tests.NewExternalRequestHandler().Ref, Data, Files)
							.WaitForExecutionCompletion(5);

	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Failed);
	Framework.AssertStringContains(Result.ErrorInfo.Description, Logs.Messages().NO_POJECT_DESCRIPTION);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartCommitsNotFound(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");
	
	RequestHandler = Tests.NewExternalRequestHandler();
	
	Data = New Map;
	Data.Insert("checkout_sha", Tests.RandomString());
	Data.Insert("project", Tests.NewProject(1, RequestHandler.ProjectURL));

	// when
	Result = DataProcessing.Start(RequestHandler.Ref, Data)
							.WaitForExecutionCompletion(5);
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Failed);
	Framework.AssertStringContains(Result.ErrorInfo.Description, Logs.Messages().NO_COMMITS);

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure StartDownloadFromRemoteVCSNoRouts(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	
	Connection = Tests.NewConnection(Tests.MockURL());
	Constants.ExternalStorageToken.Set(Connection.Token);
	
	RequestHandler = Tests.NewExternalRequestHandler(, Connection.URL);	
	Files = Tests.SplitString("path/file 1.json|path/file 2.epf|path/file 3.ERF");
	
	Commits = New Array;
	Commits.Add(Tests.NewCommit("commit1",
							Date(2020, 07, 21, 09, 22, 31),
							New Array,
							Files,
							New Array));
	Commits.Add(Tests.NewCommit("commit2",
							Date(2020, 07, 21, 09, 22, 32),
							New Array,
							Files,
							New Array));
					
	Data = New Map;
	Data.Insert("checkout_sha", Tests.RandomString());
	Data.Insert("project", Tests.NewProject(1, RequestHandler.ProjectURL));
	Data.Insert("commits", Commits);

	Tests.ResetMockServer();
	Tests.SetMockGitLabDownloadFile(Connection, , 404);

	// when
	Result = DataProcessing.Start(RequestHandler.Ref, Data)
							.WaitForExecutionCompletion(60);
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Completed);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ManualRunErrorLoadDataRequestBodyNotFound(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");

	RequestHandler = Tests.NewExternalRequestHandler();
	
	Files = Tests.NewFilesMetadata();
	NewFile = Files.Add();
	NewFile.FileName = Tests.NewFileName("test2", "epf");
	
	Tests.AddRecord("RemoteFiles", RequestHandler, Tests.RandomString(), Files);

	// when
	Result = DataProcessing.Manual(RequestHandler.Ref, "fake");
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ManualRunErrorLoadDataRemoteFilesNotFound(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");

	CheckoutSHA = Tests.RandomString();	
	RequestHandler = Tests.NewExternalRequestHandler();

	Data = New Map;
	Data.Insert("checkout_sha", CheckoutSHA);
	Tests.AddRecord("ExternalRequests", RequestHandler, CheckoutSHA, Data);

	// when
	Result = DataProcessing.Manual(RequestHandler.Ref, "fake");
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ManualLoadDataSaccess(Framework) Export

	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");
	
	CheckoutSHA = Tests.RandomString();
	RequestHandler = Tests.NewExternalRequestHandler();
	
	File = Tests.NewFile("Каталог 2", "test2", "epf");

	Data = New Map;
	Data.Insert("checkout_sha", CheckoutSHA);
	Data.Insert("project", Tests.NewProject(1, RequestHandler.ProjectURL));
	Data.Insert("commits", New Map);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, File, CheckoutSHA, "modifed", Date(2020, 07, 21, 09, 22, 31));
	
	Tests.AddRecord("ExternalRequests", RequestHandler, CheckoutSHA, Data);
	Tests.AddRecord("RemoteFiles", RequestHandler, CheckoutSHA, FilesMetadata);	
	
	// when
	Result = DataProcessing.Manual(RequestHandler.Ref, CheckoutSHA);
	
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
	
	File1 = Tests.NewFile("", "routing", "json");
	Constants.RoutingFileName.Set(File1.FileName);
	
	File2 = Tests.NewFile("каталог", "file 2", "epf");
	FilePathes = Tests.GetFilePathes(File1, File2);
	
	CheckoutSHA = Tests.RandomString();
	RequestHandler = Tests.NewExternalRequestHandler();
	
	WebServices = New Array;
	WebServices.Add(Tests.NewWebService("http://endpoint1", True));

	EPF = New Array;
	EPF.Add(Tests.NewEPF(File2.FilePath));
	Commit = Tests.NewCommit(CheckoutSHA,
							Date(2020, 01, 21, 09, 22, 31),
							New Array,
							FilePathes,
							New Array);
	Commit.Insert("settings", Tests.NewRoutes(WebServices, EPF));
	Commits = New Array;
	Commits.Add(Commit);
	
	Data = New Map;
	Data.Insert("checkout_sha", CheckoutSHA);
	Data.Insert("project", Tests.NewProject(1, RequestHandler.ProjectURL));
	Data.Insert("commits", Commits);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, File1, CheckoutSHA, "", Date(2020, 01, 21, 09, 22, 31));
	Tests.AddFileMetadata(FilesMetadata, File2, CheckoutSHA, "modified", Date(2020, 01, 21, 09, 22, 31));
	
	Tests.AddRecord("ExternalRequests", RequestHandler, CheckoutSHA, Data);
	Tests.AddRecord("RemoteFiles", RequestHandler, CheckoutSHA, FilesMetadata);
	
	// when
	Result = DataProcessing.Manual(RequestHandler.Ref, CheckoutSHA)
							.WaitForExecutionCompletion(30);
	
	// then
	Framework.AssertTrue(Result.State = BackgroundJobState.Completed);
	
EndProcedure

#EndRegion
