#Region Public

// @unit-test:fast
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure MockServerEnabled(Framework) Export
	
	// given
	URL = "http://mockserver:1080";
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server(URL, , True).OpenAPIExpectation("file:/tmp/endpoint.yaml", """infobase"": ""200""");
	
	Auth = New Structure();
	Auth.Insert( "User", "User" );
	Auth.Insert( "Password", "Password" );	
	AdditionalParams = New Structure();
	AdditionalParams.Insert( "Authentication", Auth );
	
	// when
	Result = HTTPConnector.Get(URL + "/infobase", , AdditionalParams);
	
	// then
	Framework.AssertEqual(Result.StatusCode, 200);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertStringContains(Body, "File=\""/1c/db/epf-endpoint\"";");

EndProcedure

Procedure Pause(Val Wait) Export
	
	End = CurrentSessionDate() + Wait;
	
	While (True) Do
		If CurrentSessionDate() >= End Then
			Return;
		EndIf; 
	EndDo;
	
EndProcedure

Function RandomString() Export
	
	Start = CurrentUniversalDateInMilliseconds();
	Stop = CurrentUniversalDateInMilliseconds();
	While True Do
		If Start <> Stop Then
			Break;
		EndIf;
		Stop = CurrentUniversalDateInMilliseconds();
	EndDo;
	
	Return StrReplace(String(Stop), " ", "");
	
EndFunction

Function GetJSON(Val Filename) Export
	
	Result = New TextReader(Filename, TextEncoding.UTF8);
	
	Return Result.Read();
	
EndFunction

Function NewError(Val Text) Export
	
	Try
		
		Raise Text;
		
	Except
		
		Return ErrorInfo();
		
	EndTry;
	
EndFunction

#Region File

Function NewFileName(Name, Ext) Export

	Return Name + RandomString() + "." + Ext;
	
EndFunction

Function NewFile(Dir = "", FileName, Ext) Export
	
	FileName = NewFileName(FileName, Ext);
	
	Result = New Structure;
	
	Result.Insert("FileName", FileName);
	Result.Insert("FileNameISO_8859_1", StringsClientServer.Encode(Result.FileName, "UTF-8", "ISO-8859-1"));	
	Result.Insert("FileNameEncoded", EncodeString(Result.FileName, StringEncodingMethod.URLEncoding));
	
	If (IsBlankString(Dir)) Then
		Result.Insert("FilePath", FileName);
	Else
		Result.Insert("FilePath", Dir + "/" + FileName);
	EndIf;

	Result.Insert("FilePathEncoded", EncodeString(Result.FilePath, StringEncodingMethod.URLEncoding));
	Result.Insert("Data", "{""text"":""" + Result.FilePath + """}");
	Result.Insert("APIPath", "/api/v4/projects/.*/repository/files/");	
	
	Return Result;
	
EndFunction

Function GetFilePathes(File1, File2 = Undefined, File3 = Undefined) Export
	
	Result = New Array;
	Result.Add(File1.FilePath);
	If File2 <> Undefined Then
		Result.Add(File2.FilePath);
	EndIf;
	If File3 <> Undefined Then
		Result.Add(File3.FilePath);
	EndIf;
	
	Return Result;
	
EndFunction

Function NewRAWFilePath(File, Commit, Project = Undefined) Export
	
	If Project <> Undefined Then
		
		File.APIPath = StrReplace(File.APIPath, ".*", String(Project));
		
	EndIf;
	
	Return File.APIPath + File.FilePathEncoded + "/raw?ref=" + Commit;
	
EndFunction

Function NewFilesMetadata() Export
	
	Result = New ValueTable();
	Result.Columns.Add( "RAWFilePath", New TypeDescription("String") );
	Result.Columns.Add( "FileName", New TypeDescription("String") );
	Result.Columns.Add( "FilePath", New TypeDescription("String") );
	Result.Columns.Add( "BinaryData", New TypeDescription("BinaryData") );
	Result.Columns.Add( "Action", New TypeDescription("String") );
	Result.Columns.Add( "Date", New TypeDescription("Date") );
	Result.Columns.Add( "CommitSHA", New TypeDescription("String") );
	Result.Columns.Add( "ErrorInfo" );
	
	Return Result;

EndFunction

Procedure AddFileMetadata(FilesMetadata, Val File, Val Commit, Val Action, Val Date = Undefined, Val Error = Undefined) Export

	NewFile = FilesMetadata.Add();
	FillPropertyValues(NewFile, File);
	If TypeOf(Commit) = Type("String") Then
		NewFile.CommitSHA = Commit;	
	Else
		NewFile.CommitSHA = Commit.Get("id");	
	EndIf;
	If FilesMetadata.Columns.Find("FileName") <> Undefined Then
		NewFile.FileName = File.FileName;
	EndIf;
	If FilesMetadata.Columns.Find("FilePath") <> Undefined Then
		NewFile.FilePath = File.FilePath;
	EndIf;
	NewFile.Action = Action;
	If Date <> Undefined Then
		NewFile.Date = Date;
	EndIf;	
	NewFile.BinaryData = GetBinaryDataFromString(File.Data);
	If Error = Undefined Then
		NewFile.ErrorInfo = Error;
	Else
		NewFile.ErrorInfo = NewError(Error);
	EndIf;
	
EndProcedure

#EndRegion

#Region Connection

Function MockURL() Export
	
	Return "http://mockserver:1080";
	
EndFunction

Function NewURL() Export
	
	Return "http://" + RandomString();
	
EndFunction

Function NewConnection(Val URL = "", Val Token = "", Val Timeout = 5) Export
	
	If IsBlankString(URL) Then
		URL = NewURL();
	EndIf;
	
	If IsBlankString(Token) Then
		Token = NewToken();
	EndIf;
	
	Result = New Structure();
	Result.Insert("URL", URL);
	Result.Insert("Token", Token);
	Result.Insert("Timeout", Timeout);
	
	Return Result;
	
EndFunction

#EndRegion

#Region Request

Function NewProject(Val Id, Val URL = "") Export
	
	Result = New Map;
	Result.Insert("id", Id);
	If IsBlankString(URL) Then
		URL = NewURL();
	EndIf;
	Result.Insert("web_url", URL);
	
	Return Result;
	
EndFunction

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

Function NewWebService(Val URL, Val IsEnabled) Export
	
	Result = New Map;
	Result.Insert("name", URL);
	Result.Insert("url", URL);
	Result.Insert("enabled", IsEnabled);
	
	Return Result;
	
EndFunction

Function NewEPF(Val Name, Val Exclude = Undefined) Export
	
	Result = New Map;
	Result.Insert("name", Name);
	If Exclude <> Undefined Then
		Result.Insert("exclude", Exclude);
	EndIf;
	
	Return Result;
	
EndFunction

Function NewRoutes(Val WebServices, Val Files) Export
	
	Result = New Map;
	Result.Insert("ws", WebServices);
	Result.Insert("epf", Files);
	
	Return Result;
	
EndFunction

#EndRegion

#Region Data

Procedure CatalogCleanUp( Val Names ) Export
	
	CatalogNames = StrSplit(Names, ",");
	
	For Each Element In CatalogNames Do
		
		Items = Catalogs[TrimAll(Element)].Select();
		
		While Items.Next() Do
			Object = Items.GetObject();
			Object.Delete();
		EndDo;
		
	EndDo;
	
EndProcedure

Procedure InformationRegisterCleanUp( Val Names ) Export
	
	InformationRegisterNames = StrSplit(Names, ",");
	
	For Each Element In InformationRegisterNames Do
		
		Set = InformationRegisters[TrimAll(Element)].CreateRecordSet();
		Set.Write();
		
	EndDo;
	
EndProcedure

Function NewToken() Export
	
	Return "Token" + RandomString();
	
EndFunction

Function NewExternalRequestHandler(Val Name = "", Val ProjectURL = "", Val SecretToken = "") Export
	
		Item = Catalogs.ExternalRequestHandlers.CreateItem();
		Item.DataExchange.Load = True;
		If IsBlankString(Name) Then
			Item.Description = "Test" + RandomString();
		Else
			Item.Description = Name;
		EndIf;
		If IsBlankString(ProjectURL) Then
			Item.ProjectURL = NewURL();
		Else
			Item.ProjectURL = ProjectURL;
		EndIf;
		If IsBlankString(SecretToken) Then
			Item.SecretToken = NewToken();
		Else
			Item.SecretToken = SecretToken;
		EndIf;
		Item.Write();
		
		Return Item;
	
EndFunction

Function GetRecordSet(Val Name, Val RequestHandler, Val CheckoutSHA) Export

	Result = InformationRegisters[ Name ].CreateRecordSet();
	Result.Filter.RequestHandler.Set(RequestHandler.Ref);
	Result.Filter.CheckoutSHA.Set(CheckoutSHA);
	Result.Read();
	
	Return Result;
	
EndFunction

Procedure AddRecord(Val Name, Val RequestHandler, Val CheckoutSHA, Val Data) Export

	RecordManager = InformationRegisters[ Name ].CreateRecordManager();
	RecordManager.RequestHandler = RequestHandler.Ref;
	RecordManager.CheckoutSHA = CheckoutSHA;
	RecordManager.Data = New ValueStorage(Data);
	RecordManager.Write();
	
EndProcedure

#EndRegion

#Region EventLog

//TODO check refs
Function EventLogFilterByEvent( Val Event, Val Level, Val ApplicationName = "BackgroundJob" ) Export
	
	Return New Structure("StartDate, Level, ApplicationName, Event", CurrentSessionDate(), EventLogLevel[Level], ApplicationName, Event);
	
EndFunction

//TODO check refs
Function EventLogFilterByComment( Val Comment, Val Level, Val ApplicationName = "BackgroundJob" ) Export
	
	Return New Structure("StartDate, Level, ApplicationName, Comment", CurrentSessionDate(), EventLogLevel[Level], ApplicationName, Comment);
	
EndFunction

Function EventLogFilterByData( Val Data, Val Level, Val ApplicationName = "BackgroundJob" ) Export
	
	Return New Structure("StartDate, Level, ApplicationName, Data", CurrentSessionDate(), EventLogLevel[Level], ApplicationName, Data);
	
EndFunction

Function GetEventLog( Val Filter ) Export

	Result = New ValueTable();
	Columns = "Date, ApplicationName, MetadataPresentation, DataPresentation, Comment";
	UnloadEventLog(Result, Filter, Columns);
//	Filter.Delete("ApplicationName");
//	UnloadEventLog(Result, Filter);
	Return Result;
	
EndFunction

#EndRegion

#Region MockServer

Procedure ResetMockServer() Export
	
	URL = "http://mockserver:1080";
	
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server(URL).Reset();
	
EndProcedure

Procedure SetMockGitLabDownloadFile(Connection, File = Undefined, StatusCode) Export
	
	If ( File = Undefined ) Then
		File = New Structure;
		File.Insert("FileName", "");
		File.Insert("FileNameISO_8859_1", "");
		File.Insert("FileNameEncoded", "");		
		File.Insert("FilePath", "");
		File.Insert("FilePathEncoded", "");
		File.Insert("Data", "");
		File.Insert("APIPath", "/api/v4/projects/.*/repository/files/");
	EndIf;
	
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server(Connection.URL)
		.When(
			Mock.Request()
				.WithMethod("GET")
				.WithPath(File.APIPath + File.FilePathEncoded + ".*")
				.Headers()
					.WithHeader("PRIVATE-TOKEN", Connection.Token)
		)
	    .Respond(
	        Mock.Response()
	        	.WithStatusCode(StatusCode)
	        	.Headers()
	        		.WithHeader("X-Gitlab-File-Name", File.FileNameISO_8859_1)
	        	.WithBody(File.Data)
	    );

EndProcedure

#EndRegion

#EndRegion