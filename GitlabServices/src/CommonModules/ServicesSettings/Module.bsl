#Region Public

// CurrentSettings returns a fixed structure with all the current settings.
// 
// Parameters:
// Returns:
// FixedStructure - description:
// * IsHandleRequests - Boolean - (see Constants.HandleRequests);
// * RoutingFileName - String - (see Constants.RoutingFileName);
// * TokenGitLab - String - (see Constants.TokenGitLab);
// * TimeoutGitLab - Number - (see Constants.TimeoutGitLab);
// * TokenReceiver - String - (see Constants.TokenReceiver);
// * TimeoutDeliveryFile - Number - (see Constants.TimeoutDeliveryFile);
//
Function CurrentSettings() Export
	
	Var Result;

	Result = New Structure();
	Result.Insert( "IsHandleRequests", IsHandleRequests() );
	Result.Insert( "RoutingFileName", RoutingFileName() );
	Result.Insert( "TokenGitLab", TokenGitLab() );
	Result.Insert( "TimeoutGitLab", TimeoutGitLab() );
	Result.Insert( "TokenReceiver", TokenReceiver() );
	Result.Insert( "TimeoutDeliveryFile", TimeoutDeliveryFile() );
	
	Result = New FixedStructure( Result );

	Return Result;
	
EndFunction

// RoutingFileName the constant value with the name of the Routing settings file located in the project root.
//
// Parameters:
// Returns:
// 	String - file name (max. 50 chars);
//
Function RoutingFileName() Export
	
	Return Constants.RoutingFileName.Get();
	
EndFunction

// TokenGitLab returns the constant value from the private token of a GitLab user
// with access to the GitLab API.
// 
// Parameters:
// Returns:
// 	String - value of PRIVATE-TOKEN (max. 50 chars);
// 
Function TokenGitLab() Export
	
	Return Constants.TokenGitLab.Get();
	
EndFunction

// TimeoutGitLab returns the constant value with the connection timeout to the GitLab server.
//
// Parameters:
// Returns:
// 	Number - the connection timeout, sec (0 - timeout is not set);
//
Function TimeoutGitLab() Export
	
	Return Constants.TimeoutGitLab.Get();

EndFunction

// TimeoutDeliveryFile returns the constant value with the connection timeout to the receiver.
//
// Parameters:
// Returns:
// 	Number - the connection timeout, sec (0 - timeout is not set);
//
Function TimeoutDeliveryFile() Export
	
	Return Constants.TimeoutDeliveryFile.Get();
	
EndFunction

// TokenReceiver returns the constant value used to connect to file delivery end-point services.
// 
// Parameters:
// Returns:
// 	String - value of token (max. 20 chars);
//
Function TokenReceiver() Export
	
	Return Constants.TokenReceiver.Get();
	
EndFunction

#EndRegion

#Region Private

// IsHandleRequests returns the value of the setting of processing requests from the GitLab repository.
//
// Parameters:
// Returns:
// 	Boolean - True - to process requests, otherwise - False;
//
Function IsHandleRequests()
	
	Return Constants.HandleRequests.Get();

EndFunction

#EndRegion