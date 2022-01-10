#Region Public

// CurrentSettings returns all the current settings.
// 
// Returns:
// FixedStructure - (see ServicesSettingsClientServer.Settings);
//
Function CurrentSettings() Export
	
	Var Result;

	Result = ServicesSettingsClientServer.Settings();
	Result.HandleRequests = HandleRequests();
	Result.RoutingFileName = RoutingFileName();
	Result.ExternalStorageToken = ExternalStorageToken();
	Result.ExternalStorageTimeout = ExternalStorageTimeout();
	Result.EndpointUserName = EndpointUserName();
	Result.EndpointUserPassword = EndpointUserPassword();
	Result.DeliveryFileTimeout = DeliveryFileTimeout();
	
	Result = New FixedStructure( Result );

	Return Result;
	
EndFunction

// SetCurrentSettings sets the values of the current settings.
//
// Parameters:
// 	Settings - Structure - (see ServicesSettingsClientServer.Settings);
//
Procedure SetCurrentSettings( Val Settings ) Export

	Constants.HandleRequests.Set( Settings.HandleRequests );
	Constants.ExternalStorageToken.Set( Settings.ExternalStorageToken );
	Constants.RoutingFileName.Set( Settings.RoutingFileName );
	Constants.EndpointUserName.Set( Settings.EndpointUserName );
	Constants.EndpointUserPassword.Set( Settings.EndpointUserPassword );
	Constants.ExternalStorageTimeout.Set( Settings.ExternalStorageTimeout );
	Constants.DeliveryFileTimeout.Set( Settings.DeliveryFileTimeout );
	
EndProcedure

// HandleRequests returns true if external storage requests should be handled, otherwise false.
// 
// Returns:
// 	Boolean - True - to handle requests, otherwise - False;
//
Function HandleRequests() Export

	Return Constants.HandleRequests.Get();

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

// TODO rename to EndpointTimeout

// DeliveryFileTimeout returns the connection timeout to the endpoint infobase.
//
// Returns:
// 	Number - the connection timeout, sec. (0 - timeout is not set);
//
Function DeliveryFileTimeout() Export
	
	Return Constants.DeliveryFileTimeout.Get();
	
EndFunction

// ExternalStorageToken returns a token to connect to external storage (see GitLab API).
//
// Returns:
// 	String - a token (max. 50 chars);
// 
Function ExternalStorageToken() Export
	
	Return Constants.ExternalStorageToken.Get();
	
EndFunction

// ExternalStorageTimeout returns the connection timeout to external storage (GitLab etc.).
//
// Returns:
// 	Number - the connection timeout, sec. (0 - timeout is not set);
//
Function ExternalStorageTimeout() Export
	
	Return Constants.ExternalStorageTimeout.Get();

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
