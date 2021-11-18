#Region Public

Procedure Pause(Val Wait) Export
	
	End = CurrentSessionDate() + Wait;
	
	While (True) Do
		If CurrentSessionDate() >= End Then
			Return;
		EndIf; 
	EndDo;
	
EndProcedure

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
	Return Result;
	
EndFunction

#EndRegion

#EndRegion