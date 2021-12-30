#Region Public

// GetRequestHandlerStateMessage returns the current state of the GitLab request handler as a message object.
// 
// Returns:
// 	Structure - message object:
// * message - String - text message;
//
Function GetRequestHandlerStateMessage() Export
	
	Var Result;
	
	MESSAGE_ENABLED = NStr( "ru = 'обработка запросов включена';en = 'request handler enabled'" );
	MESSAGE_DISABLED = NStr( "ru = 'обработка запросов отключена';en = 'request handler disabled'" );
	
	If ( ServicesSettings.HandleRequests() ) Then
		
		Result = HTTPServices.CreateMessage( MESSAGE_ENABLED );
		
	Else
		
		Result = HTTPServices.CreateMessage( MESSAGE_DISABLED );
		
	EndIf;
	
	Return Result;
	
EndFunction

// RemoteFile returns the file from the GitLab server with its description.
// 
// Parameters:
// 	ConnectionParams - (see GitLabAPI.GetConnectionParams)
// 	FilePath - String - URL-encoded relative URL path to the RAW file, for example
// 							"/api/v4/projects/1/repository/files/D0%BA%D0%B0%201.epf/raw?ref=ef3529e5486ff";
// 	
// Returns:
//	Structure - description:
// * FilePath - String - relative URL path to the RAW file from parameter FilePath;
// * FileName - String - file name (UTF-8);
// * BinaryData - BinaryData - file data;
// * ErrorInfo - String - description of an error while processing files;
//
Function RemoteFile( Val ConnectionParams, Val FilePath ) Export

	Var URL;
	Var Headers;
	Var AdditionalParams;
	Var Response;
	
	Var FileName;
	Var Message;
	Var ErrorInfo;
	
	Var Result;
	
	Result = RemoteFileDescription();
	Result.RAWFilePath = FilePath;

	URL = ConnectionParams.URL + FilePath;

	Try
	
		Headers = New Map();
		Headers.Insert( "PRIVATE-TOKEN", ConnectionParams.Token );
		
		AdditionalParams = New Structure();
		AdditionalParams.Insert( "Headers", Headers );
		AdditionalParams.Insert( "Timeout", ConnectionParams.Timeout );
		
		Response = HTTPConnector.Get( URL, Undefined, AdditionalParams );

		If ( NOT HTTPStatusCodesClientServerCached.isOk(Response.StatusCode) ) Then
			
			Raise HTTPStatusCodesClientServerCached.FindIdByCode( Response.StatusCode );
		
		EndIf;
		// TODO это покрыто тестом???
		FileName = Response[ "Headers" ].Get( "X-Gitlab-File-Name" );
		
		If ( FileName = Undefined ) Then
			
			Raise NStr( "ru = 'Файл не найден.';en = 'File not found.'" );
			
		EndIf;

		If ( NOT ValueIsFilled(Response["Body"]) ) Then
			
			Raise NStr( "ru = 'Пустой файл.';en = 'File is empty.'" );
			
		EndIf;

		Result.FileName = FileName;
		Result.BinaryData = Response["Body"];
		
	Except
	
		Message = NStr( "ru = 'Ошибка получения файла: %1';en = 'Error getting file: %1'" );
		ErrorInfo = URL + Chars.LF + ErrorProcessing.DetailErrorDescription( ErrorInfo() );
		Result.ErrorInfo = StrTemplate( Message, ErrorInfo );
		
	EndTry;

	Return Result;
	
EndFunction

// RemoteFile returns the files from the GitLab server with its descriptions.
//
// Parameters:
// 	GetConnectionParams - (see GitLabAPI.GetConnectionParams)
// 	FilePaths - Array of String - an array of relative URL paths (URL-encoded) to the files, for example
// 							 "/api/v4/projects/1/repository/files/D0%BA%D0%B0%201.epf/raw?ref=ef3529e5486ff";
// 	
// Returns:
// 	Array of Structure - description:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name (UTF-8);
// * BinaryData - BinaryData - file data;
// * ErrorInfo - String - description of an error while processing files;
// 
Function RemoteFiles( Val ConnectionParams, Val FilePaths ) Export
	
	Var Result;

	Result = New Array();
	
	For Each RAWFilePath In FilePaths Do
		
		Result.Add( RemoteFile(ConnectionParams, RAWFilePath) );
		
	EndDo;
	
	Return Result;

EndFunction



// Deprevated See GitLabAPI.GetProject
// ProjectDescription returns a description of the project from the GitLab request data.
// 
// Parameters:
//	QueryData - Map - GitLab deserialized request body;
//
// Returns:
// 	Structure - description:
// * Id - String - project id;
// * URL - String - URL to GitLab server, for example: "http://www.example.org";
// 
Function ProjectDescription( Val QueryData ) Export
	
	Var Project;
	Var URL;
	Var Delim;

	Var Result;
	
	Project = QueryData.Get( "project" );
	URL = Project.Get( "http_url" );
	
	Delim = StrFind( URL, "/", , , 3 ) - 1;
	
	If ( Delim > 0 ) Then
		
		URL = Left( URL, Delim );
		
	EndIf;	
			
	Result = New Structure();
	Result.Insert( "Id", String(Project.Get("id")) );
	Result.Insert( "URL", URL );	

	Return Result;
	
EndFunction

// MergeRequests returns all GitLab Merge Requests deserialized from JSON for one project.
// 
// Parameters:
// 	URL - String - URL to GitLab server, for example: "http://www.example.org";
// 	Id - String - project id;
//
// Returns:
//   Array, Map, Structure - Merge Requests deserialized from JSON;
//
Function MergeRequests( Val URL, Val Id ) Export
	
	Var ConnectionParams;
	Var Headers;
	Var AdditionalParams;
	
	ConnectionParams = GitLabAPI.GetConnectionParams( URL );
	
	Headers = New Map();
	Headers.Insert( "PRIVATE-TOKEN", ConnectionParams.Token );
		
	AdditionalParams = New Structure();
	AdditionalParams.Insert( "Заголовки", Headers );
	AdditionalParams.Insert( "Таймаут", ConnectionParams.Timeout );
	
	URL = ConnectionParams.URL + MergeRequestsPath( Id );

	Return HTTPConnector.GetJson( URL, Undefined, AdditionalParams );
	
EndFunction

#EndRegion

#Region Private

Function RemoteFileDescription()

	Var Result;
	
	Result = New Structure();
	Result.Insert( "RAWFilePath", "" );
	Result.Insert( "FileName", "" );
	Result.Insert( "BinaryData", Undefined );
	Result.Insert( "ErrorInfo", "" ); //TODO это не текст, а объект, чекнуть объявления
	
	Return Result;

EndFunction

Function MergeRequestsPath( Val ProjectId )
	
	Return StrTemplate( "/api/v4/projects/%1/merge_requests", String(ProjectId) );
	
EndFunction

#EndRegion
