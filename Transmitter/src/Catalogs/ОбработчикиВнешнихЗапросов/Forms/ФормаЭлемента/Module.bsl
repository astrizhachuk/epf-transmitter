// @strict-types

#Region FormEventHandlers

&AtClient
Procedure OnOpen( Cancel )
	
	SetFilters( Объект.Ref );
	
EndProcedure

#КонецОбласти

#Region FormTableItemsEventHandlers

&AtClient
Procedure ReceivedRequestsSelection(Item, RowSelected, Field, StandardProcessing)
	
	StandardProcessing = False;
	
	Return;
	
EndProcedure

#КонецОбласти

#Region FormCommandsEventHandlers

&AtClient
Procedure OpenRepositoryOnRemote( Command )
	
	If ( IsBlankString(Объект.ProjectURL) ) Then
		
		Return;
		
	EndIf;
	
	GotoURL( Объект.ProjectURL );
	
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
Procedure ЗагрузитьИсториюСобытий( Command )
	
	Var Notify;

	Notify = New NotifyDescription( "DoAfterSelectEventsFilter", ThisObject );
	OpenForm( CallableForm("ОтборИсторииСобытий"), , ThisObject, , , , Notify, FormWindowOpeningMode.LockOwnerWindow );

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
	
	Items.ИсторияСобытий.Refresh();
	
EndProcedure

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&AtClient
Procedure SetFilter( Val Collection, Val Key, Val Value )
	
	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки( Collection, Key, DataCompositionComparisonType.Equal, Value );

EndProcedure

&AtClient
Procedure SetFilters( Val Ref )
	
	SetFilter( ReceivedRequests.Filter, "RequestHandler", Ref );
	SetFilter( ИсторияСобытий.Filter, "Ref", Ref );
	
EndProcedure

&AtClient
Function CallableForm( Val Name )
	
	Return "Справочник.ОбработчикиВнешнихЗапросов.Форма." + Name;
	
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
	
	ОбработкаДанных.ОбработатьЗагруженныеДанные( RecordKey.RequestHandler, RecordKey.CheckoutSHA );
	
EndProcedure

&AtServer
Function LoadEventsHistoryAtServer( Знач Период )
	
	Обработчик = РеквизитФормыВЗначение( "Объект" );
	Обработчик.ЗагрузитьИсториюСобытий( Период.ДатаНачала, Период.ДатаОкончания );
	ValueToFormAttribute( Обработчик, "Объект" );
	
	Return Обработчик.ИсторияСобытий.Count();
	
EndFunction

#КонецОбласти
