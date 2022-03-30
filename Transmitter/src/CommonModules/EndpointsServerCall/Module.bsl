#Region Public

// GetStatusService returns a structured response from the endpoint status check service.
// 
// Parameters:
// 	Connector - Structure - connector parameters to the endpoint service:
// * URL - String - service URL (if empty, then service URL evaluated as BaseURL + RootURL + StatusOperation);
// * BaseURL - String - URL to infobase, like http://host/base;
// * RootURL - String - path to epf group, like /hs/epf,
//						see https://app.swaggerhub.com/apis-docs/astrizhachuk/epf-endpoint;
// * StatusOperation - String - service status operation;
// * UploadFileOperation - String - upload file operation;
// * UseGlobalSettings - Boolean - forced use of global settings;
// * User - String - user name;
// * Password - String - user password;
// * Timeout - Number - Connector timeout, sec. (0 - timeout is not set);
// 	
// Returns:
// 	Structure - response:
// * StatusCode - Number - HTTP status code (if error = -1);
// * ResponseBody - String - response body;
//
Function GetStatusService( Val Connector ) Export
	
	Return Endpoints.GetStatusService( Connector );
	
EndFunction

#EndRegion
