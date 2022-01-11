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
	
	Result.Insert( "WS_REQUEST", NStr("ru = 'ВебСервис';en = 'WebService'") );
	Result.Insert( "AUTHENTICATION", NStr("ru = 'Аутентификация';en = 'Authentication'") );
	Result.Insert( "DATA_PROCESSING", NStr("ru = 'ОбработкаДанных';en = 'DataProcessing'") );	

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

	Result.Insert( "DOWNLOADED", NStr("ru = 'файлы из внешнего хранилища загружены';en = 'files from external storage loaded'") );
	Result.Insert( "DOWNLOAD_ERROR", NStr("ru = 'ошибка загрузки файла: URL: %1: описание ошибки:" + Chars.LF + "%2';en = 'file download error: URL: %1: error description:" + Chars.LF + "%2'") );

	Result.Insert( "NO_REQUEST_DATA", NStr("ru = 'нет данных запроса';en = 'no request data'") );	
	Result.Insert( "NO_UPLOAD_DATA", NStr("ru = 'нет данных для отправки';en = 'no data to upload'") );
	Result.Insert( "NO_COMMITS", NStr("ru = 'нет коммитов';en = 'no commits'") );
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
// 	Event - String - logged event in format: "Action.Operation1.Operation2...OperationN";
// 	Message - String - message text;
// 	Prefix - String - prefix text;
//  Object - AnyRef - a ref to an object which metadata needs to be added to the log;
//  Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
// Returns:
// 	String - text of the added comment;
//
Function Info( Val Event, Val Message, Val Prefix = "", Object = Undefined, Response = Undefined ) Export
	
	Var LogOptions;
	Var Comment;
	
	LogOptions = LogOptions( Object, Response );
	Comment = AppendPrefix( Message, Prefix );
	AppendResponseBody( LogOptions, EventLogLevel.Information, Comment);
	Write( Event, EventLogLevel.Information, Comment, LogOptions );
	
	Return Comment;

EndFunction

// Warn adds an warning event to the log and returns the text of the added comment.
// When an HTTPResponse or HTTPServiceResponse is passed to a procedure, an HTTP status code
// will be appended to the logged message event. For HTTPServiceResponse, this object will be
// augmented with logged message data for HTTP status codes that support this capability.
// 
// Parameters:
// 	Event - String - logged event in format: "Action.Operation1.Operation2...OperationN";
// 	Message - String - message text;
// 	Prefix - String - prefix text;
//  Object - AnyRef - a ref to an object which metadata needs to be added to the log;
//  Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
// Returns:
// 	String - text of the added comment;
//
Function Warn( Val Event, Val Message, Val Prefix = "", Object = Undefined, Response = Undefined ) Export

	Var LogOptions;
	Var Comment;

	LogOptions = LogOptions( Object, Response );
	Comment = AppendPrefix( Message, Prefix );
	AppendResponseBody( LogOptions, EventLogLevel.Warning, Comment );
	Write( Event, EventLogLevel.Warning, Comment, LogOptions );
	
	Return Comment;

EndFunction

// Error adds an error event to the log and returns the text of the added comment.
// When an HTTPResponse or HTTPServiceResponse is passed to a procedure, an HTTP status code
// will be appended to the logged message event. For HTTPServiceResponse, this object will be
// augmented with logged message data for HTTP status codes that support this capability.
// 
// Parameters:
// 	Event - String - logged event in format: "Action.Operation1.Operation2...OperationN";
// 	Message - String - message text;
// 	Prefix - String - prefix text;
//  Object - AnyRef - a ref to an object which metadata needs to be added to the log;
//  Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
// Returns:
// 	String - text of the added comment;
//
Function Error( Val Event, Val Message, Val Prefix = "", Object = Undefined, Response = Undefined ) Export

	Var LogOptions;
	Var Comment;
	
	LogOptions = LogOptions( Object, Response );
	Comment = AppendPrefix( Message, Prefix );
	AppendResponseBody( LogOptions, EventLogLevel.Error, Message );
	Write( Event, EventLogLevel.Error, Comment, LogOptions );
	
	Return Comment;

EndFunction

#EndRegion

#Region Private

Function LogOptions( Val Object = Undefined, Val Response = Undefined )
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "Object", Object );
	Result.Insert( "Response", Response );
	
	Return Result;
	
EndFunction

Procedure AppendStatusCode( Event, Val LogOptions )
	
	Var Response;
	
	Response = CommonUseClientServer.StructureProperty( LogOptions, "Response" );

	If ( Response <> Undefined ) Then
			
		Event = Event + "." + String( Response.КодСостояния );
		
	EndIf;

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

Function AppendPrefix( Message, Val Prefix )
	
	If IsBlankString(Prefix) Then
		
		Return Message;
		
	EndIf;

	Return "[ " + Prefix + " ]: " + Message;

EndFunction

Procedure Write( Val Event, Val Level, Val Message, Val LogOptions )
	
	Var Object;
	
	AppendStatusCode( Event, LogOptions );

	Event = Metadata.Catalogs.ExternalRequestHandlers.Synonym + "." + Event;
	
	Object = CommonUseClientServer.StructureProperty( LogOptions, "Object" );

	If ( Object = Undefined ) Then

		WriteLogEvent( Event, Level, , , Message);

	Else

		WriteLogEvent( Event, Level, Metadata.FindByType(TypeOf(Object)), Object, Message );

	EndIf;

EndProcedure

#EndRegion