#Region Public

// Settings returns an undefined collection of the settings.
// 
// Returns:
// 	Structure - description:
// * IsHandleRequests - Boolean - True - to handle external storage requests, otherwise - False;
// * RoutingFileName - String - the name of the routing settings file;
// * ExternalStorageToken - String - a token for connecting to external storage;
// * ExternalStorageTimeout - Number - the connection timeout to external storage;
// * ReceiverUserName - String - endpoint infobase user name;
// * ReceiverUserPassword - String - endpoint infobase user password;
// * DeliveryFileTimeout - Number - endpoint infobase connection timeout;
// 
Function Settings() Export
	
	Var Result;

	Result = New Structure();
	Result.Insert( "IsHandleRequests" );
	Result.Insert( "RoutingFileName" );
	Result.Insert( "ExternalStorageToken" );
	Result.Insert( "ExternalStorageTimeout" );
	Result.Insert( "ReceiverUserName" );
	Result.Insert( "ReceiverUserPassword" );
	Result.Insert( "DeliveryFileTimeout" );
	
	Return Result;
	
EndFunction

#EndRegion
