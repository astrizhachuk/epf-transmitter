#Region FormEventHandlers

&AtClient
Procedure OnOpen( Cancel )
	
	УстановитьОтборыСписков( Object.Ref );
	
EndProcedure

#EndRegion

#Region FormTableItemsEventHandlers

&AtClient
Procedure ReceivedRequestsSelection( Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Return;

EndProcedure

#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure DoAfterLoadEventsHistory( Value, Params ) Export
	
	Var RecordsLoaded;
	Var Message;
	Var MessageBoxTitle;
	
	TIMEOUT = 5;
	
	If ( Value = Undefined ) Then
		
		Return;
		
	EndIf;
	
	RecordsLoaded = 0;
	
	LoadEventsHistoryAtServer( Value, RecordsLoaded );

	Message = NStr( "ru = 'Добавлено записей: ';en = 'Records added: '" ) + RecordsLoaded;
	MessageBoxTitle = NStr( "ru = 'Загрузка истории событий';en = 'Loading History Events'" );
	ShowMessageBox( Undefined, Message, TIMEOUT, MessageBoxTitle );
	
EndProcedure

&AtClient
Procedure LoadEventsHistory( Command )
	Var Notify;

	Notify = New NotifyDescription("DoAfterLoadEventsHistory", ThisObject);

	OpenForm( "Catalog.ExternalRequestHandlers.Form.FilterEventsHistory",
			 ,
			 ThisObject,
			 ,
			 ,
			 ,
			 Notify,
			 FormWindowOpeningMode.LockOwnerWindow );

EndProcedure

&AtClient
Procedure ResendData( Command )
	
	Var CurrentRow;

	CurrentRow = Items.ReceivedRequests.CurrentRow;
	
	If ( CurrentRow = Undefined ) Then
		
		Return;
		
	EndIf;
	
	ResendDataAtServer( CurrentRow );
	
	ShowMessageBox( , NStr("ru = 'Запущена повторная обработка запроса.'; en = 'Resend the request was started.'") );
		
EndProcedure

&AtClient
Procedure OpenQueryJSON( Command )
	
	OpenEditorJSON( Items.ReceivedRequests.CurrentRow, Command );

EndProcedure

&AtClient
Procedure OpenRoutingJSON( Command )
	
	OpenEditorJSON( Items.ReceivedRequests.CurrentRow, Command );

EndProcedure

&AtClient
Procedure DoAfterApplicationStart( ReturnCode, AdditionalParameters ) Export
	// No processing is required.
EndProcedure

&AtClient
Procedure OpenMergeRequestRemote( Command )
	
	Var CurrentRow;
	Var MergeRequestURL;
	Var Notify;
	
	CurrentRow = Items.ReceivedRequests.CurrentRow;
	
	If ( CurrentRow = Undefined ) Then
		
		Return;
		
	EndIf;

	MergeRequestURL = MergeRequestURL( CurrentRow );
	
	If ( NOT IsBlankString(MergeRequestURL) ) Then
		
		#If WebClient Then
			
			GotoURL( MergeRequestURL );
			
		#Else
			
			Notify = New NotifyDescription( "DoAfterApplicationStart", ThisObject );
			BeginRunningApplication( Notify,  MergeRequestURL );
			
   		#EndIf
   				
	EndIf;
	
EndProcedure

&AtClient
Procedure OpenBackgroundJobs( Command )
	
	Var CurrentRow;
	Var Filter;
	
	CurrentRow = Items.ReceivedRequests.CurrentRow;
	
	If ( CurrentRow = Undefined ) Then
		
		Return;
		
	EndIf;
	
	Filter = New Structure();
	Filter.Insert( "RecordKey", CurrentRow );
				 
	OpenForm( "Catalog.ExternalRequestHandlers.Form.BackgroundJobs",
			 Filter,
			 ThisObject,
			 ,
			 ,
			 ,
			 ,
			 FormWindowOpeningMode.LockOwnerWindow );
				 
EndProcedure

#EndRegion

#Region Private

&AtClient
Procedure SetFilter( Val Collection, Val Key, Val Value )
	
	CommonUseClientServer.AddCompositionItem( Collection,
															Key,
															DataCompositionComparisonType.Equal,
															Value );

EndProcedure

&AtClient
Procedure УстановитьОтборыСписков( Val Ref )
	
	SetFilter( ReceivedRequests.Filter, "RequestHandler", Ref );
	SetFilter( ExternalFiles.Filter, "RequestHandler", Ref );
	SetFilter( EventsHistory.Filter, "Ссылка", Ref );
	
EndProcedure

&AtServer
Procedure LoadEventsHistoryAtServer( Val Period, RecordsLoaded = 0 )
	
	ObjectData = ThisObject.FormAttributeToValue( "Object" );
	
	Filter = New Structure();
	Filter.Insert( "StartDate", Period.StartDate );
	Filter.Insert( "EndDate", Period.EndDate );
	
	LoadEventsHistoryFromModule( ObjectData, "EventsHistory", Filter, RecordsLoaded );

	ThisObject.ValueToFormAttribute( ObjectData, "Object" );
	
	Items.EventsHistory.Обновить();
	
EndProcedure

&AtServerNoContext
Procedure ResendDataAtServer( Val RecordKey )
	
	DataProcessing.RunBackgroundJob( RecordKey.RequestHandler, RecordKey.CheckoutSHA );
	
EndProcedure

&AtClient
Procedure OpenEditorJSON( Val CurrentRow, Val Command )
	
	Var OpenOptions;
	
	If ( CurrentRow = Undefined ) Then
		
		Return;
		
	EndIf;
	
	OpenOptions = New Structure();
	OpenOptions.Insert( "RecordKey", CurrentRow );
	OpenOptions.Insert( "CommandName", Command.Name );

	OpenForm( "Catalog.ExternalRequestHandlers.Form.EditorJSON",
				OpenOptions,
				ThisObject,
				,
				,
				,
				,
				FormWindowOpeningMode.LockOwnerWindow );
	
EndProcedure

&AtServerNoContext
Function MergeRequestURL( Val RecordKey )
	
	Var RequestData;
	Var ProjectParams;
	Var MergeRequests;
	Var MergeCommitSHA;
	Var Result;
	
	RequestData = ExternalRequests.GetFromIB( RecordKey.RequestHandler, RecordKey.CheckoutSHA );
	
	ProjectParams = GitLabAPI.GetProject( RequestData );

	// TODO тут необработанное исключение, когда по URL невозможно получить JSON с MR (неверная ссылка или сервер лежит),
	// подумать, или зарегать в ишузах 
	MergeRequests = GitLabAPI.GetMergeRequests( ProjectParams.URL, ProjectParams.Id ); 

	Result = "";
	
	For Each MergeRequest In MergeRequests Do
		
		MergeCommitSHA = MergeRequest.Get( "merge_commit_sha" );
		
		If ( MergeCommitSHA = Undefined OR MergeCommitSHA <> RecordKey.CheckoutSHA ) Then
			
			Continue;
			
		EndIf;
		
		Result = MergeRequest.Get( "web_url" );
		
		If ( Result <> Undefined ) Then
			
			Return Result;

		EndIf;

	EndDo;
	
	Return Result;

EndFunction

// TODO проверить, почему это ранее было в общем модуле

// LoadEventsHistory loads data from the event log into the object by filter.
// 
// Parameters:
// 	Object - CatalogObject.ExternalRequestHandlers - target object; 
// 	Destination - String - tabular section name;
// 	Filter - Structure - event log filter (see global context UnloadEventLog);
// 	RecordsLoaded - Number - (returned) number of loaded records;
//
Procedure LoadEventsHistoryFromModule( Object, Val Destination, Val Filter, RecordsLoaded )
	
	If ( NOT Filter.Property( "Data" ) ) Then
		
		Filter.Insert( "Data", Object.Ref );
		
	EndIf;
	
	Catalogs.ExternalRequestHandlers.LoadEventsHistory( Object, Destination, Filter, RecordsLoaded );
	
EndProcedure

#EndRegion