// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCheckoutSHA(Framework) Export

	// given
	Data = New Map;
	Data.Insert("checkout_sha", "value");
	
	// when
	Result = ExternalRequests.GetCheckoutSHA(Data);
	
	// then
	Framework.AssertEqual(Result, "value");
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetProjectOrRaise(Framework) Export
	
	// given
	ProjectId = 1;
	ServerURL = "http://mockserver:1080";
	
	JSON = UtilsServer.GetJSON("/test/requests/push.json");
	Data = HTTPConnector.JsonToObject(JSON);

	// when
	Result = ExternalRequests.GetProjectOrRaise(Data);
	
	// then
	Framework.AssertEqual(Result.Id, ProjectId);
	Framework.AssertEqual(Result.ServerURL, ServerURL);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetProjectOrRaiseException(Framework) Export
	
	// given
	Data = New Map;

	// when
	Try
		Result = ExternalRequests.GetProjectOrRaise(Data);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_POJECT_DESCRIPTION);
	EndTry;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCommitsOrRaise(Framework) Export
	
	// given
	JSON = UtilsServer.GetJSON("/test/requests/push.json");
	Data = HTTPConnector.JsonToObject(JSON);

	// when
	Result = ExternalRequests.GetCommitsOrRaise(Data);
	
	// then
	Framework.AssertFilled(Result);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetCommitsOrRaiseException(Framework) Export
	
	// given
	Data = New Map;

	// when
	Try
		Result = ExternalRequests.GetCommitsOrRaise(Data);
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
Procedure GetRequestBody(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	InformationRegistersCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	ExternalRequestHandler = NewExternalRequestHandler("Test", "http://" + TIME);
	CheckoutSHA = TIME;
	Data = "Data" + TIME;
	
	Map = New Map();
	Map.Insert("Key", Data);
	
	AddRecord("QueryData", ExternalRequestHandler, CheckoutSHA, Map);
	
	// when	
	Result = ExternalRequests.GetRequestBody(ExternalRequestHandler.Ref, CheckoutSHA);
	
	// then
	Framework.AssertType(Result, "Map");
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result.Get("Key"), Data);
		
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetRequestBodyNoData(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	InformationRegistersCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	ExternalRequestHandler = NewExternalRequestHandler("Test", "http://" + TIME);
	CheckoutSHA = TIME;
	
	// when	
	Result = ExternalRequests.GetRequestBody( ExternalRequestHandler.Ref, CheckoutSHA );
	
	// then
	Framework.AssertNotFilled(Result);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure AppendRoutingSettingsNoData(Framework) Export

	// given
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	FileName = ".ext-epf" + TIME +".json";
	Constants.RoutingFileName.Set(FileName);
	
	Data = New Map;
	Files = New ValueTable();

	// when
	Try
		ExternalRequests.AppendRoutingSettings(Data, Files);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_COMMITS);
	EndTry;	
	
EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure AppendRoutingSettings(Framework) Export

	// given
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	FilePath = ".ext-epf" + TIME +".json";
	Constants.RoutingFileName.Set(FilePath);
	
	Commit1 = New Map;
	Commit1.Insert("id", "commit1");
	Commit2 = New Map;
	Commit2.Insert("id", "commit2");
	Commits = New Array;
	Commits.Add(Commit1);
	Commits.Add(Commit2);
	
	Data = New Map;
	Data.Insert("commits", Commits);
	
	JSON1 = "{""key1"":""value1""}";
	JSON2 = "{""key2"":""value2""}";
	JSON3 = "{""key3"":""value3""}";

	Files = NewFiles();
	AddFileMetadata(Files, "commit1", FilePath, "added", JSON1 );
	AddFileMetadata(Files, "commit1", FilePath, "", JSON2 );
	AddFileMetadata(Files, "commit2", FilePath, "", JSON3, "any error" );		

	// when
	ExternalRequests.AppendRoutingSettings(Data, Files);

	// then
	Framework.AssertEqual(Data.Get("commits")[0].Get("settings").Get("key2"), "value2");
	Framework.AssertEqual(Data.Get("commits")[0].Get("settings").Get("json"), JSON2);
	Framework.AssertNotFilled(Data.Get("commits")[1].Get("settings"));	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure Dump(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	InformationRegistersCleanUp();
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	ExternalRequestHandler = NewExternalRequestHandler("Test", "http://" + TIME);
	CheckoutSHA = TIME;
	Data = "Data" + TIME;
	
	// when	
	ExternalRequests.Dump(ExternalRequestHandler.Ref, CheckoutSHA, Data);
	Result = GetRecordSet("QueryData", ExternalRequestHandler.Ref, CheckoutSHA);
	
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
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	ExternalRequestHandler = NewExternalRequestHandler("Test", "http://" + TIME);
	CheckoutSHA = TIME;
	Data = New HTTPRequest();
	
	// when
	Try
		ExternalRequests.Dump(ExternalRequestHandler.Ref, CheckoutSHA, Data);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, "(ValueStorage)");
	EndTry;	
	
EndProcedure

#EndRegion

#Region Private

#Region Data

Procedure ExternalRequestHandlersCleanUp()
	
	UtilsServer.CatalogCleanUp("ExternalRequestHandlers");

EndProcedure

Procedure InformationRegistersCleanUp()
	
	UtilsServer.InformationRegisterCleanUp("QueryData, RemoteFiles");

EndProcedure

Function NewExternalRequestHandler(Val Name, Val ProjectURL)
	
	Return UtilsServer.NewExternalRequestHandler(Name, ProjectURL, "empty");
	
EndFunction

Function GetRecordSet(Name, Handler, CheckoutSHA)

	Return UtilsServer.GetRecordSet(Name, Handler, CheckoutSHA);
	
EndFunction

Procedure AddRecord(Name, Handler, CheckoutSHA, Data)
	
	UtilsServer.AddRecord(Name, Handler, CheckoutSHA, Data);

EndProcedure

Function NewFiles()
	
	Result = New ValueTable();
	Result.Columns.Add( "FilePath", New TypeDescription("String") );
	Result.Columns.Add( "BinaryData", New TypeDescription("BinaryData") );
	Result.Columns.Add( "Action", New TypeDescription("String") );
	Result.Columns.Add( "CommitSHA", New TypeDescription("String") );
	Result.Columns.Add( "ErrorInfo" );
	
	Return Result;
	
EndFunction
		
Procedure AddFileMetadata(Files, Val CommitSHA, Val FilePath, Val Action, Val Data, Val Error = Undefined)
	
	UtilsServer.AddFileMetadata(Files, CommitSHA, "", FilePath, Action, Data, Error);
	
EndProcedure

#EndRegion

#EndRegion
