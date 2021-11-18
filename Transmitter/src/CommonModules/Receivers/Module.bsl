#Region Public

// todo move up "URL"

// GetConnectionParams returns connection parameters to the endpoint service.
// 
// Returns:
// Structure - description:
// * URL - String - endpoint service URL;
// * User - String - user name;
// * Password - String - user password;
// * Timeout - Number - connection timeout, sec. (0 - timeout is not set);
//
Function GetConnectionParams() Export
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "URL", "" );
	Result.Insert( "User", ServicesSettings.ReceiverUserName() );
	Result.Insert( "Password", ServicesSettings.ReceiverUserPassword() );
	Result.Insert( "Timeout", ServicesSettings.DeliveryFileTimeout() );
	
	Return Result;
	
EndFunction

// TODO rewrite descr (proc to func), I want to receive the execution result not through the log

// SendFile send the file to the endpoint infobase. The file delivery endpoint service must implement the API
// for the recipient infobase, see https://app.swaggerhub.com/apis/astrizhachuk/epf-transmitter
// 
// Parameters:
//	FileName - String - the file name used for searching and replacing external reports and processing (UTF-8);
//	BinaryData - BinaryData - binary file body;
//	ConnectionParams - Structure - file delivery parameters:
// * URL - String - end-point service URL;
// * Token - String - access token to the service;
// * Timeout - Number - the connection timeout, sec (0 - timeout is not set);
//	EventParams - Undefined, Structure - description of the event that started sending the file:
// * Webhook - CatalogRef.Webhooks - a ref to webhook;
// * CheckoutSHA - String - event identifier (commit SHA) for which the file upload is triggered;
//
Function SendFile( Val FileName, Val BinaryData, Val ConnectionParams, EventParams = Undefined ) Export

	Var Headers;
	Var RequestParams;
	Var Response;
	Var Message;

	Response = Undefined;

	Try
		
		CheckConnectionParams( ConnectionParams ); 
		
		Headers = New Map();
		Headers.Insert( "Token", ConnectionParams.Token );
		Headers.Insert( "Name", EncodeString(FileName, StringEncodingMethod.URLInURLEncoding) );
		
		RequestParams = New Structure();
		RequestParams.Insert( "Authentication", GetAuthentication(ConnectionParams) );
		RequestParams.Insert( "Headers", Headers );
		RequestParams.Insert( "Timeout", ConnectionParams.Timeout );
		
		Response = HTTPConnector.Post( ConnectionParams.URL, BinaryData, RequestParams );
		
		Message = CreateSendFileResultMessage( Response, FileName, ConnectionParams.URL );
	
		If ( NOT HTTPStatusCodesClientServerCached.isOk(Response.StatusCode) ) Then
			
			Raise Message;
			
		EndIf;
		
		LoggingSendFileResult( Message, EventParams, Response.StatusCode );
		
	Except
		
		Message = ErrorInfo().Description;
		
		LoggingSendFileResult( Message, EventParams, StatusCode(Response) );
		
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

Procedure CheckConnectionParams( Val SendFileParams )
	
	MISSING_DELIVERED_MESSAGE = NStr( "ru = 'Отсутствуют параметры доставки файлов.';
									|en = 'File delivery options are missing.'" );
	
	If ( TypeOf(SendFileParams) <> Type("Structure")
				OR NOT SendFileParams.Property("URL")
				OR NOT SendFileParams.Property("Token") ) Then
			
			Raise MISSING_DELIVERED_MESSAGE;
			
	EndIf;
	
EndProcedure

Function StatusCode( Val Response )
	
	Var Result;
	
	If ( Response = Undefined ) Then
			
		Result = HTTPStatusCodesClientServerCached.FindCodeById("INTERNAL_SERVER_ERROR");
			
	Else
			
		Result = Response.StatusCode;
			
	EndIf;
	
	Возврат Result;
	
EndFunction

Procedure LoggingSendFileResult( Message, Val EventParams, Val StatusCode )
	
	Var NewResponse;
	
	EVENT_MESSAGE = NStr( "ru = 'Core.ОтправкаДанныхПолучателю';en = 'Core.SendingFileReceiver'" );
	
	Webhook = Undefined;
	NewResponse = Undefined;

	If ( EventParams <> Undefined ) Then
		
		Webhook = EventParams.Webhook;
		NewResponse = New HTTPServiceResponse( StatusCode );
		Message = Logging.AddPrefix( Message, EventParams.CheckoutSHA );
			
	EndIf;

	If ( HTTPStatusCodesClientServerCached.isOk(StatusCode) ) Then
		
		Logging.Info( EVENT_MESSAGE, Message, Webhook, NewResponse );

	Else
		
		Logging.Error( EVENT_MESSAGE, Message, Webhook, NewResponse );
		
	EndIf;
	
EndProcedure

Function CreateSendFileResultMessage( Val Response, Val FileName, Val URL )
	
	Var DeliveryMessage;
	Var ResponseBody;
	
	DELIVERY_MESSAGE = NStr( "ru = 'URL сервиса доставки: %1; файл: %2';en = 'delivery service URL: %1; file: %2'" );
	ERROR_STATUS_CODE_MESSAGE = NStr( "ru = '[ Ошибка ]: Код ответа: ';en = '[ Error ]: Response Code: '" );
	SERVER_RESPONSE_MESSAGE = NStr( "ru = '; текст ответа:';en = '; response message:'" ); 
	
	DeliveryMessage = StrTemplate( DELIVERY_MESSAGE, URL, FileName );
	
	If ( HTTPStatusCodesClientServerCached.isOk(Response.StatusCode) ) Then
		
		ResponseBody = HTTPConnector.AsText(Response, TextEncoding.UTF8);
		
	Else
		
		ResponseBody = ERROR_STATUS_CODE_MESSAGE + Response.StatusCode;
		
	EndIf;
	
	Return DeliveryMessage + SERVER_RESPONSE_MESSAGE + Chars.LF + ResponseBody;
	
EndFunction

#EndRegion
