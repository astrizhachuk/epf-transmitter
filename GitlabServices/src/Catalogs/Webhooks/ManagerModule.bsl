#Region Public

// FindByToken returns search result from registered and not marked for deletion webhooks.
// 
// Parameters:
// 	Token - String - secret token;
// 	
// Returns:
// 	Array of CatalogRef.Webhooks - search result from registered and not marked for deletion webhooks or empty array;
//
Function FindByToken( Val Token ) Export
	
	Var Query;
	
	If ( TypeOf(Token) <> Type("String") OR IsBlankString(Token) ) Then
		
		Return New Array();
		
	EndIf;
	
	Query = New Query();
	Query.SetParameter( "SecretToken", Token );
	Query.Text = 	"SELECT
	               	|	Webhooks.Ссылка AS Ref
	               	|FROM
	               	|	Catalog.Webhooks AS Webhooks
	               	|WHERE
	               	|	NOT Webhooks.DeletionMark
	               	|	AND Webhooks.SecretToken = &SecretToken";
	
	Return Query.Execute().Unload().UnloadColumn( "Ref" );
	
EndFunction

// LoadEventsHistory loads data from the event log into the object by filter.
// 
// Parameters:
// 	Object - CatalogObject.Webhooks - target object; 
// 	Destination - String - tabular section name;
// 	Filter - Structure - event log filter (see global context UnloadEventLog);
// 	RecordsLoaded - Number - (returned) number of loaded records;
//
Procedure LoadEventsHistory( Object, Val Destination, Val Filter, RecordsLoaded ) Export
	
	Var EventLog;
	Var Event;
	Var NewHistoryRecord;
	
	EVENT_OBJECT = NStr( "ru = 'ОбработчикиСобытий';en = 'Webhooks'" );

	If ( TypeOf(Object) <> Type("CatalogObject.Webhooks") ) Then
		
		Return;
		
	EndIf;	

	Object[Destination].Clear();

	EventLog = New ValueTable();
	
	UnloadEventLog( EventLog, Filter );
	
	For Each Record In EventLog Do
		
		Event = Event( Record );
		
		If ( Event.ObjectName <> EVENT_OBJECT ) Then
			
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