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
	Result.Insert( "Token", ServicesSettings.GetGitLabToken() );
	Result.Insert( "Timeout", ServicesSettings.GetGitLabTimeout() );
	
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

// GetModifiedFiles returns metadata of modified files from the GitLab request body.
// 
// Parameters:
//	RequestData - Map - deserialized GitLab request body;
// 	
// Returns:
// 	Array of Structure - modified files metadata:
// 	* Id - String - commit id;
// 	* FilePath - String - relative path to the file for the remote repository (with the filename);
//
Function GetModifiedFiles( Val RequestData ) Export

	Var Id;
	Var ModifiedFiles;
	Var FileMetadata;
	Var Result;
	
	Result = New Array();
	
	For Each Commit In GetCommits( RequestData )  Do
		
		Id = Commit.Get("id");
		ModifiedFiles = Commit.Get( "modified" );

		For Each FilePath In ModifiedFiles Do
			
			If NOT ( HasExtension(FilePath, "EPF") OR HasExtension(FilePath, "ERF") ) Then
				
				Continue;

			EndIf;
			
			FileMetadata = New Structure();
			FileMetadata.Insert( "Id", Id );
			FileMetadata.Insert( "FilePath", FilePath );

			Result.Add( FileMetadata );

		EndDo;		
		
	EndDo;
	
	Return Result;
	
EndFunction

// RAWFilePath returns the URL-encoded relative path to the RAW file in accordance to the GitLab REST API.
// 
// Parameters:
// 	FilePath - String - relative path to the file on GitLab, for example "Path/File 1.epf";
// 	ProjectId - String - project id;
// 	CommitSHA - String - сommit SHA;
// 
// Returns:
// 	String - URL-encoded relative file path,
// 			for example "/api/v4/projects/1/repository/files/Path/File%201.epf/raw?ref=123af";
//
Function GetRAWFilePath( Val FilePath, Val ProjectId, Val CommitSHA ) Export
	
	Var URL;
	
	URL = "/api/v4/projects/%1/repository/files/%2/raw?ref=%3";

	Return StrTemplate( URL, ProjectId, EncodeString(FilePath, StringEncodingMethod.URLEncoding), CommitSHA );
	
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

// GetRAWFiles returns the files from the GitLab server with its descriptions.
//
// Parameters:
// 	ConnectionParams - Structure - (see GetConnectionParams)
// 	FilePaths - Array of String - an array of URL-encoded relative paths to the downloaded files, for example
// 								"/api/v4/projects/1/repository/files/D0%BA%D0%B0%201.epf/raw?ref=ef3529e5486ff";
// 	
// Returns:
// 	Array of Structure - description:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name (UTF-8);
// * BinaryData - BinaryData - file data;
// * ErrorInfo - Undefined, ErrorInfo - file download error;
// 
Function GetRAWFiles( Val ConnectionParams, Val FilePaths ) Export
	
	Var Result;

	Result = New Array();
	
	For Each RAWFilePath In FilePaths Do
		
		Result.Add( DownloadFile(ConnectionParams, RAWFilePath) );
		
	EndDo;
	
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

Function FileDescription()

	Var Result;
	
	Result = New Structure();
	Result.Insert( "RAWFilePath", "" );
	Result.Insert( "FileName", "" );
	Result.Insert( "BinaryData", Undefined );
	Result.Insert( "ErrorInfo", Undefined );
	
	Return Result;

EndFunction

Function AdditionalParams( Val ConnectionParams )
	
	Var Headers;
	Var Result;
	
	Headers = New Map();
	Headers.Insert( "PRIVATE-TOKEN", ConnectionParams.Token );
	
	Result = New Structure();
	Result.Insert( "VerifySSL", False );
	Result.Insert( "Headers", Headers );
	Result.Insert( "Timeout", ConnectionParams.Timeout );
	
	Return Result;
	
EndFunction

// HasExtension returns the result that the file in the path has the specified extension.
// 
// Parameters:
// 	Path - String - path to the file (with the filename);
//  Ext - String - extension (without dot);
//
// Returns:
// 	Boolean - True - the file contains the specified extension, otherwise - False;
//
Function HasExtension( Val Path, Val Ext )
	
	Return StrEndsWith( Upper(Path), "." + Upper(Ext) );
	
EndFunction

// DownloadFile returns the file from the GitLab server with its description.
// 
// Parameters:
// 	ConnectionParams - Structure - (see GetConnectionParams)
// 	FilePath - String - URL-encoded relative path to the RAW file, for example
// 							"/api/v4/projects/1/repository/files/D0%BA%D0%B0%201.epf/raw?ref=ef3529e5486ff";
// 	
// Returns:
//	Structure - description:
// * FilePath - String - relative URL path to the RAW file;
// * FileName - String - file name (UTF-8);
// * BinaryData - BinaryData - file data;
// * ErrorInfo - Undefined, ErrorInfo - file download error;
//
Function DownloadFile( Val ConnectionParams, Val FilePath )

	Var URL;
	Var Response;
	Var Message;
	Var Result;
	
	Result = FileDescription();
	
	Result.RAWFilePath = FilePath;

	URL = ConnectionParams.URL + FilePath;

	Try
		
		Response = HTTPConnector.Get( URL, Undefined, AdditionalParams(ConnectionParams) );

		If ( NOT HTTPStatusCodesClientServerCached.isOk(Response.StatusCode) ) Then
			
			Raise HTTPStatusCodesClientServerCached.FindIdByCode( Response.StatusCode );
		
		EndIf;

		Result.FileName = Response.Headers.Get( "X-Gitlab-File-Name" );
		Result.BinaryData = HTTPConnector.AsBinaryData(Response);
		
	Except

		Message = Logs.Messages().DOWNLOAD_ERROR;
		Message = StrTemplate( Message, URL, ErrorProcessing.DetailErrorDescription(ErrorInfo()) );
		Result.ErrorInfo = CommonUseServerCall.NewErrorInfo( Message );
		
	EndTry;

	Return Result;
	
EndFunction

#EndRegion
