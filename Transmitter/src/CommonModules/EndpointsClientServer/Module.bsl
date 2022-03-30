#Region Public

// Connector returns connection parameters to the endpoint service.
// 
// Returns:
// Structure - description:
// * URL - String - direct service operation URL;
// * BaseURL - String - URL to infobase, like http://host/base;
// * RootURL - String - path to upload file group, like /hs/epf,
//						see https://app.swaggerhub.com/apis-docs/astrizhachuk/epf-endpoint;
// * StatusOperation - String - service status operation;
// * UploadFileOperation - String - upload file operation;
// * UseGlobalSettings - Boolean - force use of global settings;
// * User - String - user name;
// * Password - String - user password;
// * Timeout - Number - connection timeout, sec. (0 - timeout is not set);
//
Function Connector() Export
	
	Var Result;
	
	DEFAULT_TIMEOUT = 5;

	Result = New Structure();
	Result.Insert( "URL", "" );
	Result.Insert( "BaseURL", "" );
	Result.Insert( "RootURL", "" );
	Result.Insert( "StatusOperation", "/status" );
	Result.Insert( "UploadFileOperation", "/uploadFile" );
	Result.Insert( "UseGlobalSettings", False );
	Result.Insert( "User", "" );
	Result.Insert( "Password", "" );
	Result.Insert( "Timeout", DEFAULT_TIMEOUT );
	
	Return Result;
	
EndFunction	
	
#EndRegion