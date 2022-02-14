#Region Public

// Events returns a list of logged event names.
// 
// Returns:
// 	Structure - event:
// 	* Key - String - key;
// 	* Value - String - logged event name;
//
Function Events() Export

	Result = New Structure();
	
	Result.Insert( "WS_REQUEST", NStr("ru = 'Веб-сервис';en = 'Web-service'") );
	Result.Insert( "AUTHENTICATION", NStr("ru = 'Аутентификация';en = 'Authentication'") );
	Result.Insert( "DATA_PROCESSING", NStr("ru = 'Обработка данных';en = 'Data processing'") );	

	Return Result;
	
EndFunction

// Messages returns a list of logged event texts.
//  
// Returns:
// 	Structure - event:
// 	* Key - String - key;
// 	* Value - String - logged event comment;
//
Function Messages() Export

	Result = New Structure();
	
	// BSLLS:LineLength-off
	Result.Insert( "REQUEST_RECEIVED", NStr("ru = 'получен запрос от внешнего хранилища';en = 'received a request from external storage'") );
	Result.Insert( "REQUEST_PROCESSED", NStr("ru = 'обработка запроса от внешнего хранилища завершена';en = 'processing of request from external storage completed'") );
	Result.Insert( "LOADING_DISABLED", NStr("ru = 'загрузка из внешнего хранилища отключена';en = 'loading files from external storage disabled'") );
	Result.Insert( "REQUEST_HANDLER_NOT_FOUND", NStr("ru = 'обработчик внешних запросов не найден';en = 'external request handler not found'") );
	Result.Insert( "SECRET_TOKEN_NOT_FOUND", NStr("ru = 'токен не найден';en = 'secret token not found'") );

	Result.Insert( "NO_EVENT", NStr("ru = 'в запросе нет события';en = 'no event in the request'") );
	Result.Insert( "NO_TOKEN", NStr("ru = 'в запросе нет токена';en = 'no secret token in the request'") );
	Result.Insert( "EVENT_WRONG", NStr("ru = 'событие запроса не соответствует выбранному методу';en = 'request event does not match the selected method.'") );
	Result.Insert( "NO_CHECKOUT_SHA", NStr("ru = 'в запросе нет ""checkout_sha""';en = 'the request does not contain ""checkout_sha""'") );

	Result.Insert( "DOWNLOAD_ERROR", NStr("ru = 'ошибка загрузки файла: URL: %1: описание ошибки:" + Chars.LF + "%2';en = 'file download error: URL: %1: error description:" + Chars.LF + "%2'") );

	Result.Insert( "NO_REQUEST_DATA", NStr("ru = 'нет данных запроса';en = 'no request data'") );	
	Result.Insert( "NO_UPLOAD_DATA", NStr("ru = 'нет данных для отправки';en = 'no data to upload'") );
	Result.Insert( "NO_COMMITS", NStr("ru = 'нет коммитов';en = 'no commits'") );
	Result.Insert( "NO_COMMIT", NStr("ru = 'нет коммита';en = 'no commit'") );
	Result.Insert( "NO_PROJECT", NStr("ru = 'нет данных с описанием проекта';en = 'no project description'") );
	Result.Insert( "NO_ROUTE", NStr("ru = 'не задан маршрут доставки файла';en = 'file delivery route not specified'") );
	
	Result.Insert( "DUMPED", NStr("ru = 'данные сохранены';en = 'data dumped'") );
	Result.Insert( "DUMP_ERROR", NStr("ru = 'ошибка сохранения данных: %1: описание ошибки:" + Chars.LF + "%2';en = 'dump error: %1: error description:" + Chars.LF + "%2'") );

	Result.Insert( "NO_ENDPOINT", NStr("ru = 'нет параметров доставки файла';en = 'no file delivery options'") );

	Result.Insert( "UPLOAD_FILE_JOB", NStr("ru = 'заданий на отправку файла: %1';en = 'file upload jobs: %1'") );
	// BSLLS:LineLength-on
	
	Return Result;
	
EndFunction

// Info adds an information event to the log and returns the text of the added comment.
// When an HTTPResponse or HTTPServiceResponse is passed to a procedure, an HTTP status code
// will be appended to the logged message event. For HTTPServiceResponse, this object will be
// augmented with logged message data for HTTP status codes that support this capability.
// 
// Parameters:
// 	Action - String - logged event in format: "Action1.Action2...ActionN";
// 	Message - String - message text;
// 	Prefix - String - prefix text;
//  Object - AnyRef - a ref to an object which metadata needs to be added to the log;
//  Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
// Returns:
// 	String - text of the added comment;
//
Function Info( Val Action, Val Message, Val Prefix = "", Object = Undefined, Response = Undefined ) Export
	
	Var LogOptions;
	Var Comment;
	
	LogOptions = LogOptions( Object, Response );
	Comment = AppendPrefix( Message, Prefix );
	AppendResponseBody( LogOptions, EventLogLevel.Information, Comment );
	Write( Action, EventLogLevel.Information, Comment, LogOptions );
	
	Return Comment;

EndFunction

// Warn adds an warning event to the log and returns the text of the added comment.
// When an HTTPResponse or HTTPServiceResponse is passed to a procedure, an HTTP status code
// will be appended to the logged message event. For HTTPServiceResponse, this object will be
// augmented with logged message data for HTTP status codes that support this capability.
// 
// Parameters:
// 	Action - String - logged event in format: "Action1.Action2...ActionN";
// 	Message - String - message text;
// 	Prefix - String - prefix text;
//  Object - AnyRef - a ref to an object which metadata needs to be added to the log;
//  Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
// Returns:
// 	String - text of the added comment;
//
Function Warn( Val Action, Val Message, Val Prefix = "", Object = Undefined, Response = Undefined ) Export

	Var LogOptions;
	Var Comment;

	LogOptions = LogOptions( Object, Response );
	Comment = AppendPrefix( Message, Prefix );
	AppendResponseBody( LogOptions, EventLogLevel.Warning, Comment );
	Write( Action, EventLogLevel.Warning, Comment, LogOptions );
	
	Return Comment;

EndFunction

// Error adds an error event to the log and returns the text of the added comment.
// When an HTTPResponse or HTTPServiceResponse is passed to a procedure, an HTTP status code
// will be appended to the logged message event. For HTTPServiceResponse, this object will be
// augmented with logged message data for HTTP status codes that support this capability.
// 
// Parameters:
// 	Action - String - logged event in format: "Action1.Action2...ActionN";
// 	Message - String - message text;
// 	Prefix - String - prefix text;
//  Object - AnyRef - a ref to an object which metadata needs to be added to the log;
//  Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
// Returns:
// 	String - text of the added comment;
//
Function Error( Val Action, Val Message, Val Prefix = "", Object = Undefined, Response = Undefined ) Export

	Var LogOptions;
	Var Comment;
	
	LogOptions = LogOptions( Object, Response );
	Comment = AppendPrefix( Message, Prefix );
	AppendResponseBody( LogOptions, EventLogLevel.Error, Message );
	Write( Action, EventLogLevel.Error, Comment, LogOptions );
	
	Return Comment;

EndFunction

// GetEventsHistory returns data from the event log by filter.
// 
// Parameters:
// 	Caller - String - synonym for the metadata object for which the log is collected;
// 	Filter - Structure - event log filter (see global context UnloadEventLog);
// 	
// Returns:
// 	ValueTable - event log data:
// 	* Date - Date - event date;
// 	* Level - EventLogLevel - log level;
// 	* Event - String - event name;
// 	* Data - Undefined, AnyRef - data;
// 	* DataPresentation - String - data presentation;
// 	* UserName - String - user name;
// 	* ApplicationPresentation - String - application name;
// 	* Comment - String - comment;
// 	* Action - String - action from event;
// 	* HTTPStatusCode - Number - HTTP status code or 0, if code undefined;
//
Function GetEventsHistory( Val Caller, Val Filter ) Export

	Var Log;
	Var Event;
	Var NewRecord;
	Var Result;
	
	COLUMNS = "Date, Level, Event, Data, DataPresentation, UserName, ApplicationPresentation, Comment";

	Log = New ValueTable();
	
	UnloadEventLog( Log, Filter, COLUMNS );
	
	Result = EventsHistory( Log );
	
	For Each Record In Log Do
		
		Event = GetEvent( Record );
		
		If ( Event.Context <> Caller ) Then
			
			Continue;
			
		EndIf;

		NewRecord = Result.Add();
		
		FillPropertyValues( NewRecord, Record );
		FillPropertyValues( NewRecord, Event );
 		
	EndDo;
	
	Return Result;

EndFunction

#EndRegion

#Region Private

Function StatusCodeLabel()
	
	Return NStr( "ru = 'код состояния: ';en = 'status code: '" );
	
EndFunction

Function GetStatusCode( Val Message )

	Var TypeNumber;
	
	If ( StrFind(Message, StatusCodeLabel()) = 0 ) Then
		
		Return 0;
		
	EndIf;

	TypeNumber = New TypeDescription( "Number" );
	
	Return TypeNumber.AdjustValue( Mid(Message, StrLen(StatusCodeLabel()) + 1, 3) );
	
EndFunction

Function GetStatusCodeMessage( Val StatusCode )
	
	Return StatusCodeLabel() + String( StatusCode ) + ": ";
	
EndFunction

Function EventsHistory( Val Source )
	
	Result = Source.CopyColumns();
	Result.Columns.Add( "Action", New TypeDescription("String") );
	Result.Columns.Add( "HTTPStatusCode", New TypeDescription("Number") );
	
	Return Result;
	
EndFunction

Function GetEvent( Val Record )

	Var Events;
	Var StatusCode;
	Var Result;

	Events = StrSplit( Record.Event, "." );
	StatusCode = GetStatusCode( Record.Comment );
	
	Result = New Structure();
	
	Result.Insert( "Context", Events[0] );

	If ( Events.Count() = 1 ) Then
		
		Return Result;
		
	EndIf;
	
	Result.Insert( "Action", Events[1] );
	Result.Insert( "HTTPStatusCode", StatusCode );
	Result.Insert( "Comment", StrReplace(Record.Comment, GetStatusCodeMessage(StatusCode), "") );
	
	Return Result;
	
EndFunction

Function LogOptions( Val Object = Undefined, Val Response = Undefined )
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "Object", Object );
	Result.Insert( "Response", Response );
	
	Return Result;
	
EndFunction

Procedure AppendStatusCode( Message, Val LogOptions )
	
	Var Response;
	
	Response = CommonUseClientServer.StructureProperty( LogOptions, "Response" );

	If ( Response = Undefined ) Then
		
		Return;
		
	EndIf;
			
	Message = GetStatusCodeMessage( Response.StatusCode ) + Message;
		
EndProcedure

Procedure AppendResponseBody( LogOptions, Val Level, Val Message )
	
	Var Response;
	Var Body;
	
	Response = CommonUseClientServer.StructureProperty( LogOptions, "Response" );
	
	If ( Response = Undefined ) Then
		
		Return;
		
	EndIf;
	
	If ( HTTPStatusCodesClientServerCached.IsBadRequest(Response.StatusCode) ) Then

		Response.Headers.Insert( "Content-Type", "application/json" );
		Body = HTTPServices.CreateMessage(Message);
		Response.SetBodyFromString( HTTPConnector.ObjectToJson(Body) );

	EndIf;
	
	If ( HTTPStatusCodesClientServerCached.IsInternalServerError(Response.StatusCode) ) Then

		Response.Headers.Insert( "Content-Type", "text/plain" );
		Response.SetBodyFromString( HTTPConnector.ObjectToJson(Message) );

	EndIf;
	
EndProcedure

Function AppendPrefix( Val Message, Val Prefix )
	
	If IsBlankString(Prefix) Then
		
		Return Message;
		
	EndIf;

	Return "[ " + Prefix + " ]: " + Message;

EndFunction

Procedure Write( Val Action, Val Level, Val Message, Val LogOptions )
	
	Var Event;
	Var Object;
	
	Event = Metadata.Catalogs.ExternalRequestHandlers.Synonym + "." + Action;
	Object = CommonUseClientServer.StructureProperty( LogOptions, "Object" );
	
	AppendStatusCode( Message, LogOptions );

	If ( Object = Undefined ) Then

		WriteLogEvent( Event, Level, , , Message );

	Else

		WriteLogEvent( Event, Level, Metadata.FindByType(TypeOf(Object)), Object, Message );

	EndIf;

EndProcedure

#EndRegion