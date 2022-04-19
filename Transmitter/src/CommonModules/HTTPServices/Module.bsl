#Region Public

Function StatusCodes() Export
	
	Возврат HTTPStatusCodesClientServerCached;
	
EndFunction

Function FindStatusCodeById( Val Id ) Export
	
	Return StatusCodes().FindCodeById( Id );
	
EndFunction

// GetHandleRequestsStatus returns the current handling requests status as a message object.
// Throws an exception on invalid request source.
// 
// Parameters:
// 	RequestSource - EnumRef.RequestSource - request source type;
// 	
// Returns:
// 	Structure - message object:
// * message - String - message text;
//
Function GetHandleRequestsStatus( Val RequestSource ) Export
	
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

#EndRegion
