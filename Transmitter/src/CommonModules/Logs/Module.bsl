#Region Public

// Events returns a collection of EventNames for use in the global context's WriteLogEvent() method.
// 
// Returns:
// 	Structure - collection:
// 	* Key - String - event key;
// 	* Value - String - EventName for WriteLogEvent();
//
Function Events() Export

	Result = New Structure();

	Result.Insert( "WS_REQUEST", NStr( "ru = 'WebService.ОбработкаЗапроса';en = 'WebService.QueryProcessing'" ));
	Result.Insert( "WS_REQUEST_BEGIN", NStr( "ru = 'WebService.ОбработкаЗапроса.Начало';
											|en = 'WebService.QueryProcessing.Begin'" ));
	Result.Insert( "WS_REQUEST_END", NStr( "ru = 'WebService.ОбработкаЗапроса.Окончание';
											|en = 'WebService.QueryProcessing.End'" ));
	Result.Insert( "ENDPOINT_SEND_FILE", NStr( "ru = 'Endpoint.ОтправкаФайла';en = 'Endpoint.SendingFile'" ));

	Return Result;
	
EndFunction

// Messages returns a collection of Commentaries for use in the global context's WriteLogEvent() method.
//  
// Returns:
// 	Structure - collection:
// 	* Key - String - comment key;
// 	* Value - String - comment for WriteLogEvent();
//
Function Messages() Export

	Result = New Structure();
	
	Result.Insert( "ENDPOINT_OPTIONS_MISSING", NStr( "ru = 'Отсутствуют параметры доставки файла.';
													|en = 'File delivery options are missing.'" ));
	Result.Insert( "EVENT_MISSING", NStr( "ru = 'В запросе отсутствует событие.';
										|en = 'The request is missing an event.'" ));
	Result.Insert( "EVENT_WRONG", NStr( "ru = 'Событие из запроса не соответствует выбранному методу.';
										|en = 'The request event does not match the selected method.'" ));
	Result.Insert( "KEY_MISSING", NStr( "ru = 'В запросе отсутствует секретный ключ.';
										|en = 'The request is missing a secret key.'" ));
	Result.Insert( "DESERIALIZING", NStr( "ru = 'Десериализация данных запроса.';
										|en = 'Deserializing request data.'" ));
	//todo rename KEY_NOT_FOUND ?
	Result.Insert( "KEY_NOT_FOUND", NStr( "ru = 'Секретный ключ не найден.';en = 'The Secret Key is not found.'" ));
	Result.Insert( "LOADING_DISABLED", NStr( "ru = 'Загрузка из внешнего хранилища отключена.';
											|en = 'Loading of the files is disabled.'" ));
	Result.Insert( "REQUEST_RECEIVED", NStr( "ru = 'Получен запрос с сервера GitLab.';
											|en = 'Received a request from the GitLab server.'" ));
	Result.Insert( "REQUEST_PROCESSED", NStr( "ru = 'Запрос с сервера GitLab обработан.';
											|en = 'The request from the GitLab server has been processed.'" ));
	Result.Insert( "URL_MISSING", NStr( "ru = 'В теле запроса не указан web_url проекта.';
											|en = 'The project web_url is not specified in the request body.'" ));
	Result.Insert( "WEBHOOK_NOT_FOUND", NStr( "ru = 'Обработчик событий не найден.';
											|en = 'Webhook not found.'" ));

	Return Result;
	
EndFunction

// Info adds an information event to the log. When an HTTPResponse or HTTPServiceResponse is passed to a procedure,
// an HTTP status code will be appended to the logged message event. For HTTPServiceResponse, this object will be
// augmented with logged message data for HTTP status codes that support this capability.
// 
// Parameters:
// 	Event - String - logged event in format: "Action.Operation1.Operation2...OperationN";
// 	Message - String - message text;
//  Object - AnyRef - a ref to an object which metadata needs to be added to the log;
//  Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
Procedure Info( Val Event, Val Message, Object = Undefined, Response = Undefined ) Export
	
	Var LogOptions;
	
	LogOptions = LogOptions( Object, Response );
	AppendResponseBody( LogOptions, EventLogLevel.Information, Message);
	Write( Event, EventLogLevel.Information, Message, LogOptions );

EndProcedure

// Warn adds an warning event to the log. When an HTTPResponse or HTTPServiceResponse is passed to a procedure,
// an HTTP status code will be appended to the logged message event. For HTTPServiceResponse, this object will be
// augmented with logged message data for HTTP status codes that support this capability.
// 
// Parameters:
// 	Event - String - logged event in format: "Action.Operation1.Operation2...OperationN";
// 	Message - String - message text;
//  Object - AnyRef - a ref to an object which metadata needs to be added to the log;
//  Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
Procedure Warn( Val Event, Val Message, Object = Undefined, Response = Undefined ) Export

	Var LogOptions;

	LogOptions = LogOptions( Object, Response );
	AppendResponseBody( LogOptions, EventLogLevel.Warning, Message );
	Write( Event, EventLogLevel.Warning, Message, LogOptions );

EndProcedure

// Error adds an error event to the log. When an HTTPResponse or HTTPServiceResponse is passed to a procedure,
// an HTTP status code will be appended to the logged message event. For HTTPServiceResponse, this object will be
// augmented with logged message data for HTTP status codes that support this capability.
// 
// Parameters:
// 	Event - String - logged event in format: "Action.Operation1.Operation2...OperationN";
// 	Message - String - message text;
//  Object - AnyRef - a ref to an object which metadata needs to be added to the log;
//  Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
Procedure Error( Val Event, Val Message, Object = Undefined, Response = Undefined ) Export

	Var LogOptions;
	
	LogOptions = LogOptions( Object, Response );
	AppendResponseBody( LogOptions, EventLogLevel.Error, Message );
	Write( Event, EventLogLevel.Error, Message, LogOptions );

EndProcedure

// AddPrefix returns the amended text of the message with a prefix in the format: "[Prefix]: Message".
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

// LogOptions returns additional parameters for the log event entry.
// 
// Returns:
// Structure - additional parameters:
//   * Object - AnyRef - a ref to an object which metadata needs to be added to the log;
//   * Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
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