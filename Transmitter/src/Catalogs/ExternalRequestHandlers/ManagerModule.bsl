#Region Public

// FindByURL returns the search result by URL from records not marked for deletion.
// 
// Parameters:
// 	URL - String - remote project URL;
// 	
// Returns:
// 	ValueTable - search result:
// 	* Ref - CatalogRef.ExternalRequestHandlers - ref to external request handler;
// 	* SecretToken - String - remote repository token;
//
Function FindByURL( Val URL ) Export
	
	Var Query;
	
	If ( TypeOf(URL) <> Type("String") ) Then
		
		Return New Array();
		
	EndIf;
	
	Query = New Query();
	Query.SetParameter( "URL", URL );
	Query.Text = 	"SELECT
					|	Webhooks.Ref AS Ref,
					|	Webhooks.SecretToken AS SecretToken
					|FROM
					|	Catalog.ExternalRequestHandlers AS Webhooks
					|WHERE
					|	NOT Webhooks.DeletionMark
					|	AND Webhooks.ProjectURL = &URL";
	
	Return Query.Execute().Unload();
	
EndFunction

// LoadEventsHistory loads data from the event log into the object by filter.
// 
// Parameters:
// 	Object - CatalogObject.ExternalRequestHandlers - target object; 
// 	Destination - String - tabular section name;
// 	Filter - Structure - event log filter (see global context UnloadEventLog);
// 	RecordsLoaded - Number - (returned) number of loaded records;
//
Procedure LoadEventsHistory( Object, Val Destination, Val Filter, RecordsLoaded ) Export
	
	Var EventLog;
	Var Event;
	Var NewHistoryRecord;
	
	CONTEXT = Metadata.Catalogs.ExternalRequestHandlers.Synonym;

	If ( TypeOf(Object) <> Type("CatalogObject.ExternalRequestHandlers") ) Then
		
		Return;
		
	EndIf;	

	Object[Destination].Clear();

	EventLog = New ValueTable();
	
	UnloadEventLog( EventLog, Filter );
	
	For Each Record In EventLog Do
		
		Event = Event( Record );
		
		If ( Event.ObjectName <> CONTEXT ) Then
			
			Continue;
			
		EndIf;

		NewHistoryRecord = Object[Destination].Add();
		
		FillPropertyValues( NewHistoryRecord, Record );
		FillPropertyValues( NewHistoryRecord, Event );
 		
		RecordsLoaded = RecordsLoaded + 1;

	EndDo;
	
	Object.Write();

EndProcedure

#EndRegion

#Region Private

// Event returns a structured description of log entry event (see global context UnloadEventLog, column "Event").
// Event string format: "ObjectName.Action.Operation1.Operation2...OperationN[.HTTPStatusCode]".  
// 
// Parameters:
// 	Record - ValueTableRow - log event record;
//
// Returns:
// 	Structure - log event:
// * Event - String - event string from log record (as is);
// * ObjectName - String - first element from the event string;
// * Action - String - action (second element from the event string);
// * EventPresentation - String - presentation of the event in the format: "Operation1.Operation2...OperationN";
// * HTTPStatusCode - Number - HTTP status code or 0, if code undefined; 
//
Function Event( Val Record )
	
	Var EventElements;
	Var Result;

	WORD_COUNT_MIN = 3;
	
	Result = New Structure();
	Result.Insert( "Event", Record.Event );
	Result.Insert( "ObjectName", "" );
	Result.Insert( "Action", "" );
	Result.Insert( "EventPresentation", "" );
	Result.Insert( "HTTPStatusCode", 0 );
	
	EventElements = StrSplit( Record.Event, "." );
	
	If ( EventElements.Count() < WORD_COUNT_MIN ) Then
		
		Return Result;
							
	EndIf;

	Result.ObjectName = EventElements[ 0 ];
	Result.Action = EventElements[ 1 ];
	Result.HTTPStatusCode = HTTPStatusCode( EventElements );
	Result.EventPresentation = EventPresentation( EventElements, Result.HTTPStatusCode );
	
	Return Result;
	
EndFunction

Function HTTPStatusCode( Val EventElements )

	Var TypeDescription;
	Var LastElement;
	
	LastElement = EventElements[ EventElements.UBound() ];
	TypeDescription = New TypeDescription( "Number" );
	
	Return TypeDescription.AdjustValue( LastElement );
	
EndFunction

Function EventPresentation( Val EventElements, Val HTTPStatusCode )

	Var UBoundIndex;
	Var UBoundPresentation;
	
	UBoundIndex = EventElements.UBound();
	UBoundPresentation = ?( HTTPStatusCode = 0, UBoundIndex, UBoundIndex - 1 );

	Presentation = New Array();
	
	For Index = 2 To UBoundPresentation Do
		
		Presentation.Add( EventElements[Index] );
		
	EndDo;
	
	Return StrConcat( Presentation, "." );
	
EndFunction

#EndRegion