#Region Public

// GetConnectionParams returns the connection parameters to the GitLab server.
// 
// Parameters:
// 	URL - String - GitLab server URL, for example: "http://www.example.org";
//
// Returns:
//	Structure - description:
// * URL - String - GitLab server URL;
// * Token - String - access token;
// * Timeout - Number - connection timeout, sec. (0 - timeout is not set);
//
Function GetConnectionParams( Val URL ) Export
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "URL", URL );
	Result.Insert( "Token", ServicesSettings.ExternalStorageToken() );
	Result.Insert( "Timeout", ServicesSettings.ExternalStorageTimeout() );
	
	Return Result;
	
EndFunction

// GetCheckoutSHA returns "checkout_sha" from GitLab request body.
// 
// Parameters:
// 	RequestData - Map - deserialized GitLab request body;
// 	
// Returns:
// 	- Undefined - no data found;
// 	- String - checkout SHA;
// 	
Function GetCheckoutSHA( Val RequestData ) Export
	
	Return RequestData.Get("checkout_sha");
	
EndFunction

// GetProject returns the project description from the GitLab request body.
// 
// Parameters:
//	RequestData - Map - deserialized GitLab request body;
//
// Returns:
// 	Structure - project description:
// * Id - String - project id;
// * URL - String - GitLab project URL, for example: "http://www.example.org/user/project"; 
// * ServerURL - String - GitLab server URL, for example: "http://www.example.org";
// 
Function GetProject( Val RequestData ) Export
	
	Var Project;
	Var ID;
	Var URL;
	
	Project = RequestData.Get( "project" );
	
	If ( Project = Undefined ) Then
		
		Return Undefined;
		
	EndIf;

	ID = Project.Get( "id" );
	URL = Project.Get( "web_url" );

	If ( (URL = Undefined) OR (ID = Undefined) ) Then
		
		Return Undefined;
		
	EndIf;
	
	Return New Structure( "Id, URL, ServerURL", ID, URL, GetServerURL(URL) );
	
EndFunction

// GetCommits returns commits from the GitLab request body.
// If the result is undefined, an exception will be thrown.
// 
// Parameters:
//	RequestData - Map - deserialized GitLab request body;
//
// Returns:
// 	Array of Map - deserialized GitLab commits;
// 
Function GetCommits( Val RequestData ) Export
	
	Return RequestData.Get( "commits" );
	
EndFunction

// RAWFilePath returns the URL-encoded relative path to the RAW file in accordance to the GitLab REST API.
// 
// Parameters:
// 	ProjectId - String - project id;
// 	FilePath - String - relative path to the file on GitLab, for example "Path/File 1.epf";
// 	CommitSHA - String - сommit SHA;
// 
// Returns:
// 	String - URL-encoded relative file path,
// 			for example "/api/v4/projects/1/repository/files/Path/File%201.epf/raw?ref=123af";
//
Function GetRAWFilePath( Val FilePath, Val ProjectId, Val CommitSHA ) Export
	
	Var URL;
	
	URL = "/api/v4/projects/%1/repository/files/%2/raw?ref=%3";
	URL = StrTemplate( URL, ProjectId, FilePath, CommitSHA );
	
	Return EncodeString( URL, StringEncodingMethod.URLInURLEncoding );
	
EndFunction

// GetFileActions returns a list of actions with the file in accordance to the GitLab REST API.
// 
// Returns:
// 	Array of String - values: "added", "modified", "removed";
//
Function GetFileActions() Export
	
	Var Result;
	
	Result = New Array();
	Result.Add( "added" );
	Result.Add( "modified" );
	Result.Add( "removed" );

	Return Result;
	
EndFunction

#EndRegion

#Region Private

Function GetServerURL( Val URL )
	
	Var Delimiter;
	
	Delimiter = StrFind( URL, "/", , , 3 ) - 1;
	
	If ( Delimiter > 0 ) Then
		
		URL = Left( URL, Delimiter );
		
	EndIf;
	
	Return URL;
	
EndFunction

#EndRegion
