// BSLLS-off
#Region Public

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFromRemoteVCSGitLabNoModifiedFiles(Framework) Export
	
	// given
	T = NewTest();
	Constants.RoutingFileName.Set(T.FileRoutes.FileName);
	Constants.ExternalStorageToken.Set(T.Connection.Token);
	
	ExternalRequest = NewGitLabExternalRequest();
	FillInstance(ExternalRequest, T);
	
	Tests.ResetMockServer();
	Tests.SetMockGitLabDownloadFile(T.Connection, T.FileRoutes, 200);
						
	// when
	Result = RemoteFiles.GetFromRemoteVCS(ExternalRequest);
	
	// then
	Framework.AssertEqual(Result.Count(), 3);
	CheckRow(Framework, Result[0], T.FileRoutes, T.Expectation.Commits[0], "");
	CheckRow(Framework, Result[1], T.FileRoutes, T.Expectation.Commits[1], "");
	CheckRow(Framework, Result[2], T.FileRoutes, T.Expectation.Commits[2], "");
	
EndProcedure

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFromRemoteVCSGitLabModifiedFiles(Framework) Export
	
	// given
	T = NewTest();
	Constants.RoutingFileName.Set(T.FileRoutes.FileName);
	Constants.ExternalStorageToken.Set(T.Connection.Token);
	
	ExternalRequest = NewGitLabExternalRequest();
	
	ModifiedFiles = New Array();
	ModifiedFiles.Add(NewModifiedFile(T.Expectation.Commits[0].Id, T.FileEPF.FilePath));
	ModifiedFiles.Add(NewModifiedFile(T.Expectation.Commits[1].Id, T.FileEPF.FilePath));
	ModifiedFiles.Add(NewModifiedFile(T.Expectation.Commits[2].Id, T.FileERF.FilePath));
	T.Expectation.ModifiedFiles = ModifiedFiles;
	
	FillInstance(ExternalRequest, T);
	
	Tests.ResetMockServer();
	Tests.SetMockGitLabDownloadFile(T.Connection, T.FileRoutes, 200);
	Tests.SetMockGitLabDownloadFile(T.Connection, T.FileEPF, 200);	
	Tests.SetMockGitLabDownloadFile(T.Connection, T.FileERF, 200);
		
	// when
	Result = RemoteFiles.GetFromRemoteVCS(ExternalRequest);
	
	// then
	Framework.AssertEqual(Result.Count(), 5);
	
	CheckRow(Framework, Result[0], T.FileEPF, T.Expectation.Commits[1], "modified");
	CheckRow(Framework, Result[1], T.FileERF, T.Expectation.Commits[2], "modified");
	CheckRow(Framework, Result[2], T.FileRoutes, T.Expectation.Commits[0], "");
	CheckRow(Framework, Result[3], T.FileRoutes, T.Expectation.Commits[1], "");
	CheckRow(Framework, Result[4], T.FileRoutes, T.Expectation.Commits[2], "");
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFromIB(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");
	
	ExternalRequestHandler = Tests.NewExternalRequestHandler();
	CheckoutSHA = "CheckoutSHA" + Tests.RandomString();
	Data = "Data" + Tests.RandomString();
	
	ValueTable = New ValueTable();
	ValueTable.Columns.Add("Column");
	NewRow = ValueTable.Add();
	NewRow.Column = Data;
	
	Tests.AddRecord("RemoteFiles", ExternalRequestHandler, CheckoutSHA, ValueTable);
	
	// when	
	Result = RemoteFiles.GetFromIB(ExternalRequestHandler.Ref, CheckoutSHA);
	
	// then
	Framework.AssertType(Result, "ValueTable");
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0][0], Data);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFromIBNoData(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");

	// when	
	Result = RemoteFiles.GetFromIB(Tests.NewExternalRequestHandler().Ref, Tests.RandomString());
	
	// then
	Framework.AssertNotFilled(Result);
	
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

EndProcedure

Function NewTest()
	
	Result = New Structure();
	Result.Insert("Connection", Tests.NewConnection(Tests.MockURL()));
	Result.Insert("FileEPF", Tests.NewFile("каталог", "файл", "epf"));
	Result.Insert("FileERF", Tests.NewFile("каталог", "file", "ERF"));
	Result.Insert("FileRoutes", Tests.NewFile("", ".ext-epf", "json"));
	
	Expectation = New Structure();
	Expectation.Insert("Type", Enums.RequestSource.GitLab);
	Expectation.Insert("ProjectId", "1");
	Expectation.Insert("ServerURL", Result.Connection.URL);
	
	CurrentSessionDate = CurrentSessionDate();
	Commits = New Array();
	Commits.Add(Tests.NewCommit(Tests.RandomString(), CurrentSessionDate));
	Commits.Add(Tests.NewCommit(Tests.RandomString(), CurrentSessionDate + 1));
	Commits.Add(Tests.NewCommit(Tests.RandomString(), CurrentSessionDate + 2));
	Expectation.Insert("Commits", Commits);
	
	Expectation.Insert("ModifiedFiles", New Array);
	
	Result.Insert("Expectation", Expectation);

	Return Result;
	
EndFunction

Procedure CheckRow(Framework, Row, File, Commit, Action)

	Framework.AssertEqual(Row.RAWFilePath, Tests.NewRAWFilePath(File, Commit.Id, "1"));	
	Framework.AssertEqual(Row.FileName, File.FileName);
	Framework.AssertEqual(Row.FilePath, File.FilePath);
	Framework.AssertEqual(GetStringFromBinaryData(Row.BinaryData), File.Data);
	Framework.AssertEqual(Row.Action, Action);
	Framework.AssertEqual(Row.Date, Commit.Date);
	Framework.AssertEqual(Row.CommitSHA, Commit.Id);
	
EndProcedure

#EndRegion
