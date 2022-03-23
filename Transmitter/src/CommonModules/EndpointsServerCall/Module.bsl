#Region Public

// GetServiceStatus returns a structured response from the endpoint status check service.
// 
// Parameters:
// 	Connector - Structure - connector parameters to the endpoint service:
// * URL - String - service URL (if empty, then service URL evaluated as BaseURL + RootURL + Operation);
// * BaseURL - String - URL to infobase, like http://host/base;
// * RootURL - String - path to epf group, like /hs/epf,
//						see https://app.swaggerhub.com/apis-docs/astrizhachuk/epf-endpoint;
// * Operation - String - service status operation;
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
Function GetServiceStatus( Val Connector ) Export
	
	Var HTTPConnectorParams;
	Var Response;
	Var Result;
	
	ERROR_CODE = -1;
	
	Result = New Structure( "StatusCode, ResponseBody" );
	
	HTTPConnectorParams = New Structure();
	AppendAuthentication( HTTPConnectorParams, Connector );
	AppendTimeout( HTTPConnectorParams, Connector );

	Try

		Response = HTTPConnector.Get( GetServiceURL(Connector), Undefined, HTTPConnectorParams );
	
		Result.StatusCode = Response.StatusCode;
		Result.ResponseBody = HTTPConnector.AsText( Response );

	Except
		
		Result.StatusCode = ERROR_CODE;
		Result.ResponseBody = ErrorProcessing.DetailErrorDescription( ErrorInfo() );

	EndTry;
	
	Return Result;
	
EndFunction

#EndRegion

#Region Private

Function GetServiceURL( Val Connection )
	
	If ( NOT IsBlankString(Connection.URL) ) Then
		
		Return Connection.URL;
		
	EndIf;
	
	Return Connection.BaseURL + Connection.RootURL + Connection.Operation;
	
EndFunction

Procedure AppendAuthentication( Result, Val Connector )
	
	Var Authentication;
	
	If ( StrFind(Connector.URL, "@") OR StrFind(Connector.BaseURL, "@") ) Then
		
		Return;
		
	EndIf;
		
	Authentication = New Structure( "User, Password" );
	
	FillPropertyValues( Authentication, Connector );
	
	If ( Connector.UseGlobalSettings ) Then
		
		Authentication.User = ServicesSettings.EndpointUserName();
		Authentication.Password = ServicesSettings.EndpointUserPassword();
		
	EndIf;
	
	Result.Insert( "Authentication", Authentication );
	
EndProcedure

Procedure AppendTimeout( Result, Val Connector )
	
	Var Timeout;
	
	If ( Connector.UseGlobalSettings ) Then
		
		Timeout = ServicesSettings.EndpointTimeout();
		
	Else
		
		Timeout = Connector.Timeout;
		
	EndIf;
	
	Result.Insert( "Timeout", Timeout );
	
EndProcedure

#EndRegion
