#Region Public

// CurrentSettings returns all the current settings.
// 
// Returns:
// FixedStructure - (see ServicesSettingsClientServer.Settings);
//
Function CurrentSettings() Export
	
	Var Result;

	Result = ServicesSettingsClientServer.Settings();
	Result.HandleGitLabRequests = IsHandleGitLabRequests();
	Result.RoutingFileName = RoutingFileName();
	Result.GitLabToken = GetGitLabToken();
	Result.GitLabTimeout = GetGitLabTimeout();
	Result.EndpointUserName = EndpointUserName();
	Result.EndpointUserPassword = EndpointUserPassword();
	Result.EndpointTimeout = EndpointTimeout();
	
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
	Constants.RoutingFileName.Set( Settings.RoutingFileName );
	Constants.EndpointUserName.Set( Settings.EndpointUserName );
	Constants.EndpointUserPassword.Set( Settings.EndpointUserPassword );
	Constants.EndpointTimeout.Set( Settings.EndpointTimeout );
	
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

// EndpointUserName returns the user name to connect to the endpoint infobase.
// 
// Returns:
// 	String - user name (max. 256 chars);
//
Function EndpointUserName() Export
	
	Return Constants.EndpointUserName.Get();
	
EndFunction

// EndpointUserPassword returns the user password to connect to the endpoint infobase.
// 
// Returns:
// 	String - user password (max. 256 chars);
//
Function EndpointUserPassword() Export
	
	Return Constants.EndpointUserPassword.Get();
	
EndFunction

// EndpointTimeout returns the connection timeout to the endpoint infobase.
//
// Returns:
// 	Number - the connection timeout, sec. (0 - timeout is not set);
//
Function EndpointTimeout() Export
	
	Return Constants.EndpointTimeout.Get();
	
EndFunction

// RoutingFileName returns the name of the routing settings file.
//
// Returns:
// 	String - file name (max. 50 chars);
//
Function RoutingFileName() Export
	
	Return Constants.RoutingFileName.Get();
	
EndFunction

#EndRegion
