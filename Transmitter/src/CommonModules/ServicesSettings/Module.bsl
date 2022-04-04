#Region Public

// GetCurrentSettings returns all the current settings.
// 
// Returns:
// FixedStructure - (see ServicesSettingsClientServer.Settings);
//
Function GetCurrentSettings() Export
	
	Var Result;

	Result = ServicesSettingsClientServer.Settings();
	Result.HandleGitLabRequests = IsHandleGitLabRequests();
	Result.RoutingFileName = GetRoutingFileName();
	Result.GitLabToken = GetGitLabToken();
	Result.GitLabTimeout = GetGitLabTimeout();
	Result.EndpointUserName = GetEndpointUserName();
	Result.EndpointUserPassword = GetEndpointUserPassword();
	Result.EndpointTimeout = GetEndpointTimeout();
	
	Result = New FixedStructure( Result );

	Return Result;
	
EndFunction

// SetCurrentSettings sets the values of the current settings.
//
// Parameters:
// 	Settings - Structure - (see ServicesSettingsClientServer.Settings);
//
Procedure SetCurrentSettings( Val Settings ) Export

	Constants.HandleGitLabRequests.Set( Settings.HandleGitLabRequests );
	Constants.GitLabToken.Set( Settings.GetGitLabToken );
	Constants.GitLabTimeout.Set( Settings.GetGitLabTimeout );
	Constants.RoutingFileName.Set( Settings.GetRoutingFileName );
	Constants.EndpointUserName.Set( Settings.GetEndpointUserName );
	Constants.EndpointUserPassword.Set( Settings.GetEndpointUserPassword );
	Constants.EndpointTimeout.Set( Settings.GetEndpointTimeout );
	
EndProcedure

// IsHandleGitLabRequests returns true if GitLab requests should be handled, otherwise false.
// 
// Returns:
// 	Boolean - True - to handle requests, otherwise - False;
//
Function IsHandleGitLabRequests() Export

	Return Constants.HandleGitLabRequests.Get();

EndFunction

// GetGitLabToken returns a token to connect to external storage on GitLab server.
//
// Returns:
// 	String - a token (max. 50 chars);
// 
Function GetGitLabToken() Export
	
	Return Constants.GitLabToken.Get();
	
EndFunction

// GetGitLabTimeout returns the connection timeout to external storage on GitLab server.
//
// Returns:
// 	Number - the connection timeout, sec. (0 - timeout is not set);
//
Function GetGitLabTimeout() Export
	
	Return Constants.GitLabTimeout.Get();

EndFunction

// GetEndpointUserName returns the user name to connect to the endpoint infobase.
// 
// Returns:
// 	String - user name (max. 256 chars);
//
Function GetEndpointUserName() Export
	
	Return Constants.EndpointUserName.Get();
	
EndFunction

// GetEndpointUserPassword returns the user password to connect to the endpoint infobase.
// 
// Returns:
// 	String - user password (max. 256 chars);
//
Function GetEndpointUserPassword() Export
	
	Return Constants.EndpointUserPassword.Get();
	
EndFunction

// GetEndpointTimeout returns the connection timeout to the endpoint infobase.
//
// Returns:
// 	Number - the connection timeout, sec. (0 - timeout is not set);
//
Function GetEndpointTimeout() Export
	
	Return Constants.EndpointTimeout.Get();
	
EndFunction

// GetRoutingFileName returns the name of the routing settings file.
//
// Returns:
// 	String - file name (max. 50 chars);
//
Function GetRoutingFileName() Export
	
	Return Constants.RoutingFileName.Get();
	
EndFunction

#EndRegion
