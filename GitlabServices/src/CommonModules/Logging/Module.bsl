#Region Public

// Info adds an information event to the log. When an HTTPResponse or HTTPServiceResponse is passed to a procedure,
// an HTTP status code will be appended to the logged message event. For HTTPServiceResponse, this object will be
// augmented with logged message data for HTTP status codes that support this capability.
// 
// Parameters:
// 	Event - String - logged event in format: "Action.Operation1.Operation2...OperationN";
// 	Message - String - message text;
//  Object - AnyRef - a ref to an object whose metadata needs to be added to the log;
//  Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
Procedure Info( Val Event, Val Message, Object = Undefined, Response = Undefined ) Export
	
	Var LoggingOptions;
	
	LoggingOptions = LoggingOptions( Object, Response );
	AddResponseBody( LoggingOptions, EventLogLevel.Information, Message);
	Write( Event, EventLogLevel.Information, Message, LoggingOptions);

EndProcedure

// Warn adds an warning event to the log. When an HTTPResponse or HTTPServiceResponse is passed to a procedure,
// an HTTP status code will be appended to the logged message event. For HTTPServiceResponse, this object will be
// augmented with logged message data for HTTP status codes that support this capability.
// 
// Parameters:
// 	Event - String - logged event in format: "Action.Operation1.Operation2...OperationN";
// 	Message - String - message text;
//  Object - AnyRef - a ref to an object whose metadata needs to be added to the log;
//  Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
Procedure Warn( Val Event, Val Message, Object = Undefined, Response = Undefined ) Export

	Var LoggingOptions;

	LoggingOptions = LoggingOptions( Object, Response );
	AddResponseBody( LoggingOptions, EventLogLevel.Warning, Message );
	Write( Event, EventLogLevel.Warning, Message, LoggingOptions );

EndProcedure

// Error adds an error event to the log. When an HTTPResponse or HTTPServiceResponse is passed to a procedure,
// an HTTP status code will be appended to the logged message event. For HTTPServiceResponse, this object will be
// augmented with logged message data for HTTP status codes that support this capability.
// 
// Parameters:
// 	Event - String - logged event in format: "Action.Operation1.Operation2...OperationN";
// 	Message - String - message text;
//  Object - AnyRef - a ref to an object whose metadata needs to be added to the log;
//  Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
Procedure Error( Val Event, Val Message, Object = Undefined, Response = Undefined ) Export

	Var LoggingOptions;
	
	LoggingOptions = LoggingOptions( Object, Response );
	AddResponseBody( LoggingOptions, EventLogLevel.Error, Message );
	Write( Event, EventLogLevel.Error, Message, LoggingOptions );

EndProcedure

// AddPrefixReturns the amended text of the message with a prefix in the format: "[Prefix]: Message".
// 
// Parameters:
// 	Message - String - message text;
// 	Prefix - String - prefix;
// 	
// Returns:
// 	String - message text with a prefix;
//
Function AddPrefix( Message, Val Prefix ) Export

	Return "[ " + Prefix + " ]: " + Message;

EndFunction

#EndRegion

#Region Private

Function LogLevelMap()
	
	Var Result;
	
	Result = New Map();
	Result.Insert( NStr("ru = 'Информация';en = 'Information'"), "info" );
	Result.Insert( NStr("ru = 'Предупреждение';en = 'Warning'"), "warning" );
	Result.Insert( NStr("ru = 'Ошибка';en = 'Error'"), "error" );
	
	Return Result;
		
EndFunction

Procedure AppendStatusCode( Event, Val LoggingOptions )
	
	Var Response;
	
	Response = CommonUseClientServer.StructureProperty( LoggingOptions, "HTTPResponse" );

	If ( Response <> Undefined ) Then
			
		Event = Event + "." + String( Response.КодСостояния );
		
	EndIf;

EndProcedure

Procedure AddResponseBody( LoggingOptions, Val Level, Val Message )
	
	Var HTTPResponse;
	Var AddBody;
	Var Body;
	
	HTTPResponse = CommonUseClientServer.StructureProperty( LoggingOptions, "HTTPResponse" );
	
	If ( HTTPResponse = Undefined ) Then
		
		Return;
		
	EndIf;
	
	AddBody = ( HTTPStatusCodesClientServerCached.isOk(HTTPResponse.КодСостояния)
			OR HTTPStatusCodesClientServerCached.isForbidden(HTTPResponse.КодСостояния)
			OR HTTPStatusCodesClientServerCached.isLocked(HTTPResponse.КодСостояния) );

	If ( AddBody ) Then

		HTTPResponse.Headers.Insert( "Content-Type", "application/json" );
		
		Body = HTTPServices.ResponseTemplate();
		Body.message = Message;
		Body.type = LogLevelMap().Get( String(Level) );

		HTTPResponse.SetBodyFromString( HTTPConnector.ОбъектВJson(Body) );

	EndIf;
	
EndProcedure

Procedure Write( Val Event, Val Level, Val Message, Val LoggingOptions )
	
	Var Object;
	
	EVENT_CONTEXT = NStr( "ru = 'ОбработчикиСобытий';en = 'Webhooks'" ); 
	
	AppendStatusCode( Event, LoggingOptions );

	Event = EVENT_CONTEXT + "." + Event;
	
	Object = CommonUseClientServer.StructureProperty( LoggingOptions, "Object" );

	If ( Object = Undefined ) Then

		WriteLogEvent( Event, Level, , , Message);

	Else

		WriteLogEvent( Event, Level, Metadata.FindByType(TypeOf(Object)), Object, Message );

	EndIf;

EndProcedure

// LoggingOptions returns additional parameters for the log event entry.
// 
// Returns:
// Structure - additional parameters:
//   * Object - AnyRef - a ref to an object whose metadata needs to be added to the log;
//   * Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
Function LoggingOptions( Val Object = Undefined, Val Response = Undefined )
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "Object", Object );
	Result.Insert( "HTTPResponse", Response );
	
	Return Result;
	
EndFunction

#EndRegion