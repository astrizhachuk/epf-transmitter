#Region Public

// StatusCodes returns HTTPStatusCodesClientServerCached manager.
// 
// Returns:
// 	CommonModule.HTTPStatusCodesClientServerCached - status codes manager;
//
Function StatusCodes() Export
	
	Return HTTPStatusCodesClientServerCached;
	
EndFunction

// GetHandleRequestStatus returns the current handle request status as an HTTP response
// with body in JSON format. Throws an exception on invalid request source.
// 
// Parameters:
// 	RequestSource - EnumRef.RequestSource - request source type;
// 	
// Returns:
// 	HTTPServiceResponse - HTTP response with handle request status;
//
Function GetHandleRequestStatus( Val RequestSource ) Export
	
	Var Response;
	
	Response = New HTTPServiceResponse( StatusCodes().FindCodeById("OK") );
	HTTPServices.SetBodyAsJSON( Response, GetHandleRequestStatusMessage(RequestSource) );
	
	Return Response;
	
EndFunction

// CreateMessage creates a message object.
// 
// Parameters:
// 	Message - String - text message;
// 	
// Returns:
// 	Structure - message object:
// 	* message - String - text message;
//
Function CreateMessage( Val Message ) Export
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "message", Message );
	
	Return Result;
	
EndFunction

// SetBodyAsJSON sets the HTTP service response body from data serialized to a JSON format. 
// 
// Parameters:
// 	Response - HTTPServiceResponse - HTTP-service response;
// 	Data - Structure - arbitrary structure;
//
Procedure SetBodyAsJSON( Response, Val Data ) Export

	Response.Headers.Insert( "Content-Type", "application/json" );
	Response.SetBodyFromString( GetJSON(Data) );

EndProcedure

#EndRegion

#Region Private

// GetJSON serializes data in JSON format.
// 
// Parameters:
// 	Data - Structure - arbitrary structure;
// 	
// Returns:
// 	String - JSON;
//
Function GetJSON( Val Data )
	
	Var WriterSettings;
	Var JSONWrite;
	Var Result;
	
	WriterSettings = New JSONWriterSettings( JSONLineBreak.None );
	JSONWrite = New JSONWriter();
	JSONWrite.SetString( WriterSettings );
	WriteJSON( JSONWrite, Data );
	
	Result = JSONWrite.Close();

	Return Result;
	
EndFunction

Function HandleRequestEnabled( Val RequestSource )
	
	If ( RequestSource = Enums.RequestSource.GitLab ) Then
		
		Return ServicesSettings.IsHandleGitLabRequests();
		
	ElsIf ( RequestSource = Enums.RequestSource.Custom ) Then
		
		Return ServicesSettings.IsHandleCustomRequests();
		
	Else
		
		Raise NStr( "ru = 'неверный тип запроса';en = 'invalid request type'" );
		
	EndIf;
	
EndFunction

// GetHandleRequestStatusMessage returns the current handle request status as a message object.
// Throws an exception on invalid request source.
// 
// Parameters:
// 	RequestSource - EnumRef.RequestSource - request source type;
// 	
// Returns:
// 	Structure - message object:
// * message - String - message text;
//
Function GetHandleRequestStatusMessage( Val RequestSource )
	
	Var Result;
	
	MESSAGE_ENABLED = NStr( "ru = 'обработка запросов включена';en = 'request handler enabled'" );
	MESSAGE_DISABLED = NStr( "ru = 'обработка запросов отключена';en = 'request handler disabled'" );
	
	If ( HandleRequestEnabled(RequestSource) ) Then
		
		Result = HTTPServices.CreateMessage( MESSAGE_ENABLED );
		
	Else
		
		Result = HTTPServices.CreateMessage( MESSAGE_DISABLED );
		
	EndIf;
	
	Return Result;
	
EndFunction

#EndRegion
