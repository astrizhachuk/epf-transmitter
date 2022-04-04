#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetConnectionParams(Framework) Export
	
	// given
	Connection = Tests.NewConnection(, , Number(Right(Tests.RandomString(), 4)));
	Constants.GitLabToken.Set(Connection.Token);
	Constants.GitLabTimeout.Set(Connection.Timeout);
	
	// when
	Result = GitlabAPI.GetConnectionParams(Connection.URL);
	
	// then
	Framework.AssertEqual(Result.Count(), 3);
	Framework.AssertEqual(Result.URL, Connection.URL);
	Framework.AssertEqual(Result.Token, Connection.Token);
	Framework.AssertEqual(Result.Timeout, Connection.Timeout);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCheckoutSHANotFound(Framework) Export

	// given
	Data = New Map;
	
	// when
	Result = GitLabAPI.GetCheckoutSHA(Data);
	
	// then
	Framework.AssertEqual(Result, Undefined);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCheckoutSHA(Framework) Export

	// given
	Text = "value";
	
	Data = New Map;
	Data.Insert("checkout_sha", Text);
	
	// when
	Result = GitLabAPI.GetCheckoutSHA(Data);
	
	// then
	Framework.AssertEqual(Result, Text);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetProjectWithoutProjectNode(Framework) Export
	
	// given
	Data = New Map;

	// when
	Result = GitLabAPI.GetProject(Data);
	
	// then
	Framework.AssertNotFilled(Result);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetProjectWithoutWebURL(Framework) Export
	
	// given
	Project = New Map;
	Project.Insert("id", 1);
	
	Data = New Map;
	Data.Insert("project", Project);

	// when
	Result = GitLabAPI.GetProject(Data);
	
	// then
	Framework.AssertNotFilled(Result);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetProjectWithoutProjectId(Framework) Export
	
	// given
	Project = New Map;
	Project.Insert("web_url", "http://example.com/path");
	
	Data = New Map;
	Data.Insert("project", Project);

	// when
	Result = GitLabAPI.GetProject(Data);
	
	// then
	Framework.AssertNotFilled(Result);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetProjectShortURL(Framework) Export
	
	// given
	Project = Tests.NewProject(1, "http://example.com");
	
	Data = New Map;
	Data.Insert("project", Project);

	// when
	Result = GitLabAPI.GetProject(Data);
	
	// then
	Framework.AssertEqual(Result.URL, Project.Get("web_url"));
	Framework.AssertEqual(Result.ServerURL, Project.Get("web_url"));
	Framework.AssertEqual(Result.Id, Project.Get("id"));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetProjectLongURL(Framework) Export
	
	// given
	Project = Tests.NewProject(1, "http://example.com/path/");
	
	Data = New Map;
	Data.Insert("project", Project);

	// when
	Result = GitLabAPI.GetProject(Data);
	
	// then
	Framework.AssertEqual(Result.URL, Project.Get("web_url"));
	Framework.AssertEqual(Result.ServerURL, "http://example.com");
	Framework.AssertEqual(Result.Id, Project.Get("id"));
	
EndProcedure


// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCommitsWithoutCommitsNode(Framework) Export
	
	// given
	Data = New Map;

	// when
	Result = GitLabAPI.GetCommits(Data);
	
	// then
	Framework.AssertNotFilled(Result);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCommits(Framework) Export

	// given
	Commits = New Map;
	Commits.Insert("key", "value");
	
	Data = New Map;
	Data.Insert("commits", Commits);	
	
	// when
	Result = GitLabAPI.GetCommits(Data);
	
	// then
	Framework.AssertFilled(Result);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetModifiedFiles(Framework) Export

	// given
	Modified = New Array;
	Modified.Add("file1");
	Modified.Add("file2.epf");
	Modified.Add("путь к файлу/file3.ErF");
	
	Commit1 = NewCommit("commit1",
							Date(2020, 07, 21, 09, 22, 31),
							New Array,
							New Array,
							New Array);
	Commit2 = NewCommit("commit2",
							Date(2020, 07, 22, 09, 22, 31),
							New Array,
							Modified,
							New Array);
	Commits = New Array;
	Commits.Add(Commit1);
	Commits.Add(Commit2);
	
	Data = New Map;
	Data.Insert("commits", Commits);
	
	// when
	Result = GitLabAPI.GetModifiedFiles(Data);
	
	// then
	Framework.AssertEqual(Result.Count(), 2);
	Framework.AssertEqual(Result[0].Id, Commit2.Get("id"));
	Framework.AssertEqual(Result[0].FilePath, Modified[1]);
	Framework.AssertEqual(Result[1].FilePath, Modified[2]);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetRAWFilePath(Framework) Export
	
	// given
	Path = "а/б/в";
	ProjectId = 1;
	CommitSHA = "0123456789";
	RAWFilePath = "/api/v4/projects/" + ProjectId
					+ "/repository/files/" + EncodeString(Path, StringEncodingMethod.URLEncoding)
					+ "/raw?ref=" + CommitSHA;
	
	// when
	Result = GitlabAPI.GetRAWFilePath(Path, ProjectId, CommitSHA);
	
	//then
	Framework.AssertEqual(Result, RAWFilePath);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFileActions(Framework) Export
	
	// given
	
	// when	
	Result = GitlabAPI.GetFileActions();
	
	// then
	Framework.AssertEqual(Result[0], "added");
	Framework.AssertEqual(Result[1], "modified");
	Framework.AssertEqual(Result[2], "removed");
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetRAWFilesNoRAWFilePaths(Framework) Export
	
	// given
	
	// when
	Result = GitlabAPI.GetRAWFiles(Tests.NewConnection(), New Array);
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetRAWFilesBadURL(Framework) Export
	
	// given
	Connection = Tests.NewConnection();
	RAWFilePaths = New Array;
	RAWFilePaths.Add("/HostNotFound");
	
	// when
	Result = GitlabAPI.GetRAWFiles(Connection, RAWFilePaths);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertStringContains(Result[0].ErrorInfo.Description, "Couldn't resolve host name");

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetRAWFiles404NotFound(Framework) Export

	// given
	Connection = Tests.NewConnection(Tests.MockURL());
	RAWFilePaths = New Array;
	RAWFilePaths.Add("/api/v4/projects/.*/repository/files/нет такого файла.epf");

	Tests.ResetMockServer();
	Tests.SetMockGitLabDownloadFile(Connection, , 404);

	// when
	Result = GitlabAPI.GetRAWFiles(Connection, RAWFilePaths);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertStringContains(Result[0].ErrorInfo.Description, HTTPStatusCodesClientServerCached.FindIdByCode(404));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetRAWFilesMixed(Framework) Export

	// given
	Connection = Tests.NewConnection(Tests.MockURL());
	File1 = Tests.NewFile("path", "file 1", "epf");
	File2 = Tests.NewFile("каталог", "файл 2", "epf");
	
	RAWFilePaths = New Array;
	RAWFilePaths.Add(Tests.NewRAWFilePath(File1, "master"));
	RAWFilePaths.Add(Tests.NewRAWFilePath(File2, "master"));
	RAWFilePaths.Add(File1.APIPath + "нет файла.epf");	

	Tests.ResetMockServer();
	Tests.SetMockGitLabDownloadFile(Connection, File1, 200);
	Tests.SetMockGitLabDownloadFile(Connection, File2, 200);
	Tests.SetMockGitLabDownloadFile(Connection, , 404);
	
	// when
	Result = GitlabAPI.GetRAWFiles(Connection, RAWFilePaths);
	
	// then	
	Framework.AssertEqual(Result[0].RAWFilePath, RAWFilePaths[0]);
	Framework.AssertEqual(Result[0].FileName, File1.FileName);
	Framework.AssertFilled(Result[0].BinaryData);
	Framework.AssertNotFilled(Result[0].ErrorInfo);
	Framework.AssertEqual(Result[1].RAWFilePath, RAWFilePaths[1]);
	Framework.AssertEqual(Result[1].FileName, File2.FileName);
	Framework.AssertFilled(Result[1].BinaryData);
	Framework.AssertNotFilled(Result[1].ErrorInfo);
	Framework.AssertStringContains(Result[2].ErrorInfo.Description, HTTPStatusCodesClientServerCached.FindIdByCode(404));

EndProcedure

#EndRegion

#Region Private

 Function NewCommit(Val Id, Val Date = Undefined, Val Added = Undefined, Val Modified = Undefined, Val Removed = Undefined) Export
	
 	Result = New Map;
 	Result.Insert("id", Id);
 	If Date <> Undefined Then
 		Result.Insert("timestamp", Date);
 	EndIf;
 	If Added <> Undefined Then
 		Result.Insert("added", Added);
 	EndIf;
 	If Modified <> Undefined Then
 		Result.Insert("modified", Modified);
 	EndIf;
 	If Removed <> Undefined Then
 		Result.Insert("removed", Removed);
 	EndIf;
	
 	Return Result;
	
 EndFunction
 
 #EndRegion
