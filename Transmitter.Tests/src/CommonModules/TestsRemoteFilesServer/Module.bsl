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
		RemoteFiles.GetFromRemoteVCS(NewConnection(), New Map);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_POJECT_DESCRIPTION);
	EndTry;
	
EndProcedure

// @unit-test:dev
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFromRemoteVCSCommitsNoCompiledFiles(Framework) Export
	
	// given
	File = NewFile( "", ".ext-epf", "json");
	Constants.RoutingFileName.Set(File.Name);

	Commit = NewCommit("commit",
						Date(2020, 07, 21, 09, 22, 31),
						New Array,
						New Array,
						New Array);
	Commits = New Array;
	Commits.Add(Commit);
	Data = New Map;
	Data.Insert("project", NewProject(1));
	Data.Insert("commits", Commits);
	
	ResetMockServer();
	SetMockUploadFile(File, 200);
						
	// when
	Result = RemoteFiles.GetFromRemoteVCS(NewConnection(), Data);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	CheckRow(Framework, Result[0], File, Commit, "");
	
EndProcedure

// @unit-test:dev
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFromRemoteVCSGetFileMetadataFromCommits(Framework) Export
	
	// given

	File1 = NewFile("", ".ext-epf", "json");
	Constants.RoutingFileName.Set(File1.Name);
	
	File2 = NewFile("path", "file 2", "epf");
	File3 = NewFile("path", "file 3", "ERF");
	
	FilePathes = GetFilePathes(File1, File2, File3);

	Commit1 = NewCommit("commit1",
						Date(2020, 01, 21, 09, 22, 31),
						FilePathes,
						FilePathes,
						FilePathes);
	Commit2 = NewCommit("commit2",
						Date(2020, 02, 21, 09, 22, 31),
						FilePathes,
						FilePathes,
						FilePathes);
	Commit3 = NewCommit("commit3",
						Date(2020, 03, 21, 09, 22, 31),
						FilePathes,
						FilePathes,
						FilePathes);
	Commits = New Array;
	Commits.Add(Commit1);
	Commits.Add(Commit3);
	Commits.Add(Commit2);
	Data = New Map;
	Data.Insert("project", NewProject(1));
	Data.Insert("commits", Commits);

	ResetMockServer();
	SetMockUploadFile(File1, 200);
	SetMockUploadFile(File2, 200);	
	SetMockUploadFile(File3, 200);
		
	// when
	Result = RemoteFiles.GetFromRemoteVCS(NewConnection(), Data);
	
	// then
	Framework.AssertEqual(Result.Count(), 5);
	
	CheckRow(Framework, Result[0], File2, Commit3, "modified");
	CheckRow(Framework, Result[1], File3, Commit3, "modified");
	CheckRow(Framework, Result[2], File1, Commit1, "");
	CheckRow(Framework, Result[3], File1, Commit3, "");
	CheckRow(Framework, Result[4], File1, Commit2, "");
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFromIB(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	InformationRegistersCleanUp();
	
	ExternalRequestHandler = NewExternalRequestHandler();
	CheckoutSHA = "CheckoutSHA" + RandomString();
	Data = "Data" + RandomString();
	
	ValueTable = New ValueTable();
	ValueTable.Columns.Add("Column");
	NewRow = ValueTable.Add();
	NewRow.Column = Data;
	
	AddRecord("RemoteFiles", ExternalRequestHandler, CheckoutSHA, ValueTable);
	
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
	ExternalRequestHandlersCleanUp();
	InformationRegistersCleanUp();

	// when	
	Result = RemoteFiles.GetFromIB(NewExternalRequestHandler().Ref, RandomString());
	
	// then
	Framework.AssertNotFilled(Result);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure Dump(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	InformationRegistersCleanUp();
	
	ExternalRequestHandler = NewExternalRequestHandler();
	CheckoutSHA = "CheckoutSHA" + RandomString();
	Data = "Data" + RandomString();
	
	// when	
	RemoteFiles.Dump(ExternalRequestHandler.Ref, CheckoutSHA, Data);
	Result = GetRecordSet("RemoteFiles", ExternalRequestHandler.Ref, CheckoutSHA);
	
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
	ExternalRequestHandlersCleanUp();
	InformationRegistersCleanUp();

	Data = New HTTPRequest();
	
	// when
	Try
		RemoteFiles.Dump(NewExternalRequestHandler().Ref, RandomString(), Data);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, "(ValueStorage)");
	EndTry;	
	
EndProcedure

#EndRegion

#Region Private

Function RandomString()
	
	Return UtilsServer.RandomString();
	
EndFunction

Procedure CheckRow(Framework, Row, File, Commit, Action)

	Framework.AssertEqual(Row.RAWFilePath, NewExpectedRAWFilePath(File, Commit));	
	Framework.AssertEqual(Row.FileName, File.Name);
	Framework.AssertEqual(Row.FilePath, File.Path);
	Framework.AssertEqual(GetStringFromBinaryData(Row.BinaryData), File.Data);
	Framework.AssertEqual(Row.Action, Action);
	Framework.AssertEqual(Row.Date, Commit.Get("timestamp"));
	Framework.AssertEqual(Row.CommitSHA, Commit.Get("id"));
	
EndProcedure

Function NewExpectedRAWFilePath(File, Commit)
	
	RootPath = "/api/v4/projects/1/repository/files/";
	
	Return RootPath + File.EncodedPath + "/raw?ref=" + Commit.Get("id");
	
EndFunction

Function NewFile(Dir = "", Name, Ext)
	
	Name = NewFileName(Name, Ext);
	
	Result = New Structure;
	Result.Insert("Name", Name);
	If (IsBlankString(Dir)) Then
		Result.Insert("Path", Name);
	Else
		Result.Insert("Path", Dir + "/" + Name);
	EndIf;

	Result.Insert("EncodedPath", EncodeString(Result.Path, StringEncodingMethod.URLInURLEncoding));
	Result.Insert("Data", "{""text"":" + Result.Path + "}");
	
	Return Result;
	
EndFunction

Function NewFileName(Name, Ext)
	
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	Return Name + TIME + "." + Ext;
	
EndFunction

Function GetFilePathes(File1, File2, File3)
	
	Result = New Array;
	Result.Add(File1.Path);
	Result.Add(File2.Path);
	Result.Add(File3.Path);
	
	Return Result;
	
EndFunction

Function NewConnection()
	
	URL = "http://mockserver:1080";
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	Result = New Structure();
	Result.Insert("URL", URL);
	Result.Insert("Token", "Token" + TIME);
	Result.Insert("Timeout", 5);
	
	Return Result;
	
EndFunction

Procedure ResetMockServer()
	
	URL = "http://mockserver:1080";
	
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server(URL).Reset();
	Mock = Undefined;
	
EndProcedure

Procedure SetMockUploadFile(File, StatusCode)
	
	URL = "http://mockserver:1080";
	
	RootPath = "/api/v4/projects/.*/repository/files/";
	
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server(URL)
		.Когда(
			Mock.Request()
				.WithMethod("GET")
				.WithPath(RootPath
					+ EncodeString(File.Path, StringEncodingMethod.URLInURLEncoding)
					+ ".*")
		)
	    .Respond(
	        Mock.Response()
	        	.WithStatusCode(StatusCode)
	        	.Headers()
	        	.WithHeader("X-Gitlab-File-Name", File.Name)
	        	.WithBody(File.Data)
	    );
    Mock = Undefined;
    
EndProcedure

#Region Request

Function NewProject(Id)
	
	Return UtilsServer.NewProject(Id, "http://" + RandomString());
	
EndFunction

Function NewCommit(Id, Date, Added, Modified, Removed)
	
	Return UtilsServer.NewCommit(Id, Date, Added, Modified, Removed);
	
EndFunction

#EndRegion

#Region Data

Procedure ExternalRequestHandlersCleanUp()
	
	UtilsServer.CatalogCleanUp("ExternalRequestHandlers");

EndProcedure

Procedure InformationRegistersCleanUp()
	
	UtilsServer.InformationRegisterCleanUp("QueryData, RemoteFiles");

EndProcedure

Function NewExternalRequestHandler()
	
	Return UtilsServer.NewExternalRequestHandler("Test", "http://" + RandomString(), "empty");
	
EndFunction

Function GetRecordSet(Name, Handler, CheckoutSHA)

	Return UtilsServer.GetRecordSet(Name, Handler, CheckoutSHA);
	
EndFunction

Procedure AddRecord(Name, Handler, CheckoutSHA, Data)
	
	UtilsServer.AddRecord(Name, Handler, CheckoutSHA, Data);

EndProcedure

#EndRegion

#EndRegion
