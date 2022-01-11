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
	Var Data;
	Var Settings;
	
	FileName = ServicesSettings.RoutingFileName();
	
	Commits = GetCommitsOrRaise( RequestData );
	
	For Each Commit In Commits Do
		
		RoutingFileMetadata = Files.FindRows( FindFileMetadataFilter(Commit, FileName) );
		
		If ( NOT ValueIsFilled(RoutingFileMetadata) ) Then
			
			Continue;
			
		EndIf;
		
		Data = RoutingFileMetadata[0].BinaryData.OpenStreamForRead();
		Settings = HTTPConnector.JsonToObject( Data );
		CommonUseServerCall.AppendCollectionFromStream( Settings, "json", Data );
		
		Commit.Insert( "settings", Settings );
	
	EndDo;	
	
EndProcedure

#EndRegion

#Region Private

Function FindFileMetadataFilter( Val Commit, Val FilePath )
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "CommitSHA", Commit.Get("id") );
	Result.Insert( "FilePath", FilePath );
	Result.Insert( "Action", "" );
	Result.Insert( "ErrorInfo", Undefined );
		
	Return Result;
	
EndFunction

#EndRegion
