#Region Public

Procedure Pause(Val Wait) Export
	
	End = CurrentSessionDate() + Wait;
	
	While (True) Do
		If CurrentSessionDate() >= End Then
			Return;
		EndIf; 
	EndDo;
	
EndProcedure

Function RandomString() Export
	
	Return StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
EndFunction

Function GetJSON(Val Filename) Export
	
	Result = New TextReader(Filename, TextEncoding.UTF8);
	
	Return Result.Read();
	
EndFunction

#Region Request

Function NewProject(Val Id, Val URL) Export
	
	Result = New Map;
	Result.Insert("id", Id);
	Result.Insert("web_url", URL);
	
	Return Result;
	
EndFunction

Function NewCommit(Val Id, Val Date, Val Added, Val Modified, Val Removed) Export
	
	Result = New Map;
	Result.Insert("id", Id);
	Result.Insert("timestamp", Date);
	Result.Insert("added", Added);
	Result.Insert("modified", Modified);
	Result.Insert("removed", Removed);
	
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

Function SplitString(Val String) Export

	Return StrSplit(String, "|", False);
	
EndFunction

Procedure AddFileMetadata(FilesMetadata, Val CommitSHA, Val FileName, Val FilePath, Val Action, Val Data, Val Error) Export

	NewFile = FilesMetadata.Add();
	NewFile.CommitSHA = CommitSHA;
	If FilesMetadata.Columns.Find("FileName") <> Undefined Then
		NewFile.FileName = FileName;
	EndIf;
	If FilesMetadata.Columns.Find("FilePath") <> Undefined Then
		NewFile.FilePath = FilePath;
	EndIf;
	NewFile.Action = Action;
	NewFile.BinaryData = GetBinaryDataFromString(Data);
	If Error = Undefined Then
		NewFile.ErrorInfo = Error;
	Else
		NewFile.ErrorInfo = NewError(Error);
	EndIf;
	
EndProcedure

Function NewError(Val Text) Export
	
	Try
		
		Raise Text;
		
	Except
		
		Return ErrorInfo();
		
	EndTry;
	
EndFunction

Function NewExternalRequestHandler(Val Name = "", Val ProjectURL = "", Val SecretToken = "") Export
	
		Item = Catalogs.ExternalRequestHandlers.CreateItem();
		Item.DataExchange.Load = True;
		Item.Description = Name;
		Item.ProjectURL = ProjectURL;
		Item.SecretToken = SecretToken;
		Item.Write();
		
		Return Item;
	
EndFunction

Function GetRecordSet(Val Name, Val RequestHandler, Val CheckoutSHA) Export

	Result = InformationRegisters[ Name ].CreateRecordSet();
	Result.Filter.Webhook.Set(RequestHandler);
	Result.Filter.CheckoutSHA.Set(CheckoutSHA);
	Result.Read();
	
	Return Result;
	
EndFunction

Procedure AddRecord(Val Name, Val RequestHandler, Val CheckoutSHA, Val Data) Export

	RecordManager = InformationRegisters[ Name ].CreateRecordManager();
	RecordManager.Webhook = RequestHandler.Ref;
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
	Columns = "Date, ApplicationName, EventPresentation, MetadataPresentation, DataPresentation, Comment";
	UnloadEventLog(Result, Filter, Columns);
//	Filter.Delete("ApplicationName");
//	UnloadEventLog(Result, Filter);
	Return Result;
	
EndFunction

#EndRegion

#EndRegion