#Region FormEventHandlers

&AtClient
Procedure OnOpen( Cancel )
	
	SetFilters( Object.Ref );
	
EndProcedure

#EndRegion

#Region FormTableItemsEventHandlers

&AtClient
Procedure ReceivedRequestsSelection(Item, RowSelected, Field, StandardProcessing)
	
	StandardProcessing = False;
	
	Return;
	
EndProcedure

#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure OpenRepositoryOnRemote( Command )
	
	If ( IsBlankString(Object.ProjectURL) ) Then
		
		Return;
		
	EndIf;
	
	GotoURL( Object.ProjectURL );
	
EndProcedure

&AtClient
Procedure OpenRequest( Command )
	
	OpenJSONEditor( Items.ReceivedRequests.CurrentRow, Command );

EndProcedure

&AtClient
Procedure OpenRoutingSettings( Command )
	
	OpenJSONEditor( Items.ReceivedRequests.CurrentRow, Command );

EndProcedure

&AtClient
Procedure OpenBackgrounds( Command )
	
	Var CurrentRow;
	Var Options;
	
	CurrentRow = Items.ReceivedRequests.CurrentRow;
	
	If ( CurrentRow = Undefined ) Then
		
		Return;
		
	EndIf;
	
	Options = New Structure();
	Options.Insert( "RecordKey", CurrentRow );
	OpenForm( CallableForm("Backgrounds"), Options, ThisObject, , , , , FormWindowOpeningMode.LockOwnerWindow );
				 
EndProcedure

&AtClient
Procedure HandleRequest( Command )
	
	Var CurrentRow;

	CurrentRow = Items.ReceivedRequests.CurrentRow;
	
	If ( CurrentRow = Undefined ) Then
		
		Return;
		
	EndIf;
	
	HandleRequestManually( CurrentRow );
	
	ShowMessageBox( , NStr("ru = 'Задание на обработку запроса запущено.'; en = 'Request processing job started.'") );
		
EndProcedure

&AtClient
Procedure LoadEventsHistory( Command )
	
	Var Notify;

	Notify = New NotifyDescription( "DoAfterSelectEventsFilter", ThisObject );
	OpenForm( CallableForm("FilterEventsHistory"), , ThisObject, , , , Notify, FormWindowOpeningMode.LockOwnerWindow );

EndProcedure

&AtClient
Procedure DoAfterSelectEventsFilter( Val Period, Val Params ) Export
	
	Var Records;
	Var Message;
	Var MessageBoxTitle;
	
	TIMEOUT = 5;
	
	If ( Period = Undefined ) Then
		
		Return;
		
	EndIf;
		
	Records = LoadEventsHistoryAtServer( Period );
	
	Message = NStr( "ru = 'Загружено записей: ';en = 'Records loaded: '" ) + Records;
	MessageBoxTitle = NStr( "ru = 'Загрузка истории событий';en = 'Loading history events'" );
	ShowMessageBox( Undefined, Message, TIMEOUT, MessageBoxTitle );
	
	Items.EventsHistory.Refresh();
	
EndProcedure

#EndRegion

#Region Private

&AtClient
Procedure SetFilter( Val Collection, Val Key, Val Value )
	
	CommonUseClientServer.AddCompositionItem( Collection, Key, DataCompositionComparisonType.Equal, Value );

EndProcedure

&AtClient
Procedure SetFilters( Val Ref )
	
	SetFilter( ReceivedRequests.Filter, "RequestHandler", Ref );
	SetFilter( EventsHistory.Filter, "Ref", Ref );
	
EndProcedure

&AtClient
Function CallableForm( Val Name )
	
	Return "Catalog.ExternalRequestHandlers.Form." + Name;
	
EndFunction

&AtClient
Procedure OpenJSONEditor( Val CurrentRow, Val Command )
	
	Var Options;
	
	If ( CurrentRow = Undefined ) Then
		
		Return;
		
	EndIf;
	
	Options = New Structure();
	Options.Insert( "RecordKey", CurrentRow );
	Options.Insert( "CommandName", Command.Name );
	OpenForm( CallableForm("JSONEditor"), Options, ThisObject, , , , , FormWindowOpeningMode.LockOwnerWindow );
	
EndProcedure

&AtServerNoContext
Procedure HandleRequestManually( Val RecordKey )
	
	DataProcessing.Manual( RecordKey.RequestHandler, RecordKey.CheckoutSHA );
	
EndProcedure

&AtServer
Function LoadEventsHistoryAtServer( Val Period )
	
	Var RequestHandler;
	
	RequestHandler = FormAttributeToValue( "Object" );
	RequestHandler.LoadEventsHistory( Period.StartDate, Period.EndDate );
	ValueToFormAttribute( RequestHandler, "Object" );
	
	Return RequestHandler.EventsHistory.Count();
	
EndFunction

#EndRegion
