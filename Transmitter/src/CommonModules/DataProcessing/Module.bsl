#Region Public

Function Start( Val RequestHandler, Val RequestData, Val Files = Undefined, Val Dump = True ) Export

	Var Message;
	Var CheckoutSHA;
	Var BackgroundJobParams;
	Var BackgroundJob;
	
	CheckoutSHA = ExternalRequests.GetCheckoutSHA( RequestData );
	
	BackgroundJobParams = New Array();
	BackgroundJobParams.Add( RequestHandler );
	BackgroundJobParams.Add( CheckoutSHA );
	BackgroundJobParams.Add( RequestData );
	BackgroundJobParams.Add( Files );
	BackgroundJobParams.Add( Dump );
	
	BackgroundJob = Undefined;
	
	Try
		
		BackgroundJob = BackgroundJobs.Execute( "DataProcessing.Run", BackgroundJobParams, CheckoutSHA );
		
	Except
		
		Message = ErrorProcessing.DetailErrorDescription( ErrorInfo() );
		Logs.Error( Logs.Events().DATA_PROCESSING, Message, CheckoutSHA, RequestHandler );
		
		Raise;
		
	EndTry;
	
	Return BackgroundJob;
	
EndFunction

Function Manual( Val RequestHandler, Val CheckoutSHA ) Export
	
	Var Data;
	Var Files;

	Data = ExternalRequests.GetFromIB( RequestHandler, CheckoutSHA );
	Files = RemoteFiles.GetFromIB( RequestHandler, CheckoutSHA );
	
	If ( Data = Undefined ) Then
	
		Logs.Error( Logs.Events().DATA_PROCESSING, Logs.Messages().NO_REQUEST_DATA, CheckoutSHA, RequestHandler );
		
		Return Undefined;
		
	EndIf;
	
	If ( Files = Undefined ) Then
	
		Logs.Error( Logs.Events().DATA_PROCESSING, Logs.Messages().NO_UPLOAD_DATA, CheckoutSHA, RequestHandler );
		
		Return Undefined;
		
	EndIf;
	
	Return Start( RequestHandler, Data, Files, False );
	
EndFunction

// GetBackgroundsByCommit returns an array of BackgroundJob objects containing the commit in the BackgroundJob key.
// 
// Parameters:
// 	CommitSHA - String - сommit SHA;
// 	
// Returns:
// 	Array of BackgroundJob - an array of backgrounds;
//
Function GetBackgroundsByCommit( Val CommitSHA ) Export
	
	Var SendFileJobs;
	Var Result;
	
	SetPrivilegedMode(True);
	
	Result = BackgroundJobs.GetBackgroundJobs( FilterDataProcessingRun(CommitSHA) );
	SendFileJobs = Backgrounds.GetByKeyPrefix( FilterEndpointsSendFile(), CommitSHA + "|" );
	CommonUseClientServer.SupplementArray( Result, SendFileJobs );
	
	Return Result;
	
EndFunction

#EndRegion

#Region Internal

Procedure Run( Val RequestHandler, Val CheckoutSHA, Val RequestData, Val Files, Val Dump ) Export

	Var Project;
	Var ConnectionParams;
	Var FilesToSend;
	Var Jobs;
	
	Project = ExternalRequests.GetProjectOrRaise( RequestData );

	// TODO теперь видно, что надо пробросить URL как можно ближе к загрузке и вызывать GetConnectionParams уже там,
	// так как гитлаб кроме как в GetFromRemoteVCS не используется
	ConnectionParams = GitLabAPI.GetConnectionParams( Project.ServerURL );
	
	If ( Files = Undefined ) Then
		
		Files = RemoteFiles.GetFromRemoteVCS( ConnectionParams, RequestData );
		
		LogDownloadResult( Files, RequestHandler, CheckoutSHA );
		
		Files = GetFilesWithoutErrors( Files );
	
		// TODO AppendRoutingSettings переместить в GetFromRemoteVCS??? вай нот?
		ExternalRequests.AppendRoutingSettings( RequestData, Files );
	
	EndIf;
	
	AssertFiles( Files, RequestHandler, CheckoutSHA );
	
	If ( Dump ) Then
		
		Dump( "ExternalRequests", RequestHandler, CheckoutSHA, RequestData );
		Dump( "RemoteFiles", RequestHandler, CheckoutSHA, Files );
		
	EndIf;
	
	FilesToSend = Routing.GetFilesByRoutes( RequestData, Files );
	
	LogRoutingResult( FilesToSend, RequestHandler, CheckoutSHA );
	
	FilesToSend = RemoveUnRoutedFiles( FilesToSend );

	Jobs = Endpoints.BackgroundSendFiles( FilesToSend );
	
	LogRunBackgroundSendFiles( Jobs, RequestHandler, CheckoutSHA );
	
EndProcedure

#EndRegion

#Region Private

Procedure AssertFiles( Val Files, Val RequestHandler, Val CheckoutSHA )
	
	If ( NOT ValueIsFilled(Files) ) Then

		Raise Logs.Error( Logs.Events().DATA_PROCESSING, Logs.Messages().NO_UPLOAD_DATA, CheckoutSHA, RequestHandler );
		
	EndIf;
	
EndProcedure

Procedure LogDownloadResult( Val FilesMetadata, Val RequestHandler, Val CheckoutSHA )
	
	Var ErrorText;
	
	For Each FileMetadata In FilesMetadata Do
			
		If ( FileMetadata.ErrorInfo = Undefined ) Then
			
			Continue;
			
		EndIf;
		
		ErrorText = ErrorProcessing.DetailErrorDescription( FileMetadata.ErrorInfo );
		
		Logs.Error( Logs.Events().DATA_PROCESSING, ErrorText, CheckoutSHA, RequestHandler );
		
	EndDo;

EndProcedure

Procedure LogRoutingResult( Val Files, Val RequestHandler, Val CheckoutSHA )
	
	Var Message;
	
	For Each File In Files Do
			
		If ( File.Routes = Undefined ) Then
			
			Message = File.CommitSHA + ": " + Logs.Messages().NO_ROUTE;
			Logs.Error( Logs.Events().DATA_PROCESSING, Message, CheckoutSHA, RequestHandler );
			
		EndIf;
				
	EndDo;
	
EndProcedure

Procedure LogRunBackgroundSendFiles( Val Jobs, Val RequestHandler, Val CheckoutSHA )

	Var Created;
	Var Message;
	
	Created = 0;
	
	For Each Job In Jobs Do
			
		If ( Job.BackgroundJob <> Undefined ) Then
			
			Created = Created + 1;

		EndIf;
		
		If ( Job.ErrorInfo <> Undefined ) Then
			
			Message = ErrorProcessing.DetailErrorDescription( Job.ErrorInfo );			
			Logs.Error( Logs.Events().DATA_PROCESSING, Message, CheckoutSHA, RequestHandler );
			
		EndIf;
				
	EndDo;
	
	Message = StrTemplate( Logs.Messages().UPLOAD_FILE_JOB, Created );
	Logs.Info( Logs.Events().DATA_PROCESSING, Message, CheckoutSHA, RequestHandler );
	
EndProcedure

Function GetFilesWithoutErrors( Val FilesMetadata )
	
	Var FileWithoutError;
	Var Result;
	
	Result = FilesMetadata.CopyColumns();
	
	For Each FileMetadata In FilesMetadata Do
			
		If ( FileMetadata.ErrorInfo <> Undefined ) Then
			
			Continue;
			
		EndIf;
		
		FileWithoutError = Result.Add();
		FillPropertyValues( FileWithoutError, FileMetadata );
		
	EndDo;
	
	Return Result;

EndFunction

Function RemoveUnroutedFiles( Val Files )
	
	Var Result;
	
	Result = New Array();
	
	For Each File In Files Do
			
		If ( File.Routes = Undefined ) Then
			
			Continue;
			
		EndIf;
		
		Result.Add( File );
				
	EndDo;	
	
	Return Result;
	
EndFunction

Procedure Dump( Val Name, Val RequestHandler, Val CheckoutSHA, Val Data )
	
	Var Message;
	
	Try

		InformationRegisters[Name].SaveData( RequestHandler, CheckoutSHA, Data );
		
	Except
		
		Message = Logs.Messages().DUMP_ERROR;
		Message = StrTemplate( Message, Name, ErrorProcessing.DetailErrorDescription(ErrorInfo()) );
		Logs.Error( Logs.Events().DATA_PROCESSING, Message, CheckoutSHA, RequestHandler );	
		
		Raise;
		
	EndTry;

	Message = Metadata.InformationRegisters[Name].FullName() + ": " + Logs.Messages().DUMPED;
	Logs.Info( Logs.Events().DATA_PROCESSING, Message, CheckoutSHA, RequestHandler );
	
EndProcedure

#Region Filters

// FilterDataProcessingRun returns a filter for selecting background jobs that process
// an incoming request from external storage. 
// 
// Parameters:
// 	Key - String - job key;
// 	
// Returns:
// 	Structure - filter:
// * MethodName - String - method name from a non-global module;
// * Key - String - job key;
//
Function FilterDataProcessingRun( Val Key )
	
	Return New Structure( "MethodName, Key", "DataProcessing.Run", Key );
	
EndFunction

// FilterEndpointsSendFile returns a filter for selecting background jobs that send files to infobases.
// 
// Returns:
// 	Structure - filter:
// * MethodName - String - method name from a non-global module;
//
Function FilterEndpointsSendFile()
	
	Return New Structure( "MethodName", "Endpoints.SendFile" );
	
EndFunction

#EndRegion

#EndRegion
