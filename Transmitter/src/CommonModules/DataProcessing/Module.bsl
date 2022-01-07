#Region Public

Function Start( Val RequestHandler, Val RequestData, Val Files = Undefined, Val DumpData = True ) Export

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
	BackgroundJobParams.Add( DumpData );
	
	BackgroundJob = Undefined;
	
	Try
		
		BackgroundJob = BackgroundJobs.Execute( "DataProcessing.Run", BackgroundJobParams, CheckoutSHA );
		
	Except
		
		Message = Logs.AddPrefix( ErrorProcessing.DetailErrorDescription(ErrorInfo()), CheckoutSHA );
		Logs.Error( Logs.Events().JOB_RUNNING, Message, RequestHandler );
		
		Raise;
		
	EndTry;
	
	Return BackgroundJob;
	
EndFunction

Function Manual( Val RequestHandler, Val CheckoutSHA ) Export
	
	Var Message;
	
	Data = ExternalRequests.GetRequestBody( RequestHandler, CheckoutSHA );
	Files = RemoteFiles.GetFromIB( RequestHandler, CheckoutSHA );
	
	If ( Data = Undefined ) Then
	
		Message = Logs.AddPrefix( Logs.Messages().NO_REQUEST_BODY, CheckoutSHA );
		Logs.Error( Logs.Events().LOAD_DATA, Message, RequestHandler );
		
		Return Undefined;
		
	EndIf;
	
	If ( Files = Undefined ) Then
	
		Message = Logs.AddPrefix( Logs.Messages().NO_SEND_DATA, CheckoutSHA );
		Logs.Error( Logs.Events().LOAD_DATA, Message, RequestHandler );
		
		Return Undefined;
		
	EndIf;
	
	BackgroundJob = Start( RequestHandler, Data, Files, False );
	
	Return BackgroundJob;
	
EndFunction

#EndRegion

#Region Internal

Procedure Run( Val RequestHandler, Val CheckoutSHA, Val RequestData, Val Files, Val DumpData ) Export

	Var Project;
	Var ConnectionParams;
	Var FilesToSend;
	Var Jobs;
	
	Project = ExternalRequests.GetProjectOrRaise( RequestData );

	ConnectionParams = GitLabAPI.GetConnectionParams( Project.ServerURL );
	
	If ( Files = Undefined ) Then
		
		Files = RemoteFiles.GetFromRemoteVCS( ConnectionParams, RequestData );
		LogDownloadResult( Files, RequestHandler, CheckoutSHA );
		
		// TODO логирование загрузки файлов куцое, вернуться сюда при создании фунциональных тестов
		// возможно, что сообщение надо опустить ниже перед SendFile и согласовать с LogDownloadResult
		Message = Logs.AddPrefix( "???", CheckoutSHA );
		Logs.Info( Logs.Events().DOWNLOAD_FILE, Message, RequestHandler );
	
		ExternalRequests.AppendRoutingSettings( RequestData, Files );
	
	EndIf;
	
	AssertFiles( Files, RequestHandler, CheckoutSHA );
	
	If ( DumpData ) Then
		
		ExternalRequests.Dump( RequestHandler, CheckoutSHA, RequestData );
		RemoteFiles.Dump( RequestHandler, CheckoutSHA, Files );
		
	EndIf;
	
	FilesToSend = Routing.GetFilesByRoutes( RequestData, Files );
	LogRoutingResult( FilesToSend, RequestHandler, CheckoutSHA );
	
	FilesToSend = RemoveUnroutedFiles( FilesToSend );

	Jobs = Endpoints.BackgroundSendFiles( FilesToSend );
	LogRunBackgroundSendFiles( Jobs, RequestHandler, CheckoutSHA );
	
EndProcedure

#EndRegion

#Region Private

Procedure AssertFiles( Val Files, Val RequestHandler, Val CheckoutSHA )
	
	Var  Message;
	
	If ( NOT ValueIsFilled(Files) ) Then

		Message = Logs.AddPrefix( Logs.Messages().NO_SEND_DATA, CheckoutSHA );
		Logs.Error( Logs.Events().LOAD_DATA, Message, RequestHandler );
		
		Raise Message;
		
	EndIf;
	
EndProcedure

Procedure LogDownloadResult( Val Files, Val RequestHandler, Val CheckoutSHA )
	
	Var Message;
	
	For Each FileMetadata In Files Do
			
		If ( NOT IsBlankString(FileMetadata.ErrorInfo) ) Then
			
			Message = Logs.AddPrefix( FileMetadata.ErrorInfo, CheckoutSHA );
			Logs.Error( Logs.Events().DOWNLOAD_FILE, Message, RequestHandler );
			
		EndIf;
				
	EndDo;
	
EndProcedure

Procedure LogRoutingResult( Val Files, Val RequestHandler, Val CheckoutSHA )
	
	Var Message;
	
	For Each File In Files Do
			
		If ( File.Routes = Undefined ) Then
			
			Message = Logs.AddPrefix( File.CommitSHA + ": " + Logs.Messages().ROUTE_MISSING, CheckoutSHA );
			Logs.Error( Logs.Events().DATA_PROCESSING, Message, RequestHandler );
			
		EndIf;
				
	EndDo;
	
EndProcedure

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

Procedure LogRunBackgroundSendFiles( Val Jobs, Val RequestHandler, Val CheckoutSHA )

	Var Created;
	Var Message;
	
	Created = 0;
	
	For Each Job In Jobs Do
			
		If ( Job.BackgroundJob <> Undefined ) Then
			
			Created = Created + 1;

		EndIf;
		
		If ( Job.ErrorInfo <> Undefined ) Then
			
			Message = Logs.AddPrefix( ErrorProcessing.DetailErrorDescription(Job.ErrorInfo), CheckoutSHA );			
			Logs.Error( Logs.Events().DATA_PROCESSING, Message, RequestHandler );
			
		EndIf;
				
	EndDo;
	
	Message = StrTemplate( Logs.Messages().UPLOAD_FILE_JOB_CREATED, Created );
	Message = Logs.AddPrefix( Message, CheckoutSHA );			
	Logs.Info( Logs.Events().DATA_PROCESSING, Message, RequestHandler );
	
EndProcedure

#EndRegion
