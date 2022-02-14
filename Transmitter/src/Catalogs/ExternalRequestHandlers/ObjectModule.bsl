#If Server OR ThickClientOrdinaryApplication OR ExternalConnection Тогда

#Region Public

// LoadEventsHistory loads the event log data to the event handler's tabular section.
// 
// Parameters:
// 	StartDate - Date - start date of events;
// 	EndDate - Date - end date of events;
//
Procedure LoadEventsHistory( Val StartDate, Val EndDate ) Export
	
	Var Filter;
	Var NewEvent;

	Filter = New Structure();
	Filter.Insert( "StartDate", StartDate );
	Filter.Insert( "EndDate", EndDate );
	
	Events = Logs.GetEventsHistory( ThisObject.Metadata().Synonym, Filter );
	
	EventsHistory.Clear();
	
	For Each Event In Events Do
		
		If NOT ( Event.Data = Undefined OR Event.Data = Ref ) Then
			
			Continue;
			
		EndIf;
		
		NewEvent = EventsHistory.Add();
		FillPropertyValues( NewEvent, Event );
			
	EndDo;

	Write();
	
EndProcedure

#EndRegion

#Region EventHandlers

Procedure BeforeWrite( Cancel )
	
	Var Items;
	
	If ( Cancel OR DataExchange.Load ) Then
		
		Return;

	EndIf;
	
	Items = Catalogs.ExternalRequestHandlers.FindByURL( ProjectURL );
	
	For Each Item In Items Do
		
		If ( Ref = Item.Ref ) Then

			Continue;
			
		EndIf;
		
		Cancel = True;
		
		Return;
		
	EndDo;

EndProcedure

#EndRegion

#EndIf
