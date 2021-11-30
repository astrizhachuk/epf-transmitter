#Region Public

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

#EndRegion
