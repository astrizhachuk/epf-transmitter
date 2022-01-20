#Region Public

// GetCheckoutSHA returns "checkout_sha" from request body.
// 
// Parameters:
// 	RequestData - Map - deserialized request body;
// 	
// Returns:
// 	- Undefined - no data found;
// 	- String - checkout_sha;
// 	
Function GetCheckoutSHA( Val RequestData ) Export
	
	Return GitLabAPI.GetCheckoutSHA( RequestData );
	
EndFunction

// GetProjectOrRaise returns the project description from request body.
// If the result is undefined, an exception will be thrown.
// 
// Parameters:
//	RequestData - Map - deserialized request body;
//
// Returns:
// 	Structure - project description:
// * Id - String - project id;
// * URL - String - project URL, for example: "http://www.example.org/user/project"; 
// * ServerURL - String - server URL, for example: "http://www.example.org";
// 
Function GetProjectOrRaise( Val RequestData ) Export
	
	Var Result;
	
	Result = GitLabAPI.GetProject( RequestData );
	
	If ( Result = Undefined ) Then
		
		Raise Logs.Messages().NO_PROJECT;
		
	EndIf;
	
	Return Result;
	
EndFunction

// GetCommitsOrRaise returns commits from request body. If the result is undefined, an exception will be thrown.
// 
// Parameters:
//	RequestData - Map - deserialized request body;
//
// Returns:
// 	Array of Map - deserialized commits;
// 
Function GetCommitsOrRaise( Val RequestData ) Export
	
	Var Result;
	
	Result = GitLabAPI.GetCommits( RequestData );
	
	If ( Result = Undefined ) Then
		
		Raise Logs.Messages().NO_COMMITS;
		
	EndIf;
	
	Return Result;
	
EndFunction

// GetCommitOrRaise returns commit from request body. If the result is undefined, an exception will be thrown.
// 
// Parameters:
//	RequestData - Map - deserialized request body;
//	CommitSHA - String - сommit SHA;
//
// Returns:
// 	Map - deserialized commit;
// 
Function GetCommitOrRaise( Val RequestData, Val CommitSHA ) Export
	
	Var Commits;
	
	Commits = GetCommitsOrRaise( RequestData );
	
	For Each Commit In Commits Do

		If ( Commit.Get("id") <> CommitSHA ) Then
			
			Continue;
			
		EndIf;
		
		Return Commit;
		
	EndDo;
	
	Raise Logs.Messages().NO_COMMIT;
	
EndFunction	

// GetFromIB returns the deserialized request body stored in the infobase. 
// 
// Parameters:
// 	RequestHandler - CatalogRef.ExternalRequestHandlers - ref to external request handler;
//  CheckoutSHA - String - event identifier;
// 	
// Returns:
// 	- Undefined - no data found;
// 	- Map - deserialized request body;
// 	
Function GetFromIB( Val RequestHandler, Val CheckoutSHA ) Export
	
	Var Filter;
	
	Filter = New Structure();
	Filter.Insert( "RequestHandler", RequestHandler );
	Filter.Insert( "CheckoutSHA", CheckoutSHA );
	
	InformationRegisters.ExternalRequests.Get(Filter).Data.Get();
	
	Return InformationRegisters.ExternalRequests.Get(Filter).Data.Get();

EndFunction

// AppendRoutingSettings adds JSON-formatted and deserialized routing settings to the request data.
// 
// Parameters:
// 	RequestData - Map - deserialized request body;
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
Procedure AppendRoutingSettings( RequestData, Val Files ) Export
	
	Var FileName;
	Var Commits;
	Var RoutingFileMetadata;
	
	NODE_NAME = "settings";
	
	FileName = ServicesSettings.RoutingFileName();
	
	Commits = GetCommitsOrRaise( RequestData );
	
	For Each Commit In Commits Do
		
		RoutingFileMetadata = Files.FindRows( FindFileMetadataFilter(Commit, FileName) );
		
		If ( NOT ValueIsFilled(RoutingFileMetadata) ) Then
			
			Continue;
			
		EndIf;
		
		AppendSettings( Commit, NODE_NAME, RoutingFileMetadata[0].BinaryData );
		
	EndDo;	
	
EndProcedure

// AppendCustomRoutingSettings adds JSON-formatted and deserialized custom routing settings to the request data.
// 
// Parameters:
// 	RequestData - Map - deserialized request body;
//	CommitSHA - String - сommit SHA;
// 	JSON - String - routes in JSON format;
//
Procedure AppendCustomRoutingSettings( RequestData, Val CommitSHA, Val JSON ) Export
	
	Var Commit;
	Var Data;
	
	NODE_NAME = "custom_settings";
	
	Commit = GetCommitOrRaise( RequestData, CommitSHA );
	Data = GetBinaryDataFromString( JSON, TextEncoding.UTF8 );
	
	AppendSettings( Commit, NODE_NAME, Data );
	
EndProcedure

// RemoveCustomRoutingSettings removes custom routing settings from the request data
// stored in the infobase and returns the default routes in JSON format.
// 
// Parameters:
// 	RequestHandler - CatalogRef.ExternalRequestHandlers - ref to external request handler;
//  CheckoutSHA - String - event identifier;
//	CommitSHA - String - сommit SHA;
// 	
// Returns:
// String - default routing settings in JSON format;
// 	
Function RemoveCustomRoutingSettings( Val RequestHandler, Val CheckoutSHA, Val CommitSHA ) Export
	
	Var RequestData;
	Var Commit;
	Var DefaultJSON;
	Var CustomJSON;

	CUSTOM = "custom_settings";
	
	RequestData = ExternalRequests.GetFromIB( RequestHandler, CheckoutSHA );
	
	If ( RequestData = Undefined ) Then
		
		Raise Logs.Messages().NO_REQUEST_DATA;
		
	EndIf;
		
	Commit = GetCommitOrRaise( RequestData, CommitSHA );
	DefaultJSON = GetDefaultSettingsJSON( Commit );
	CustomJSON = GetCustomSettingsJSON( Commit );
	
	If ( CustomJSON <> Undefined ) Then
		
		Commit.Delete( CUSTOM );
		InformationRegisters.ExternalRequests.SaveData( RequestHandler, CheckoutSHA, RequestData );
	
	EndIf;

	Return DefaultJSON;
	
EndFunction

// GetCustomSettingsJSON returns custom routes in JSON format.
// 
// Parameters:
// 	Commit - Map - deserialized commit;
// 	
// Returns:
// 	- Undefined - no data found;
// 	- String - custom routes;
// 	
Function GetCustomSettingsJSON( Val Commit ) Export

	CUSTOM = "custom_settings";

	Return GetSettingsJSON( Commit, CUSTOM );
	
EndFunction

// GetCustomSettingsJSON returns the default routes in JSON format.
// 
// Parameters:
// 	Commit - Map - deserialized commit;
// 	
// Returns:
// 	- Undefined - no data found;
// 	- String - default routes;
// 
Function GetDefaultSettingsJSON( Val Commit ) Export
	
	DEFAULT = "settings";
	
	Return GetSettingsJSON( Commit, DEFAULT );
	
EndFunction

#EndRegion

#Region Private

Function GetSettingsJSON( Val Commit, Val Source )
	
	Var Result;

	JSON = "json";
	
	Result = Commit.Get( Source );
	
	If ( Result = Undefined ) Then
		
		Return Result;
		
	EndIf;
	
	Return Result.Get( JSON );
	
EndFunction

Function FindFileMetadataFilter( Val Commit, Val FilePath )
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "CommitSHA", Commit.Get("id") );
	Result.Insert( "FilePath", FilePath );
	Result.Insert( "Action", "" );
	Result.Insert( "ErrorInfo", Undefined );
		
	Return Result;
	
EndFunction

Процедура AppendSettings(Commit, Val NodeName, Знач BinaryData )
	
	Var Data;
	Var Settings;
	
	JSON = "json";
	
	Data = BinaryData.OpenStreamForRead();
	Settings = HTTPConnector.JsonToObject( Data );
	CommonUseServerCall.AppendCollectionFromStream( Settings, JSON, Data );
	
	Commit.Insert( NodeName, Settings );
	
КонецПроцедуры

#EndRegion
