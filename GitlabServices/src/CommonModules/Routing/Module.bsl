#Region Internal

// TODO подумать об упрощении
// TODO подумать о возвращении отправки по доступным маршрутам, если файл не имеет описания в json

// FilesByRoutes returns remote files with delivery end-point service URLs.
// 
// Parameters:
// 	Commits - Map - deserialized commits from the GitLab request;
// 	RemoteFiles - ValueTable - files from the GitLab server with its descriptions:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the file in remote repository (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
// Returns:
// 	Array of Structure:
// * FileName - String - file name; 
// * BinaryData - BinaryData - file data;
// * Routes - Array of String - delivery end-point service URLs;
// * ErrorInfo - String - description of an error while processing files;
//
Function FilesByRoutes( Val RemoteFiles, Val Commits ) Export
	
	Var RoutesByCommits;
	Var FileToSend;
	Var Routes;
	Var Result;
	
	ROUTING_SETTINGS_MISSING_MESSAGE = NStr( "ru = '%1: отсутствуют настройки маршрутизации.';
										|en = '%1: there are no routing settings.'" );
										
	DELIVERY_ROUTE_MISSING_MESSAGE = NStr( "ru = '%1: не задан маршрут доставки файла.';
										|en = '%1: file delivery route not specified.'" );
	
	RoutesByCommits = RoutesByCommits( Commits );
	
	Result = New Array();
	
	For Each RemoteFile In RemoteFiles Do
		
		If ( IsSettingFile(RemoteFile) ) Then
			
			Continue;
			
		EndIf;
		
		FileToSend = FileToSend();
		
		FillPropertyValues( FileToSend, RemoteFile );
		
		If ( NOT IsBlankString(FileToSend.ErrorInfo) ) Then
			
			Result.Add( FileToSend );
			
			Continue;
			
		EndIf;
			
		Routes = RoutesByCommits.Get( RemoteFile.CommitSHA );
	
		If ( Routes = Undefined ) Then
			
			FileToSend.ErrorInfo = StrTemplate( ROUTING_SETTINGS_MISSING_MESSAGE, RemoteFile.CommitSHA );

		Else

			FileToSend.Routes = Routes.Get( RemoteFile.FilePath );
			
			If ( FileToSend.Routes = Undefined ) Then

				FileToSend.ErrorInfo = StrTemplate( DELIVERY_ROUTE_MISSING_MESSAGE, RemoteFile.CommitSHA );
				
			EndIf;

		EndIf;
		
		Result.Add( FileToSend );
		
	EndDo;
	
	Return Result;
	
EndFunction

// AddRoutingFilesDescription adds a description of files with routing settings.
// 
// Parameters:
// 	Commits - Map - deserialized commits from the GitLab request;
//	ProjectId - String - project id from the GitLab request;
// 	RemoteFiles - ValueTable - files from the GitLab server with its descriptions:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the file in remote repository (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
Procedure AddRoutingFilesDescription( RemoteFiles, Val Commits, Val ProjectId ) Export
	
	Var FilePath;
	Var CommitSHA;
	Var RAWFilePath;
	Var NewDescription;
	
	If ( Commits = Undefined ) Then
		
		Return;
		
	EndIf;

	FilePath = ServicesSettings.CurrentSettings().RoutingFileName;
	
	For Each Commit In Commits Do

		NewDescription = RemoteFiles.Add();
		CommitSHA = Commit.Get( "id" );
		RAWFilePath = GitLab.RAWFilePath( ProjectId, FilePath, CommitSHA );
		NewDescription.RAWFilePath = RAWFilePath;
		NewDescription.FilePath = FilePath;
		NewDescription.Action = "";
		NewDescription.Date = Commit.Get( "timestamp" );
		NewDescription.CommitSHA = CommitSHA;
	
	EndDo;

EndProcedure

// AppendQueryDataByRoutingSettings adds file routing settings deserialized from JSON to the request data.
// 
// Parameters:
// 	Commits - Map - deserialized commits from the GitLab request;
// 	RemoteFiles - ValueTable - files from the GitLab server with its descriptions:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the file in remote repository (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
Procedure AppendQueryDataByRoutingSettings( Commits, Val RemoteFiles ) Export
	
	Var FilePath;
	Var Filter;
	Var File;
	Var Stream;
	Var Settings;

	FilePath = ServicesSettings.CurrentSettings().RoutingFileName;	
	
	For Each Commit In Commits Do
		
		Filter = New Structure();
		Filter.Insert( "CommitSHA", Commit.Get( "id" ) );
		Filter.Insert( "FilePath", FilePath );
		Filter.Insert( "Action", "" );
		Filter.Insert( "ErrorInfo", "" );
		
		File = RemoteFiles.FindRows( Filter );
		
		If ( NOT ValueIsFilled(File) ) Then
			
			Continue;
			
		EndIf;
		
		Stream = File[0].BinaryData.OpenStreamForRead();
		Settings = HTTPConnector.JsonВОбъект( Stream );
		CommonUseServerCall.AppendCollectionFromStream( Settings, "json", Stream );
		
		Commit.Insert( "settings", Settings );
		
	EndDo;
	
EndProcedure
 
#EndRegion

#Region Private

// FileToSend returns a description of the file to delivery it to the receivers.
//
// Returns:
// 	Structure - description:
// * FileName - String - file name; 
// * BinaryData - BinaryData - file data;
// * Routes - Array of String - delivery end-point service URLs;
// * ErrorInfo - String - description of an error while processing files;
//
Function FileToSend()
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "FileName", "" );
	Result.Insert( "BinaryData", Undefined );
	Result.Insert( "Routes", Undefined );
	Result.Insert( "ErrorInfo", "" );
	
	Return Result;
	
EndFunction

// RoutesByCommits returns file delivery routes by commits.
// Routes are taken from the commit's settings file (see ServicesSettings.RoutingFileName) or from custom settings.
// For custom settings, the priority is higher than for settings from the file.
// 
// Parameters:
// 	Commits - Map - deserialized commits from the GitLab request;
// 	
// Returns:
// 	Map - file routes by commits:
// 	* Key - String - commit SHA;
// 	* Value - Map - routes;
// 	** Key - String - relative path to the file in remote repository (with the filename);
// 	** Value - Array of String - file delivery end-point services URLs;
//
Function RoutesByCommits( Val Commits )

	Var Settings;
	Var Result;
	
	Result = New Map();
	
	For Each Commit In Commits Do
		
		Settings = Commit.Get( "custom_settings" );
		
		If ( Settings = Undefined ) Then
			
			Settings = Commit.Get( "settings" );
			
		EndIf;
		
		If ( Settings = Undefined ) Then
			
			Continue;
			
		EndIf;
		
		Result.Insert( Commit.Get( "id" ), Routes( Settings ) );

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
			
		URL = Service.Get( "address" );
		
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
	
	EnabledServices = EnabledServices( Settings );
	
	Files = Settings.Get( "epf" );
	
	Result = New Map();
	
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

#EndRegion