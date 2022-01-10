// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFromRemoteVCSEmptyData(Framework) Export

	// given
	
	// when
	Try
		RemoteFiles.GetFromRemoteVCS(Tests.NewConnection(), New Map);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_POJECT_DESCRIPTION);
	EndTry;
	
EndProcedure

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFromRemoteVCSCommitsNoCompiledFiles(Framework) Export
	
	// given
	Connection = Tests.NewConnection(Tests.MockURL());
	File = Tests.NewFile( "", ".ext-epf", "json");
	
	Constants.RoutingFileName.Set(File.FileName);
	
	Project = Tests.NewProject(1);

	Commit = Tests.NewCommit("commit",
							Date(2020, 07, 21, 09, 22, 31),
							New Array,
							New Array,
							New Array);
	Commits = New Array;
	Commits.Add(Commit);
	
	Data = New Map;
	Data.Insert("project", Project);
	Data.Insert("commits", Commits);
	
	Tests.ResetMockServer();
	Tests.SetMockGitLabDownloadFile(Connection, File, 200);
						
	// when
	Result = RemoteFiles.GetFromRemoteVCS(Connection, Data);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	CheckRow(Framework, Result[0], File, Project, Commit, "");
	
EndProcedure

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFromRemoteVCSGetFileMetadataFromCommits(Framework) Export
	
	// given
	Connection = Tests.NewConnection(Tests.MockURL());
	File1 = Tests.NewFile("", ".ext-epf", "json");
	Constants.RoutingFileName.Set(File1.FileName);
	
	File2 = Tests.NewFile("path", "file 2", "epf");
	File3 = Tests.NewFile("path", "file 3", "ERF");
	
	FilePathes = Tests.GetFilePathes(File1, File2, File3);
	
	Project = Tests.NewProject(1);

	Commit1 = Tests.NewCommit("commit1",
							Date(2020, 01, 21, 09, 22, 31),
							FilePathes,
							FilePathes,
							FilePathes);
	Commit2 = Tests.NewCommit("commit2",
							Date(2020, 02, 21, 09, 22, 31),
							FilePathes,
							FilePathes,
							FilePathes);
	Commit3 = Tests.NewCommit("commit3",
							Date(2020, 03, 21, 09, 22, 31),
							FilePathes,
							FilePathes,
							FilePathes);
	Commits = New Array;
	Commits.Add(Commit1);
	Commits.Add(Commit3);
	Commits.Add(Commit2);
	
	Data = New Map;
	Data.Insert("project", Project);
	Data.Insert("commits", Commits);

	Tests.ResetMockServer();
	Tests.SetMockGitLabDownloadFile(Connection, File1, 200);
	Tests.SetMockGitLabDownloadFile(Connection, File2, 200);	
	Tests.SetMockGitLabDownloadFile(Connection, File3, 200);
		
	// when
	Result = RemoteFiles.GetFromRemoteVCS(Connection, Data);
	
	// then
	Framework.AssertEqual(Result.Count(), 5);
	
	CheckRow(Framework, Result[0], File2, Project, Commit3, "modified");
	CheckRow(Framework, Result[1], File3, Project, Commit3, "modified");
	CheckRow(Framework, Result[2], File1, Project, Commit1, "");
	CheckRow(Framework, Result[3], File1, Project, Commit3, "");
	CheckRow(Framework, Result[4], File1, Project, Commit2, "");
	
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

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure Dump(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Tests.InformationRegisterCleanUp("ExternalRequests, RemoteFiles");
	
	ExternalRequestHandler = Tests.NewExternalRequestHandler();
	CheckoutSHA = "CheckoutSHA" + Tests.RandomString();
	Data = "Data" + Tests.RandomString();
	
	// when	
	RemoteFiles.Dump(ExternalRequestHandler.Ref, CheckoutSHA, Data);
	Result = Tests.GetRecordSet("RemoteFiles", ExternalRequestHandler.Ref, CheckoutSHA);
	
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
		RemoteFiles.Dump(Tests.NewExternalRequestHandler().Ref, Tests.RandomString(), Data);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, "(ValueStorage)");
	EndTry;	
	
EndProcedure

#EndRegion

#Region Private

Procedure CheckRow(Framework, Row, File, Project, Commit, Action)

	Framework.AssertEqual(Row.RAWFilePath, Tests.NewRAWFilePath(File, Commit.Get("id"), Project.Get("id")));	
	Framework.AssertEqual(Row.FileName, File.FileName);
	Framework.AssertEqual(Row.FilePath, File.FilePath);
	Framework.AssertEqual(GetStringFromBinaryData(Row.BinaryData), File.Data);
	Framework.AssertEqual(Row.Action, Action);
	Framework.AssertEqual(Row.Date, Commit.Get("timestamp"));
	Framework.AssertEqual(Row.CommitSHA, Commit.Get("id"));
	
EndProcedure

#EndRegion
