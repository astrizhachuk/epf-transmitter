#Region Public

// GetConnectionParams returns connection parameters to the endpoint service.
// 
// Returns:
// Structure - description:
// * User - String - user name;
// * Password - String - user password;
// * Timeout - Number - connection timeout, sec. (0 - timeout is not set);
//
Function GetConnectionParams() Export
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "User", ServicesSettings.EndpointUserName() );
	Result.Insert( "Password", ServicesSettings.EndpointUserPassword() );
	Result.Insert( "Timeout", ServicesSettings.DeliveryFileTimeout() );
	
	Return Result;
	
EndFunction

// SetURL sets the upload file URL for the endpoint connection parameters. 
// 
// Parameters:
// 	Params - Structure - parameters (see GetConnectionParams);
// 	URL - String - endpoint service URL;
//
Procedure SetURL( Params, Val URL ) Export
	
	Params.Insert( "URL", URL );
	
EndProcedure

// SendFile sends a file to the endpoint infobase. The endpoint service must implement the API
// see https://app.swaggerhub.com/apis-docs/astrizhachuk/epf-endpoint
// 
// Parameters:
//	Endpoint - Structure - upload file options:
// * URL - String - endpoint service URL;
// * User - String - user name;
// * Password - String - user password;
// * Timeout - Number - connection timeout, sec. (0 - timeout is not set);
//	FileName - String - the filename used to replace files in the endpoint infobase (UTF-8);
//	Data - BinaryData - file body;
//
// Returns:
// 	String - the result of the operation with a response from the endpoint;
//
Function SendFile( Val Endpoint, Val FileName, Val Data ) Export

	Var Headers;
	Var RequestParams;
	Var Response;
	Var Message;
	
	Assert( Endpoint );
	
	Headers = New Map();
	Headers.Insert( "name", EncodeString(FileName, StringEncodingMethod.URLEncoding) );

	RequestParams = New Structure();
	RequestParams.Insert( "Authentication", GetAuthentication(Endpoint) );
	RequestParams.Insert( "Headers", Headers );
	RequestParams.Insert( "Timeout", Endpoint.Timeout );
	
	Response = HTTPConnector.Post( Endpoint.URL, Data, RequestParams );
	
	Message = CreateResponseMessage( Endpoint.URL, FileName, Response );

	If ( NOT StatusCodes().isOk(Response.StatusCode) ) Then

		Raise Message;
		
	EndIf;
		
	Return Message;
		
EndFunction

// BackgroundSendFiles returns the result of running a background job to upload files to endpoint infobases.
// 
// Parameters:
// 	Files - Structure - file upload description:
// * CommitSHA - String - сommit SHA;
// * FileName - String - file name; 
// * BinaryData - BinaryData - file data;
// * Routes - Undefined, Array of String - list of endpoint service URLs;
// 	
// Returns:
// 	Array of Structure - file sending result:
// 	* BackgroundJob - BackgroundJob - the background job;
// 	* ErrorInfo - ErrorInfo - an error occurred when starting a background job;
//
Function BackgroundSendFiles( Val Files ) Export

	Var JobKey;
	Var Endpoint;
	Var BackgroundJob;
	Var BackgroundJobParams;
	Var ErrorInfo;
	Var Result;
	
	Endpoint = Endpoints.GetConnectionParams();
	
	Result = New Array();
	
	For Each File In Files Do
		
		For Each URL In File.Routes Do
		
			BackgroundJob = Undefined;
			ErrorInfo = Undefined;
			
			Try
				Endpoints.SetURL( Endpoint, URL );
				
				BackgroundJobParams = New Array();
				BackgroundJobParams.Add( Endpoint );
				BackgroundJobParams.Add( File.FileName );
				BackgroundJobParams.Add( File.BinaryData );
				
				JobKey = File.CommitSHA + "|" + URL + "|" + File.FileName;
				
				BackgroundJob = BackgroundJobs.Execute( "Endpoints.SendFile", BackgroundJobParams, JobKey );
	
			Except
				
				ErrorInfo = ErrorInfo();
				
			EndTry;
			
			Result.Add( NewFileSendingResult(BackgroundJob, ErrorInfo) );
		
		EndDo;
		
	EndDo;
	
	Return Result;
	
EndFunction

#EndRegion

#Region Private

Function GetAuthentication( Val ConnectionParams )
	
	Var Result;

	Result = New Structure();
	Result.Insert( "User", ConnectionParams.User );
	Result.Insert( "Password", ConnectionParams.Password );
	
	Return Result;
	
EndFunction

Procedure Assert( Val Endpoint )
	
	If ( TypeOf(Endpoint) <> Type("Structure") ) Then
		
		Raise Logs.Messages().ENDPOINT_OPTIONS_MISSING;
		
	EndIf;

	If ( NOT (Endpoint.Property("URL") AND Endpoint.Property("User") AND Endpoint.Property("Password")) ) Then
	
		Raise Logs.Messages().ENDPOINT_OPTIONS_MISSING;
		
	EndIf;
	
EndProcedure

Function StatusCodes()
	
	Return HTTPStatusCodesClientServerCached;
	
EndFunction

Function CreateResponseMessage( Val URL, Val FileName, Val Response )
	
	Var ResponseBody;
	Var Message;
	
	Message = NStr( "ru = 'URL: %1; имя файла: %2
					|Код ответа: %3
					|%4';
					|en = 'URL: %1; filename: %2
					|Status code: %3
					|%4'" );

	ResponseBody = HTTPConnector.AsText(Response, TextEncoding.UTF8);
	
	Return StrTemplate( Message, URL, FileName, Response.StatusCode, ResponseBody );
	
EndFunction

Function NewFileSendingResult( Val BackgroundJob, Val ErrorInfo )
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "BackgroundJob", BackgroundJob );
	Result.Insert( "ErrorInfo", ErrorInfo );
	
	Return Result;
	
EndFunction

#EndRegion
