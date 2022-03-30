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
	
	Var ConnectorParams;
	Var Response;
	Var Result;
	
	ERROR_CODE = -1;
	
	Result = New Structure( "StatusCode, ResponseBody" );
	
	ConnectorParams = GetConnectorParams( Connector );
	
	Try

		Response = HTTPConnector.Get( GetStatusServiceURL(Connector), Undefined, ConnectorParams );
	
		Result.StatusCode = Response.StatusCode;
		Result.ResponseBody = HTTPConnector.AsText( Response );

	Except
		
		Result.StatusCode = ERROR_CODE;
		Result.ResponseBody = ErrorProcessing.DetailErrorDescription( ErrorInfo() );

	EndTry;
	
	Return Result;
	
EndFunction

// SendFile sends a file to the endpoint infobase. The endpoint service must implement the API
// see https://app.swaggerhub.com/apis-docs/astrizhachuk/epf-endpoint
// 
// Parameters:
//	URL - String - upload file service URL or endpoint infobase URL (see Catalog.Endpoints.BaseURL);
//	FileName - String - the filename used to replace files in the endpoint infobase (UTF-8);
//	Data - BinaryData - file body;
//
// Returns:
// 	String - the result of the operation with a response from the endpoint;
//
Function SendFile( Val URL, Val FileName, Val Data ) Export

	Var ServiceURL;
	Var Connector;
	Var Response;
	Var Message;
	
	Connector = CreateConnector( URL );
	
	ServiceURL = GetUploadFileServiceURL( Connector );
	
	Response = HTTPConnector.Post( ServiceURL, Data, GetConnectorParams(Connector, FileName) );
	
	Message = CreateResponseMessage( ServiceURL, FileName, Response );

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
	Var BackgroundJob;
	Var BackgroundJobParams;
	Var ErrorInfo;
	Var Result;
	
	Result = New Array();
	
	For Each File In Files Do
		
		For Each URL In File.Routes Do
		
			BackgroundJob = Undefined;
			ErrorInfo = Undefined;
			
			Try
				
				BackgroundJobParams = New Array();
				BackgroundJobParams.Add( URL );
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

// FindByBaseURL looks for an endpoint by infobase URL.
// 
// Parameters:
// 	URL - String - endpoint infobase URL;
// 	
// Returns:
// 	CatalogRef.Endpoints - ref to external request handler;
//
Function FindByBaseURL( Val URL )

	Var Items;
	Var Message;
	
	Items = Catalogs.Endpoints.FindByBaseURL( URL );
	
	If ( NOT ValueIsFilled(Items) ) Then
		
		Return Catalogs.Endpoints.EmptyRef();
		
	EndIf;
	
	If ( Items.Count() > 1 ) Then
		
		Message = NStr( "ru = 'Дублирование URL не поддерживается: %1';en = 'Duplicate URL is not supported: %1'" );
		Message = StrTemplate( Message, URL );
		
		Raise Message;
		
	EndIf;
		
	Return Items[0];

EndFunction

Function CreateConnector( Val BaseURL )
	
	Var Endpoint;
	Var Result;

	Result = EndpointsClientServer.Connector();
	
	Endpoint = FindByBaseURL( BaseURL );

	If ( Endpoint.IsEmpty() ) Then

		Result.UseGlobalSettings = True;
		
		Result.URL = BaseURL;
		
	Else
		
		FillPropertyValues( Result, Endpoint.Ref.GetObject() );
		
	EndIf;
	
	Return Result;
	
EndFunction

Function GetConnectorParams( Val Connector, Val FileName = Undefined )

	Var Headers;
	Var Result;
		
	Result = New Structure();
	
	If ( NOT FileName = Undefined ) Then

		Headers = New Map();
		Headers.Insert( "name", EncodeString(FileName, StringEncodingMethod.URLEncoding) );
		Result.Insert( "Headers", Headers );
	
	EndIf;

	AppendAuthentication( Result, Connector );
	AppendTimeout( Result, Connector );
	
	Return Result;
	
EndFunction

Procedure AppendAuthentication( Params, Val Connector )
	
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
	
	Params.Insert( "Authentication", Authentication );
	
EndProcedure

Procedure AppendTimeout( Params, Val Connector )
	
	Var Timeout;
	
	If ( Connector.UseGlobalSettings ) Then
		
		Timeout = ServicesSettings.EndpointTimeout();
		
	Else
		
		Timeout = Connector.Timeout;
		
	EndIf;
	
	Params.Insert( "Timeout", Timeout );
	
EndProcedure

Function GetStatusServiceURL( Val Connector )
	
	If ( NOT IsBlankString(Connector.URL) ) Then
		
		Return Connector.URL;
		
	EndIf;
	
	Return Connector.BaseURL + Connector.RootURL + Connector.StatusOperation;
	
EndFunction

Function GetUploadFileServiceURL( Val Connector )
	
	If ( NOT IsBlankString(Connector.URL) ) Then
		
		Return Connector.URL;
		
	EndIf;
	
	Return Connector.BaseURL + Connector.RootURL + Connector.UploadFileOperation;
	
EndFunction

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
