#Region Public

// GetConnectionParams returns connection parameters to the endpoint service.
// 
// Returns:
// Structure - description:
// * URL - String - service URL (if empty, then service URL evaluated as BaseURL + RootURL + Operation);
// * BaseURL - String - URL to infobase, like http://host/base;
// * RootURL - String - path to epf group, like /hs/epf,
//						see https://app.swaggerhub.com/apis-docs/astrizhachuk/epf-endpoint;
// * Operation - String - service status operation;
// * UseGlobalSettings - Boolean - forced use of global settings;
// * User - String - user name;
// * Password - String - user password;
// * Timeout - Number - connection timeout, sec. (0 - timeout is not set);
//
Function GetConnectionParams() Export

	Result = New Structure();
	Result.Insert( "URL", "" );
	Result.Insert( "BaseURL", "" );
	Result.Insert( "RootURL", "" );
	Result.Insert( "Operation", "/status" );
	Result.Insert( "UseGlobalSettings", False );
	Result.Insert( "User", "" );
	Result.Insert( "Password", "" );
	Result.Insert( "Timeout", Undefined );
	
	Return Result;
	
EndFunction	
	
#EndRegion