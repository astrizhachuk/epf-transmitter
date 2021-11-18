#Region Public

// CurrentSettings returns all the current settings.
// 
// Returns:
// FixedStructure - (see ServicesSettingsClientCerver.Settings);
//
Function CurrentSettings() Export
	
	Var Result;

	Result = ServicesSettingsClientCerver.Settings();
	Result.IsHandleRequests = IsHandleRequests();
	Result.RoutingFileName = RoutingFileName();
	Result.ExternalStorageToken = ExternalStorageToken();
	Result.ExternalStorageTimeout = ExternalStorageTimeout();
	Result.ReceiverUserName = ReceiverUserName();
	Result.ReceiverUserPassword = ReceiverUserPassword();
	Result.DeliveryFileTimeout = DeliveryFileTimeout();
	
	Result = New FixedStructure( Result );

	Return Result;
	
EndFunction

// SetCurrentSettings sets the values of the current settings.
//
// Parameters:
// 	Settings - Structure - (see ServicesSettingsClientCerver.Settings);
//
Procedure SetCurrentSettings( Val Settings ) Export

	Constants.IsHandleRequests.Set( Settings.IsHandleRequests );
	Constants.ExternalStorageToken.Set( Settings.ExternalStorageToken );
	Constants.RoutingFileName.Set( Settings.RoutingFileName );
	Constants.ReceiverUserName.Set( Settings.ReceiverUserName );
	Constants.ReceiverUserPassword.Set( Settings.ReceiverUserPassword );
	Constants.ExternalStorageTimeout.Set( Settings.ExternalStorageTimeout );
	Constants.DeliveryFileTimeout.Set( Settings.DeliveryFileTimeout );
	
EndProcedure

// IsHandleRequests returns true if external storage requests should be handled, otherwise false.
// 
// Returns:
// 	Boolean - True - to handle requests, otherwise - False;
//
Function IsHandleRequests() Export

	Return Constants.IsHandleRequests.Get();

EndFunction

// ReceiverUserName returns the user name to connect to the endpoint infobase.
// 
// Returns:
// 	String - user name (max. 256 chars);
//
Function ReceiverUserName() Export
	
	Return Constants.ReceiverUserName.Get();
	
EndFunction

// ReceiverUserPassword returns the user password to connect to the endpoint infobase.
// 
// Returns:
// 	String - user password (max. 256 chars);
//
Function ReceiverUserPassword() Export
	
	Return Constants.ReceiverUserPassword.Get();
	
EndFunction

// DeliveryFileTimeout returns the connection timeout to the endpoint infobase.
//
// Returns:
// 	Number - the connection timeout, sec. (0 - timeout is not set);
//
Function DeliveryFileTimeout() Export
	
	Return Constants.DeliveryFileTimeout.Get();
	
EndFunction

#EndRegion

#Region Private

// RoutingFileName returns the name of the routing settings file.
//
// Returns:
// 	String - file name (max. 50 chars);
//
Function RoutingFileName()
	
	Return Constants.RoutingFileName.Get();
	
EndFunction

// ExternalStorageToken returns a token to connect to external storage, like GitLab API.
//
// Returns:
// 	String - a token (max. 50 chars);
// 
Function ExternalStorageToken()
	
	Return Constants.ExternalStorageToken.Get();
	
EndFunction

// ExternalStorageTimeout returns the connection timeout to external storage, like GitLab.
//
// Returns:
// 	Number - the connection timeout, sec. (0 - timeout is not set);
//
Function ExternalStorageTimeout()
	
	Return Constants.ExternalStorageTimeout.Get();

EndFunction

#EndRegion