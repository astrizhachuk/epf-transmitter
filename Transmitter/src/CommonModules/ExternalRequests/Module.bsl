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
		
		Raise Logs.Messages().NO_POJECT_DESCRIPTION;
		
	EndIf;
	
	Return Result;
	
EndFunction

// GetCommitsOrRaise returns commits from request body.
// If the result is undefined, an exception will be thrown.
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

// GetRequestBody returns the deserialized request body stored in the infobase. 
// 
// Parameters:
// 	RequestHandler - CatalogRef.ExternalRequestHandlers - ref to external request handler;
//  CheckoutSHA - String - event identifier;
// 	
// Returns:
// 	- Undefined - no data found;
// 	- Map - deserialized request body;
// 	
Function GetRequestBody( Val RequestHandler, Val CheckoutSHA ) Export
	
	// TODO не всегда нужно логировать (проверить вызовы и создать новый метод без лога
	// или в менеджер вынести сам процесс получения данных)
	
	Var Filter;
	Var Message;
	Var Result;
	
	Filter = New Structure();
	Filter.Insert( "Webhook", RequestHandler );
	Filter.Insert( "CheckoutSHA", CheckoutSHA );
	
	Result = InformationRegisters.QueryData.Get(Filter).Data.Get();
	
	Message = Metadata.InformationRegisters.QueryData.FullName();
	Message = Logs.AddPrefix( Message, CheckoutSHA );
	
	If ( ValueIsFilled(Result) ) Then
	
		Logs.Info( Logs.Events().LOAD_DATA, Message, RequestHandler );
		
	Else
		
		Logs.Error( Logs.Events().LOAD_DATA, Message, RequestHandler );
		
	EndIf;
	
	Return Result;

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

// Dump saves the deserialized request body to the infobase.
// 
// Parameters:
// 	RequestHandler - CatalogRef.ExternalRequestHandlers - ref to external request handler;
//  CheckoutSHA - String - event identifier;
// 	Data - Map - deserialized request body;
//
Procedure Dump( Val RequestHandler, Val CheckoutSHA, Val Data ) Export
	
	Var Message;
	
	Message = Metadata.InformationRegisters.QueryData.FullName();
	Message = Logs.AddPrefix( Message, CheckoutSHA );
	
	Try
		
		InformationRegisters.QueryData.SaveData( RequestHandler, CheckoutSHA, Data );
		
	Except
		
		Logs.Error( Logs.Events().SAVE_DATA, Message, RequestHandler );
		
		Raise;
		
	EndTry;
	
	Logs.Info( Logs.Events().SAVE_DATA, Message, RequestHandler );	

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
