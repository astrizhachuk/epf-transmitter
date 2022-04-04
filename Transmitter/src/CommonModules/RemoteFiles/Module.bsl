#Region Public

// GetFromRemoteVCS returns downloaded files from external repositories with metadata.
// 
// Parameters:
// 	ExternalRequest - DataProcessorObject.ExternalRequest - external request instance;
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
Function GetFromRemoteVCS( Val ExternalRequest ) Export
	
	Var Result;
	
	Result = FileMetadata();
	
	For Each ModifiedFile In ExternalRequest.GetModifiedFiles() Do
		
		AddFileMetadata( Result, ModifiedFile, "modified" );

	EndDo;
	
	Result = SliceLastByAction( Result, "modified" );
	
	AddRoutingMetadata( Result, ExternalRequest.GetCommits() );
	
	AppendRAWFilePath( Result, ExternalRequest.GetProjectId() );
	
	DownloadFromGitLab( Result, ExternalRequest.GetServerURL() );	

	Return Result;
	
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

	Var Filter;
	
	Filter = New Structure();
	Filter.Insert( "RequestHandler", RequestHandler );
	Filter.Insert( "CheckoutSHA", CheckoutSHA );
	
	Return InformationRegisters.RemoteFiles.Get(Filter).Data.Get();
	
EndFunction

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

Procedure AddFileMetadata( FileMetadata, Val File, Val Action )
	
	Var NewFile;
	
	NewFile = FileMetadata.Add();

	If File.Property("FileName") Then
		NewFile.FileName = File.FileName;
	Else
		NewFile.FileName = "";
	EndIf;
	NewFile.FilePath = File.FilePath;
	NewFile.Action = Action;
	NewFile.Date = File.Date;
	NewFile.CommitSHA = File.Id;
	
EndProcedure

// AddRoutingMetadata adds a description of the routing files.
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
// 	Commits - DataProcessorTabularSection.ExternalRequest.Commits - commits description;
//
Procedure AddRoutingMetadata( FileMetadata, Val Commits )
	
	Var File;
	Var FilePath;
	
	FilePath = ServicesSettings.GetRoutingFileName();
	
	For Each Commit In Commits Do
		
		File = New Structure();
		File.Insert("Id", Commit.Id );
		File.Insert("Date", Commit.Date );
		File.Insert("FileName", FilePath );
		File.Insert("FilePath", FilePath );

		AddFileMetadata( FileMetadata, File, "" );

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

Procedure DownloadFromGitLab( FilesMetadata, Val ServerURL )

	Var RAWFilePaths;
	Var Files;
	Var FileMetadata;

	RAWFilePaths = FilesMetadata.UnloadColumn( "RAWFilePath" );
	
	Files = GitlabAPI.GetRAWFiles( GitLabAPI.GetConnectionParams(ServerURL), RAWFilePaths );
	
	For Each File In Files Do
			
		FileMetadata = FilesMetadata.Find( File.RAWFilePath, "RAWFilePath" );
		
		FillPropertyValues( FileMetadata, File );

	EndDo;

EndProcedure

#EndRegion