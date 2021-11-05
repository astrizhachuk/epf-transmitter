#Region Public

// FindByToken returns search result from registered webhooks.
// 
// Parameters:
// 	Token - String - secret token;
// 	
// Returns:
// 	CatalogRef.Webhooks - search result from registered webhooks or blank ref;
//
Function FindByToken( Val Token ) Export
	
	Var Webhook;
	
	Webhook = Catalogs.Webhooks.FindByToken( Token );

	Return ?( ValueIsFilled(Webhook), Webhook[0], Catalogs.Webhooks.EmptyRef() );
	
EndFunction

// LoadEventsHistory loads data from the event log into the object by filter.
// 
// Parameters:
// 	Object - CatalogObject.Webhooks - target object; 
// 	Destination - String - tabular section name;
// 	Filter - Structure - event log filter (see global context UnloadEventLog);
// 	RecordsLoaded - Number - (returned) number of loaded records;
//
Procedure LoadEventsHistory( Object, Val Destination, Val Filter, RecordsLoaded ) Export
	
	If ( NOT Filter.Property( "Data" ) ) Then
		
		Filter.Insert( "Data", Object.Ref );
		
	EndIf;
	
	Catalogs.Webhooks.LoadEventsHistory( Object, Destination, Filter, RecordsLoaded );
	
EndProcedure

// SaveQueryData saves the GitLab request data deserialized from JSON to the infobase.
// 
// Parameters:
// 	Webhook - CatalogRef.Webhooks - a ref to webhook;
//  CheckoutSHA - String - event identifier (commit SHA);
// 	QueryData - Map - request body deserialized from JSON;
//
Procedure SaveQueryData( Val Webhook, Val CheckoutSHA, Val QueryData ) Export
	
	Save( "QueryData", Webhook, CheckoutSHA, QueryData );
		
EndProcedure

// SaveRemoteFiles saves remote files from the GitLab with its descriptions.
// 
// Parameters:
//	Webhook - CatalogRef.Webhooks - a ref to webhook;
//  CheckoutSHA - String - event identifier (commit SHA);
// 	RemoteFiles - ValueTable - description:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the file in remote repository (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CheckoutSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
Procedure SaveRemoteFiles( Val Webhook, Val CheckoutSHA, Val RemoteFiles ) Export
	
	Save( "RemoteFiles", Webhook, CheckoutSHA, RemoteFiles );
		
EndProcedure

// LoadQueryData loads from the infobase previously saved the GitLab request data deserialized from JSON.
// 
// Parameters:
//	Webhook - CatalogRef.Webhooks - a ref to webhook;
//  CheckoutSHA - String - event identifier (commit SHA);
//
// Returns:
// 	Map - request body deserialized from JSON;
//
Function LoadQueryData( Val Webhook, Val CheckoutSHA ) Export
	
	Var Record;
	
	Record = New Structure();
	Record.Insert( "Webhook", Webhook );
	Record.Insert( "CheckoutSHA", CheckoutSHA );
	
	Return Load( "QueryData", Record );
	
EndFunction

// LoadRemoteFiles loads from the infobase previously saved remote files with their description.
// 
// Parameters:
//	Webhook - CatalogRef.Webhooks - a ref to webhook;
//  CheckoutSHA - String - event identifier (commit SHA);
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
Function LoadRemoteFiles( Val Webhook, Val CheckoutSHA ) Export
	
	Var Record;
	
	Record = New Structure();
	Record.Insert( "Webhook", Webhook );
	Record.Insert( "CheckoutSHA", CheckoutSHA );
	
	Return Load( "RemoteFiles", Record );
	
EndFunction

#EndRegion

#Region Private

Procedure Save( Val RegisterName, Val Webhook, Val CheckoutSHA, Val Data )
	
	Var RecordSet;
	Var Record;

	Data = New ValueStorage( Data );

	RecordSet = InformationRegisters[ RegisterName ].CreateRecordSet();
	RecordSet.Filter.Webhook.Set( Webhook );
	RecordSet.Filter.CheckoutSHA.Set( CheckoutSHA );
	RecordSet.Read();

	Record = ?( RecordSet.Count() = 0, RecordSet.Add(), RecordSet[0] );		
	
	Record.Webhook = Webhook;
	Record.CheckoutSHA = CheckoutSHA;
	Record.Data = Data;
	
	RecordSet.Write();

EndProcedure

Function Load( Val RegisterName, Val RecordKey )
	
	Var Result;
	Var RecordManager;
	
	If ( RegisterName = "RemoteFiles" ) Then
		
		Result = GitLab.RemoteFilesEmpty();
	
	Else
		
		Result = New Map();
		
	EndIf;

	RecordManager = InformationRegisters[ RegisterName ].CreateRecordManager();
	FillPropertyValues( RecordManager, RecordKey );
	
	RecordManager.Read();

	If RecordManager.Selected() Then
		
		Result = RecordManager[ "Data" ].Get();
		
	EndIf;
	
	Return Result;
	
EndFunction

#EndRegion
