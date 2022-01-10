#Region Public

// Settings returns an undefined collection of the settings.
// 
// Returns:
// 	Structure - description:
// * HandleRequests - Boolean - True - to handle external storage requests, otherwise - False;
// * RoutingFileName - String - the name of the routing settings file;
// * ExternalStorageToken - String - a token for connecting to external storage;
// * ExternalStorageTimeout - Number - the connection timeout to external storage;
// * EndpointUserName - String - endpoint infobase user name;
// * EndpointUserPassword - String - endpoint infobase user password;
// * EndpointTimeout - Number - endpoint infobase connection timeout;
// 
Function Settings() Export
	
	Var Result;

	Result = New Structure();
	Result.Insert( "HandleRequests" );
	Result.Insert( "RoutingFileName" );
	Result.Insert( "ExternalStorageToken" );
	Result.Insert( "ExternalStorageTimeout" );
	Result.Insert( "EndpointUserName" );
	Result.Insert( "EndpointUserPassword" );
	Result.Insert( "EndpointTimeout" );
	
	Return Result;
	
EndFunction

#EndRegion
