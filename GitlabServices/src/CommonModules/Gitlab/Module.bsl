#Region Public

// ConnectionParams returns the connection parameters to the GitLab server.
// 
// Parameters:
// 	URL - String - URL to GitLab server, for example: "http://www.example.org";
//
// Returns:
//	Structure - description:
// * URL - String - URL to GitLab server;
// * Token - String - access token to the server from the current settings;
// * Timeout - Number - the connection timeout from the current settings, sec (0 - timeout is not set);
//
Function ConnectionParams( Val URL ) Export
	
	Var CurrentSettings;
	Var Result;
	
	CurrentSettings = ServicesSettings.CurrentSettings();
	
	Result = New Structure();
	Result.Insert( "URL", URL );
	Result.Insert( "Token", CurrentSettings.TokenGitLab );
	Result.Insert( "Timeout", CurrentSettings.TimeoutGitLab );
	
	Return Result;
	
EndFunction

// RemoteFile returns the file from the GitLab server with its description.
// 
// Parameters:
// 	ConnectionParams - (See GitLab.ConnectionParams)
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
		AdditionalParams.Insert( "Заголовки", Headers );
		AdditionalParams.Insert( "Таймаут", ConnectionParams.Timeout );
		
		Response = HTTPConnector.Get( URL, Undefined, AdditionalParams );

		If ( NOT HTTPStatusCodesClientServerCached.isOk(Response.КодСостояния) ) Then
			
			Raise HTTPStatusCodesClientServerCached.FindIdByCode( Response.КодСостояния );
		
		EndIf;
		
		FileName = Response["Заголовки"].Get( "X-Gitlab-File-Name" );
		
		If ( FileName = Undefined ) Then
			
			Raise NStr( "ru = 'Файл не найден.';en = 'File not found.'" );
			
		EndIf;

		If ( NOT ValueIsFilled(Response["Тело"]) ) Then
			
			Raise NStr( "ru = 'Пустой файл.';en = 'File is empty.'" );
			
		EndIf;

		Result.FileName = FileName;
		Result.BinaryData = Response["Тело"];
		
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
// 	ConnectionParams - (See GitLab.ConnectionParams)
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

// RemoteFilesEmpty returns an empty remote files collection.
// 
// Returns:
//	ValueTable - description:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the file in remote repository (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
Function RemoteFilesEmpty() Export
	
	Var Result;
	
	Result = GitLabCached.RemoteFilesEmpty();
	Result.Clear(); // ValueTable is cached, so we exclude returning a filled values.

	Return Result;
	
EndFunction

// RemoteFilesWithDescription returns description of binary data files after parsing commits data
// from deserialized GitLab request;
// 
// Parameters:
//	Webhook - CatalogRef.ОбработчикиСобытий - a ref to webhook;
// 	Commits - Map - deserialized commits from the GitLab request;
// 	Project - Structure - description;
// * Id - String - project id;
// * URL - String - URL to GitLab server, for example: "http://www.example.org";
//
// Returns:
//	ValueTable - description:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the file in remote repository (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
Function RemoteFilesWithDescription( Val Webhook, Commits, Project ) Export
	
	Var LoggingOptions;
	Var ConnectionParams;
	Var RemoteFiles;
	
	EVENT_MESSAGE_BEGIN = NStr( "ru = 'Core.ПолучениеФайловGitLab.Начало';en = 'Core.ReceivingFilesGitLab.Begin'" );
	EVENT_MESSAGE = NStr( "ru = 'Core.ПолучениеФайловGitLab';en = 'Core.ReceivingFilesGitLab'" );
	EVENT_MESSAGE_END = NStr( "ru = 'Core.ПолучениеФайловGitLab.Окончание';en = 'Core.ReceivingFilesGitLab.End'" );
	
	RECEIVING_MESSAGE = NStr( "ru = 'получение файлов с сервера...';en = 'receiving files from the server...'" );
	
	LoggingOptions = Логирование.ДополнительныеПараметры( Webhook ); 
	Логирование.Информация( EVENT_MESSAGE_BEGIN, RECEIVING_MESSAGE, LoggingOptions );	

	RemoteFiles = AllRemoteFilesByActions( Commits, Project.Id );
	RemoteFiles = RemoteFilesSliceLast( RemoteFiles );
	Routing.AddRoutingFilesDescription( RemoteFiles, Commits, Project.Id );

	ConnectionParams = ConnectionParams( Project.URL );
	FillRemoteFilesBinaryData( RemoteFiles, ConnectionParams );	

	For Each RemoteFile In RemoteFiles Do
		
		If ( NOT IsBlankString(RemoteFile.ErrorInfo) ) Then
			
			Логирование.Ошибка( EVENT_MESSAGE, RemoteFile.ErrorInfo, LoggingOptions );
			
		EndIf;
			
	EndDo;
	
	Логирование.Информация( EVENT_MESSAGE_END, RECEIVING_MESSAGE, LoggingOptions );	

	Return RemoteFiles;	
	
EndFunction

// ProjectDescription returns a description of the project from the GitLab request data.
// 
// Parameters:
//	QueryData - Map - GitLab request body deserialized from JSON;
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
	
	ConnectionParams = ConnectionParams( URL );
	
	Headers = New Map();
	Headers.Insert( "PRIVATE-TOKEN", ConnectionParams.Token );
		
	AdditionalParams = New Structure();
	AdditionalParams.Insert( "Заголовки", Headers );
	AdditionalParams.Insert( "Таймаут", ConnectionParams.Timeout );
	
	URL = ConnectionParams.URL + MergeRequestsPath( Id );

	Return HTTPConnector.GetJson( URL, Undefined, AdditionalParams );
	
EndFunction

#EndRegion

#Region Internal

// RAWFilePath returns the URL-encoded relative path to the RAW file.
// 
// Parameters:
// 	ProjectId - String - project id;
// 	FilePath - String - relative path to a file in the remote repository, for example "Path/File 1.epf";
// 	CommitSHA - String - сommit SHA;
// 
// Returns:
// 	String - URL-encoded relative file path, like "/api/v4/projects/1/repository/files/Path/File 1.epf/raw?ref=123af";
//
Function RAWFilePath( Val ProjectId, Val FilePath, Val CommitSHA ) Export
	
	Var Template;
	
	Template = "/api/v4/projects/%1/repository/files/%2/raw?ref=%3";
	FilePath = EncodeString( FilePath, StringEncodingMethod.URLEncoding );
	
	Return StrTemplate( Template, ProjectId, FilePath, CommitSHA );
	
EndFunction

#EndRegion

#Region Private

Function RemoteFileDescription()

	Var Result;
	
	Result = New Structure();
	Result.Insert( "RAWFilePath", "" );
	Result.Insert( "FileName", "" );
	Result.Insert( "BinaryData", Undefined );
	Result.Insert( "ErrorInfo", "" );
	
	Return Result;

EndFunction

// IsCompiledFile returns the result of checking that the file is a compiled external report or processing file.
// 
// Parameters:
// 	FilePath - String - relative path to the file (with the filename);
//
// Returns:
// 	Boolean - True - it's a compiled file, otherwise - False;
//
Function IsCompiledFile( Val FilePath )
	
	Return ( StrEndsWith(FilePath, ".epf") OR StrEndsWith(FilePath, ".erf") );
	
EndFunction

// ListFileActions returns a list of possible actions on files in accordance with the GitLab REST API.
// 
// Returns:
// 	Array - "added", "modified", "removed";
//
Function ListFileActions()
		
	Return GitLabCached.ListFileActions();
	
EndFunction

Procedure FillRemoteFilesCompiledFiles( RemoteFiles, Val Actions, Val Commit, Val ProjectId )
	
	Var CommitSHA;
	Var ActionDate;
	Var FilePaths;
	Var NewRemoteFile;
	
	CommitSHA = Commit.Get( "id" );
	ActionDate = Commit.Get( "timestamp" );
		
	For Each Action In Actions Do

		FilePaths = Commit.Get( Action );

		For Each FilePath In FilePaths Do
			
			If ( NOT IsCompiledFile(FilePath) ) Then
				
				Continue;

			EndIf;

			NewRemoteFile = RemoteFiles.Add();
			NewRemoteFile.RAWFilePath = RAWFilePath( ProjectId, FilePath, CommitSHA );
			NewRemoteFile.FilePath = FilePath;
			NewRemoteFile.Action = Action;
			NewRemoteFile.Date = ActionDate;
			NewRemoteFile.CommitSHA = CommitSHA;

		EndDo;

	EndDo;
		
EndProcedure

Function AllRemoteFilesByActions( Val Commits, Val ProjectId )
	
	Var ListFileActions;
	Var Result;
	
	Result = RemoteFilesEmpty();
	
	If ( Commits = Undefined ) Then
		
		Return Result;
		
	EndIf;
	
	ListFileActions = ListFileActions();
	
	For Each Commit In Commits Do

		FillRemoteFilesCompiledFiles( Result, ListFileActions, Commit, ProjectId );
		
	EndDo;
	
	Return Result;
	
EndFunction

Function MergeRequestsPath( Val ProjectId )
	
	Return StrTemplate( "/api/v4/projects/%1/merge_requests", String(ProjectId) );
	
EndFunction

Function RemoteFilesSliceLast( Val RemoteFiles, Val Action = "modified" )
	
	Var FilePaths;
	Var Filter;
	Var LastFile;
	Var Result;
	
	Result = RemoteFiles.CopyColumns();
	FilePaths = CommonUseClientServer.CollapseArray( RemoteFiles.UnloadColumn("FilePath") );
	
	If ( NOT ValueIsFilled(FilePaths) ) Then
		
		Return Result;
	
	EndIf;
	
	RemoteFiles.Sort( "Date Desc" );
	
	Filter = New Structure( "FilePath, Action" );
	Filter.Action = Action;
			
	For Each FilePath In FilePaths Цикл

		Filter.FilePath = FilePath;
		LastFile = RemoteFiles.FindRows( Filter );

		If ( ValueIsFilled(LastFile) ) Then

			FillPropertyValues( Result.Add(), LastFile[0] );
								
		EndIf;
		
	EndDo;

	Return Result;
	
EndFunction

Procedure FillRemoteFilesBinaryData( RemoteFiles, Val ConnectionParams )

	Var FilePaths;
	Var File;
	Var Files;

	FilePaths = RemoteFiles.UnloadColumn( "RAWFilePath" );
	Files = RemoteFiles( ConnectionParams, FilePaths );
	
	For Each RemoteFile In Files Do
			
		File = RemoteFiles.Find( RemoteFile.RAWFilePath, "RAWFilePath" );
		FillPropertyValues( File, RemoteFile );

	EndDo;

EndProcedure

#EndRegion
