#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetConnectionParams(Framework) Export
	
	// given
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	URL = "http://" + TIME;
	Token = "Token" + Right(TIME, 10);
	Timeout = Number(Right(TIME, 4));

	Constants.ExternalStorageToken.Set(Token);
	Constants.ExternalStorageTimeout.Set(Timeout);
	
	// when
	Result = GitlabAPI.GetConnectionParams(URL);
	
	// then
	Framework.AssertEqual(Result.Count(), 3);
	Framework.AssertEqual(Result.URL, URL);
	Framework.AssertEqual(Result.Token, Token);
	Framework.AssertEqual(Result.Timeout, Timeout);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCheckoutSHA(Framework) Export

	// given
	Data = New Map;
	Data.Insert("checkout_sha", "value");
	
	// when
	Result = GitLabAPI.GetCheckoutSHA(Data);
	
	// then
	Framework.AssertEqual(Result, "value");
	
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
Procedure GetProject(Framework) Export
	
	// given
	ProjectId = 1;
	ServerURL = "http://mockserver:1080";
	
	Project = New Map;
	Project.Insert("id", 1);
	Project.Insert("web_url", ServerURL);
	
	Data = New Map;
	Data.Insert("project", Project);	
	
	// when
	Result = GitLabAPI.GetProject(Data);
	
	// then
	Framework.AssertEqual(Result.Id, ProjectId);
	Framework.AssertEqual(Result.ServerURL, ServerURL);
	
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
	Project.Insert("web_url", "http://domen/path");
	
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
	URL = "http://domen";
	
	Project = New Map;
	Project.Insert("id", 1);
	Project.Insert("web_url", URL);
	
	Data = New Map;
	Data.Insert("project", Project);

	// when
	Result = GitLabAPI.GetProject(Data);
	
	// then
	Framework.AssertEqual(Result.URL, URL);
	Framework.AssertEqual(Result.ServerURL, URL);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetProjectLongURL(Framework) Export
	
	// given
	LongURL = "http://domen/path/";
	ShortURL = "http://domen";
	
	Project = New Map;
	Project.Insert("id", 1);
	Project.Insert("web_url", LongURL);
	
	Data = New Map;
	Data.Insert("project", Project);

	// when
	Result = GitLabAPI.GetProject(Data);
	
	// then
	Framework.AssertEqual(Result.URL, LongURL);
	Framework.AssertEqual(Result.ServerURL, ShortURL);
	
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
Procedure GetRAWFilePath(Framework) Export
	
	// given
	ProjectId = 1;
	Path = "а/б/в";
	EncodedPath = "%D0%B0/%D0%B1/%D0%B2";
	CommitSHA = "0123456789";
	RAWFilePath = "/api/v4/projects/" + ProjectId
					+ "/repository/files/" + EncodedPath
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
	A = "added";
	M = "modified";
	R = "removed";
	
	// when	
	Result = GitlabAPI.GetFileActions();
	
	// then
	Framework.AssertEqual(Result[0], A);
	Framework.AssertEqual(Result[1], M);
	Framework.AssertEqual(Result[2], R);
	
EndProcedure

#EndRegion
