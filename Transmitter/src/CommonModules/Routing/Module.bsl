#Region Public

// TODO подумать о возвращении отправки по доступным маршрутам, если файл не имеет описания в json

// GetFilesByRoutes returns downloaded files with the URLs of the delivery endpoint service.
// 
// Parameters:
//	ExternalRequest - DataProcessorObject.ExternalRequest - external request instance;
// 	Files - ValueTable - downloaded files metadata:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the file for the remote repository (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - file operation date;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - Undefined, ErrorInfo - file download error;
//
// Returns:
// 	Array of Structure:
// * CommitSHA - String - сommit SHA;
// * FileName - String - file name; 
// * BinaryData - BinaryData - file data;
// * Routes - Array of String - delivery end-point service URLs;
//
Function GetFilesByRoutes( Val ExternalRequest, Val Files ) Export
	
	Var RoutesByCommits;
	Var FileToSend;
	Var Routes;
	Var Result;
	
	RoutesByCommits = FindRoutesByCommits( ExternalRequest );
	
	Result = New Array();
	
	For Each RemoteFile In Files Do
		
		If ( IsSettingFile(RemoteFile) ) Then
			
			Continue;
			
		EndIf;
		
		FileToSend = FileToSend();
		
		FillPropertyValues( FileToSend, RemoteFile );
		
		Routes = RoutesByCommits.Get( RemoteFile.CommitSHA );
	
		If ( Routes <> Undefined ) Then
			
			FileToSend.Routes = Routes.Get( RemoteFile.FilePath );

		EndIf;
		
		Result.Add( FileToSend );
		
	EndDo;
	
	Return Result;
	
EndFunction

// FillRoutesFromBinaryData fills routes in JSON format extracted from file metadata.
// 
// Parameters:
// 	ExternalRequest - DataProcessorObject.ExternalRequest - external request instance;
// 	Files - ValueTable - downloaded files metadata:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the file for the remote repository (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - file operation date;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - Undefined, ErrorInfo - file download error;
//
Procedure FillRoutesFromBinaryData( ExternalRequest, Val Files ) Export
	
	Var FileName;
	Var FileMetadata;
	
	FileName = ServicesSettings.GetRoutingFileName();
	
	For Each Commit In ExternalRequest.GetCommits() Do
		
		FileMetadata = Files.FindRows( FilterRouteFile(Commit.Id, FileName) );
		
		If ( NOT ValueIsFilled(FileMetadata) ) Then
			
			Continue;
			
		EndIf;
		
		ExternalRequest.AddRoute( Commit.Id, GetStringFromBinaryData(FileMetadata[0].BinaryData) );
		
	EndDo;	
	
EndProcedure

// AddCustomRoute adds custom route in JSON format with format verify.
//
// Parameters:
// 	RequestHandler - CatalogRef.ExternalRequestHandlers - ref to external request handler;
// 	CheckoutSHA - String - event identifier;
// 	Id - String - сommit SHA;
// 	JSON - String - routes in JSON format;
//
Procedure AddCustomRoute( Val RequestHandler, Val CheckoutSHA, Val Id, Val JSON ) Export
	
	Var ExternalRequest;
	
	CommonUseServerCall.JsonToObject( JSON );
	
	ExternalRequest = ExternalRequests.GetObjectFromIB( RequestHandler, CheckoutSHA );
	
	If ( ExternalRequest = Undefined ) Then
		
		Return;
		
	EndIf;

	ExternalRequest.AddRoute( Id, JSON, True );
	
	ExternalRequests.SaveObject( RequestHandler, CheckoutSHA, ExternalRequest );

EndProcedure

// RemoveCustomRoute removes the custom route by commit and returns the default route from the external request.
// 
// Parameters:
// 	RequestHandler - CatalogRef.ExternalRequestHandlers - ref to external request handler;
// 	CheckoutSHA - String - event identifier;
// 	Id - String - сommit SHA;
// 	
// Returns:
// 	String - default routes in JSON format;
//
Function RemoveCustomRoute( Val RequestHandler, Val CheckoutSHA, Val Id ) Export
	
	Var Result;
	
	ExternalRequest = ExternalRequests.GetObjectFromIB( RequestHandler, CheckoutSHA );
	
	Result = ExternalRequest.GetRouteJSON( Id, False );
	
	ExternalRequest.RemoveRoute( Id, True );

	ExternalRequests.SaveObject( RequestHandler, CheckoutSHA, ExternalRequest );	
	
	Return Result;
	
EndFunction

#EndRegion

#Region Private

// FileToSend returns a description of the file to delivery it to the endpoint infobases.
//
// Returns:
// 	Structure - description:
// * CommitSHA - String - сommit SHA; 
// * FileName - String - file name; 
// * BinaryData - BinaryData - file data;
// * Routes - Array of String - delivery end-point service URLs;
//
Function FileToSend()
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "CommitSHA", "" );
	Result.Insert( "FileName", "" );
	Result.Insert( "BinaryData", Undefined );
	Result.Insert( "Routes", Undefined );
	
	Return Result;
	
EndFunction

// FindRoutesByCommits returns file delivery routes by commits. Custom routes have a higher priority than "default".
// 
// Parameters:
// 	ExternalRequest - DataProcessorObject.ExternalRequest - external request instance;
// 	
// Returns:
// 	Map - file routes by commits:
// 	* Key - String - commit SHA;
// 	* Value - Map - routes;
// 	** Key - String - relative path to the file in remote repository (with the filename);
// 	** Value - Array of String - list of file delivery endpoint URLs;
//
Function FindRoutesByCommits( Val ExternalRequest )

	Var Result;
	
	Result = New Map();
	
	For Each ActualRoute In ExternalRequest.GetActualRoutes() Do
		
		Result.Insert( ActualRoute.Key, Routes( ActualRoute.Value.Data ) );

	EndDo;
	
	Return Result;
	
EndFunction

Function IsSettingFile( Val File )
	
	Return IsBlankString( File.Action );
	
EndFunction

// EnabledServices returns a list of enabled file delivery end-point services from the routing settings.
// 
// Parameters:
// 	Settings - Map - deserialized routing settings;
// 	  
// Returns:
// 	Map - enabled file delivery services:
//	* Key - Sting - delivery service name;
//	* Value - Sting - delivery service URL;
//
Function EnabledServices( Val Settings )

	Var Services;
	Var ServiceName;
	Var IsServiceEnabled;
	Var URL;
	Var Result;
	
	Result = New Map();
	
	Services = Settings.Get( "ws" );
	
	If ( Services = Undefined ) Then
		
		Return Result;
		
	EndIf;
	
	For Each Service In Services Do
		
		ServiceName = Service.Get( "name" );
		
		If ( ServiceName = Undefined ) Then
			
			Continue;
			
		EndIf;
		
		IsServiceEnabled = Service.Get( "enabled" );
		
		If ( IsServiceEnabled = Undefined OR NOT IsServiceEnabled ) Then
			
			Continue;
			
		EndIf;
			
		URL = Service.Get( "url" );
		
		If ( URL = Undefined ) Then
			
			Continue;
			
		EndIf;
		
		Result.Insert( ServiceName, URL );

	EndDo;
	
	Return Result;
	
EndFunction

Function GetURLs( Val Services )
	
	Var Result;
	
	Result = New Array();
	
	For Each Service In Services Do
		
		Result.Add( Service.Value );
	
	EndDo;	
	
	Return Result;
	
EndFunction

Function ExcludedServices( Val Services, Val Excluded )
	
	Var Result;
	
	Result = New Array();
	
	For Each Service In Services Do
		
		If ( Excluded = Undefined OR Excluded.Find(Service.Key) = Undefined ) Then
	
			Result.Add( Service );
			
		EndIf;
		
	EndDo;
	
	Return Result;
	
EndFunction

// Routes returns routes formed according to the settings in the routing file.
// 
// Parameters:
//	Settings - Map - deserialized routing settings;
// 	
// Returns:
// 	Map - routes:
// 	*Key - String - relative path to the repository file (with the filename);
// 	*Value - Array of String - file delivery end-point services URLs;
//
Function Routes( Val Settings )
	
	Var EnabledServices;
	Var ExcludedServices;
	Var Files;
	Var FilePath;
	Var URLs;
	Var Result;
	
	Result = New Map();
	
	EnabledServices = EnabledServices( Settings );
	
	Files = Settings.Get( "epf" );
	
	If ( Files = Undefined ) Then
		
		Return Result;
		
	EndIf;
	
	For Each File In Files Do
		
		FilePath = File.Get( "name" );
		
		If ( FilePath = Undefined ) Then
			
			Continue;
			
		EndIf;
		
		ExcludedServices = ExcludedServices( EnabledServices, File.Get( "exclude" ) );

		URLs = GetURLs( ExcludedServices );

		Result.Insert( FilePath, URLs );
		
	EndDo;
	
	Return Result;
	
EndFunction

Function FilterRouteFile( Val Id, Val FilePath )
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "CommitSHA", Id );
	Result.Insert( "FilePath", FilePath );
	Result.Insert( "Action", "" );
	Result.Insert( "ErrorInfo", Undefined );
		
	Return Result;
	
EndFunction

#EndRegion