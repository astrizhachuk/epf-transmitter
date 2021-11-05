#Region Internal

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
	
	Result = New ValueTable();
	Result.Columns.Add( "RAWFilePath", New TypeDescription("String") );
	Result.Columns.Add( "FileName", New TypeDescription("String") );
	Result.Columns.Add( "FilePath", New TypeDescription("String") );
	Result.Columns.Add( "BinaryData", New TypeDescription("BinaryData") );
	Result.Columns.Add( "Action", New TypeDescription("String") );
	Result.Columns.Add( "Date", New TypeDescription("Date") );
	Result.Columns.Add( "CommitSHA", New TypeDescription("String") );
	Result.Columns.Add( "ErrorInfo", New TypeDescription("String") );

	Return Result;
	
EndFunction

// ListFileActions returns a list of possible actions on files in accordance with the GitLab REST API.
// 
// Returns:
// 	Array - "added", "modified", "removed";
//
Function ListFileActions() Export
	
	Var Result;
	
	Result = New Array();
	Result.Add( "added" );
	Result.Add( "modified" );
	Result.Add( "removed" );

	Return Result;
	
EndFunction

#EndRegion
