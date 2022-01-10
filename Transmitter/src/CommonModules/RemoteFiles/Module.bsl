#Region Public

// GetFromRemoteVCS returns files downloaded from external repositories with their descriptions.
// 
// Parameters:
// 	ConnectionParams - Structure - connection parameters to the GitLab server (see GitLabAPI.GetConnectionParams);
// 	RequestData - Map - deserialized request body;
// 	
// Returns:
//	ValueTable - downloaded files metadata:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the file for the remote repository (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - file operation date;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - Undefined, ErrorInfo - file download error;
//
Function GetFromRemoteVCS( Val ConnectionParams, Val RequestData ) Export
	
	Var Files;
	Var Project;
	Var Commits;
	
	Files = FileMetadata();
	
	Project = ExternalRequests.GetProjectOrRaise( RequestData );
	Commits = ExternalRequests.GetCommitsOrRaise( RequestData );

	For Each Commit In Commits Do

		AddCompiledFiles( Files, Commit );
		
	EndDo;
	
	Files = SliceLastByAction( Files, "modified" );
	
	AddRoutingFiles( Files, Commits );

	AppendRAWFilePath( Files, Project.Id );

	AppendBinaryData( Files, ConnectionParams );	

	Return Files;
	
EndFunction

// GetFromIB returns files downloaded from external repositories and saved in the infobase.
// 
// Parameters:
//	RequestHandler - CatalogRef.ExternalRequestHandlers - ref to external request handler;
//  CheckoutSHA - String - event identifier;
//
// Returns:
// 	- Undefined - no data found;
//	- ValueTable - downloaded files metadata:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the file for the remote repository (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - file operation date;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - Undefined, ErrorInfo - file download error;
//
Function GetFromIB( Val RequestHandler, Val CheckoutSHA ) Export
	
	// TODO не всегда нужно логировать (проверить вызовы и создать новый метод без лога
	// или в менеджер вынести сам процесс получения данных)
	
	Var Filter;
	Var Message;
	Var Result;
	
	Filter = New Structure();
	Filter.Insert( "RequestHandler", RequestHandler );
	Filter.Insert( "CheckoutSHA", CheckoutSHA );
	
	Result = InformationRegisters.RemoteFiles.Get(Filter).Data.Get();
	
	Message = Metadata.InformationRegisters.RemoteFiles.FullName();
	
	If ( ValueIsFilled(Result) ) Then

		Message = Logs.AddPrefix( Message, CheckoutSHA );
		Logs.Info( Logs.Events().LOAD_DATA, Message, RequestHandler );
		
	Else
		
		Logs.Error( Logs.Events().LOAD_DATA, Message, RequestHandler );
		
	EndIf;
	
	Return Result;
	
EndFunction

// Dump saves files downloaded from external repositories with their descriptions.
//
// Parameters:
//	RequestHandler - CatalogRef.ExternalRequestHandlers - ref to external request handler;
//  CheckoutSHA - String - event identifier;
// 	Data - ValueTable - downloaded files metadata:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the file for the remote repository (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - file operation date;
// * CheckoutSHA - String - сommit SHA;
// * ErrorInfo - Undefined, ErrorInfo - file download error;
//
Procedure Dump( Val RequestHandler, Val CheckoutSHA, Val Data ) Export
	
	Var Message;

	Message = Metadata.InformationRegisters.RemoteFiles.FullName();
	Message = Logs.AddPrefix( Message, CheckoutSHA );
	
	Try
		
		InformationRegisters.RemoteFiles.SaveData( RequestHandler, CheckoutSHA, Data );
		
	Except
		
		Logs.Error( Logs.Events().SAVE_DATA, Message, RequestHandler );
		
		Raise;
		
	EndTry;
	
	Logs.Info( Logs.Events().SAVE_DATA, Message, RequestHandler );	
	
EndProcedure

#EndRegion

#Region Private

// FileMetadata returns an empty table for files metadata downloaded from external repositories.
// 
// Returns:
//	ValueTable - downloaded files metadata:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the file for the remote repository (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - file operation date;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - Undefined, ErrorInfo - file download error;
//
Function FileMetadata()
	
	Var Result;

	Result = New ValueTable();
	Result.Columns.Add( "RAWFilePath", New TypeDescription("String") );
	Result.Columns.Add( "FileName", New TypeDescription("String") );
	Result.Columns.Add( "FilePath", New TypeDescription("String") );
	Result.Columns.Add( "BinaryData", New TypeDescription("BinaryData") );
	Result.Columns.Add( "Action", New TypeDescription("String") );
	Result.Columns.Add( "Date", New TypeDescription("Date") );
	Result.Columns.Add( "CommitSHA", New TypeDescription("String") );
	Result.Columns.Add( "ErrorInfo" );

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

Procedure AddFileMetadata( FileMetadata, Val Commit, Val FileName, Val FilePath, Val Action )
	
	Var NewFile;
	
	NewFile = FileMetadata.Add();
	NewFile.FileName = FileName;
	NewFile.FilePath = FilePath;
	NewFile.Action = Action;
	NewFile.Date = Commit.Get( "timestamp" );
	NewFile.CommitSHA = Commit.Get( "id" );
	
EndProcedure

Procedure AddCompiledFiles( FileMetadata, Val Commit )
	
	Var FileActions;
	Var FilePaths;
	
	FileActions = GitLabAPI.GetFileActions();
	
	For Each Action In FileActions Do

		FilePaths = Commit.Get( Action );

		For Each FilePath In FilePaths Do
			
			If NOT ( HasExtension(FilePath, "EPF") OR HasExtension(FilePath, "ERF") ) Then
				
				Continue;

			EndIf;

			AddFileMetadata( FileMetadata, Commit, "", FilePath, Action );

		EndDo;

	EndDo;
	
EndProcedure

// AddRoutingFiles adds a description of the routing settings files.
// 
// Parameters:
// 	FileMetadata - ValueTable - downloaded files metadata:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the file for the remote repository (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - file operation date;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - Undefined, ErrorInfo - file download error;
// 	Commits - Map - deserialized commits from the request body;
//
Procedure AddRoutingFiles( FileMetadata, Val Commits )
	
	Var FilePath;
	
	FilePath = ServicesSettings.RoutingFileName();
	
	For Each Commit In Commits Do
		
		AddFileMetadata( FileMetadata, Commit, FilePath, FilePath, "" );
		
	EndDo;

EndProcedure

Procedure AppendRAWFilePath( FileMetadata, Val ProjectId )
	
	For Each Record In FileMetadata Do
		
		Record.RAWFilePath = GitLabAPI.GetRAWFilePath( Record.FilePath, ProjectId, Record.CommitSHA );
				
	EndDo;
	
EndProcedure

Function SliceLastByAction( Val FileMetadata, Val Action )
	
	Var FilePaths;
	Var Filter;
	Var LastFile;
	Var Result;
	
	Result = FileMetadata.CopyColumns();
	
	FilePaths = CommonUseClientServer.CollapseArray( FileMetadata.UnloadColumn("FilePath") );
	
	If ( NOT ValueIsFilled(FilePaths) ) Then
		
		Return Result;
	
	EndIf;
	
	FileMetadata.Sort( "Date Desc" );
	
	Filter = New Structure( "Action, FilePath", Action, "" );
		
	For Each FilePath In FilePaths Цикл

		Filter.FilePath = FilePath;
		
		LastFile = FileMetadata.FindRows( Filter );

		If ( ValueIsFilled(LastFile) ) Then

			FillPropertyValues( Result.Add(), LastFile[0] );
								
		EndIf;
		
	EndDo;

	Return Result;
	
EndFunction

Procedure AppendBinaryData( FilesMetadata, Val ConnectionParams )

	Var RAWFilePaths;
	Var DownloadedFiles;
	Var FileMetadata;

	RAWFilePaths = FilesMetadata.UnloadColumn( "RAWFilePath" );
	
	DownloadedFiles = GitlabAPI.GetRAWFiles( ConnectionParams, RAWFilePaths );
	
	For Each File In DownloadedFiles Do
			
		FileMetadata = FilesMetadata.Find( File.RAWFilePath, "RAWFilePath" );
		
		FillPropertyValues( FileMetadata, File );

	EndDo;

EndProcedure

#EndRegion