#Region Public

// GetConnectionParams returns connection parameters to the endpoint service.
// 
// Returns:
// Structure - description:
// * User - String - user name;
// * Password - String - user password;
// * Timeout - Number - connection timeout, sec. (0 - timeout is not set);
//
Function GetConnectionParams() Export
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "User", ServicesSettings.EndpointUserName() );
	Result.Insert( "Password", ServicesSettings.EndpointUserPassword() );
	Result.Insert( "Timeout", ServicesSettings.DeliveryFileTimeout() );
	
	Return Result;
	
EndFunction

// SetURL sets the delivery URL for the endpoint connection parameters. 
// 
// Parameters:
// 	Params - Structure - parameters (see GetConnectionParams);
// 	URL - String - endpoint service URL;
//
Procedure SetURL( Params, Val URL ) Export
	
	Params.Insert( "URL", URL );
	
EndProcedure

// SendFile sends a file to the endpoint infobase. The endpoint service must implement the API
// see https://app.swaggerhub.com/apis-docs/astrizhachuk/epf-endpoint
// 
// Parameters:
//	FileName - String - the filename used to replace files in the endpoint infobase (UTF-8);
//	Data - BinaryData - file body;
//	Endpoint - Structure - upload file options:
// * URL - String - endpoint service URL;
// * User - String - user name;
// * Password - String - user password;
// * Timeout - Number - connection timeout, sec. (0 - timeout is not set);
//	Options - Undefined, Structure - additional parameters for logging the result of sending a file:
// * GetRequestHandler - CatalogRef.ExternalRequestHandlers - ref to external request handler;
// * CheckoutSHA - String - event identifier (commit SHA) for which the file sending is initiated;
//
// Returns:
// 	String - the result of the operation with a response from the endpoint;
//
Function SendFile( Val FileName, Val Data, Val Endpoint, Options = Undefined ) Export

	Var Headers;
	Var RequestParams;
	Var Response;
	Var StatusCode;
	Var Message;
	
	StatusCode = Undefined; // undefined for internal errors

	Try
		
		Assert( Endpoint );
		
		Headers = New Map();
		Headers.Insert( "name", EncodeString(FileName, StringEncodingMethod.URLInURLEncoding) );

		RequestParams = New Structure();
		RequestParams.Insert( "Authentication", GetAuthentication(Endpoint) );
		RequestParams.Insert( "Headers", Headers );
		RequestParams.Insert( "Timeout", Endpoint.Timeout );
		
		Response = HTTPConnector.Post( Endpoint.URL, Data, RequestParams );
		
		Message = CreateResponseMessage( Endpoint.URL, FileName, Response );
		
		StatusCode = Response.StatusCode;
	
		If ( NOT StatusCodes().isOk(StatusCode) ) Then
			
			Raise Message;
			
		EndIf;
		
		Message = AddMessagePrefix( Message, Options );
		Logs.Info( Logs.Events().ENDPOINT_SEND_FILE, Message, GetRequestHandler(Options), NewResponse(StatusCode) );
		
	Except
		
		Message = AddMessagePrefix( ErrorInfo().Description, Options );
		Logs.Error( Logs.Events().ENDPOINT_SEND_FILE, Message, GetRequestHandler(Options), NewResponse(StatusCode) );
		
		Raise Message;
		
	EndTry;
	
	Return Message;
		
EndFunction

#EndRegion

#Region Private

Function GetAuthentication( Val ConnectionParams )
	
	Var Result;

	Result = New Structure();
	Result.Insert( "User", ConnectionParams.User );
	Result.Insert( "Password", ConnectionParams.Password );
	
	Return Result;
	
EndFunction

Procedure Assert( Val Endpoint )
	
	If ( NOT (Endpoint.Property("URL") AND Endpoint.Property("User") AND Endpoint.Property("Password")) ) Then
	
		Raise Logs.Messages().ENDPOINT_OPTIONS_MISSING;
		
	EndIf;
	
EndProcedure

Function StatusCodes()
	
	Return HTTPStatusCodesClientServerCached;
	
EndFunction

Function CreateResponseMessage( Val URL, Val FileName, Val Response )
	
	Var ResponseBody;
	Var Message;
	
	Message = NStr( "ru = 'URL: %1; имя файла: %2
					|Код ответа: %3
					|%4';
					|en = 'URL: %1; filename: %2
					|Status code: %3
					|%4'" );

	ResponseBody = HTTPConnector.AsText(Response, TextEncoding.UTF8);
	
	Return StrTemplate( Message, URL, FileName, Response.StatusCode, ResponseBody );
	
EndFunction

Function AddMessagePrefix( Val Message, Val Options )
	
	Var CheckoutSHA;
	
	CheckoutSHA = CommonUseClientServer.StructureProperty( Options, "CheckoutSHA" );
	
	If ( CheckoutSHA = Undefined ) Then
		
		Return Message;
		
	EndIf;

	Return Logs.AddPrefix( Message, CheckoutSHA );
	
EndFunction

Function NewResponse( Val StatusCode )
	
	If ( StatusCode = Undefined ) Then
		
		Return StatusCode;
	
	EndIf;
		
	Return New HTTPServiceResponse( StatusCode );
	
EndFunction

Function GetRequestHandler( Val Options )
	
	Return CommonUseClientServer.StructureProperty( Options, "ExternalRequestHandler" );
	
EndFunction

#EndRegion
