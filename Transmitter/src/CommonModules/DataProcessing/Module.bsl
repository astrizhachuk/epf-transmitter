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
	
	Project = ExternalRequests.GetProjectOrRaise( RequestData );

	ConnectionParams = GitLabAPI.GetConnectionParams( Project.ServerURL );
	
	If ( Files = Undefined ) Then
		
		Files = RemoteFiles.GetFromRemoteVCS( ConnectionParams, RequestData );
		
		// TODO Возможно дублирование обработки ошибки, чекнуть после рефакторинга роута
		LogDowloadErrors(Files, RequestHandler, CheckoutSHA );
		
		// TODO логирование загрузки файлов куцое, вернуться сюда при создании фунциональных тестов
		// возможно, что сообщение надо опустить ниже перед SendFile и согласовать с LogDowloadErrors
		Message = Logs.AddPrefix( "???", CheckoutSHA );
		Logs.Info( Logs.Events().DOWNLOAD_FILE, Message, RequestHandler );
	
	EndIf;
	
	AssertFiles( Files, RequestHandler, CheckoutSHA );
	
	ExternalRequests.AppendRoutingSettings( RequestData, Files );
	
	//Files = Routing.GetFilesByRoutes( RequestData, Files );
	
	// TODO добавить обработку отсутсвия маршрутов

	If ( DumpData ) Then
		
		ExternalRequests.Dump( RequestHandler, CheckoutSHA, RequestData );
		RemoteFiles.Dump( RequestHandler, CheckoutSHA, Files );
		
	EndIf;

	// Send
	Stab=new array;
	
//	CommitSHA = TIME;
//	
//	EndpointURL = URL + "/epf/uploadFile";
//	Routes = New Array;
//	Routes.Add(EndpointURL);
//	Routes.Add(EndpointURL);
//
//	NotFoundURL = "http://mockserver:1080/NotFound";
//	NotFoundStatusCode = 404;
//	RoutesHasError = New Array;
//	RoutesHasError.Add(NotFoundURL);
//
//	File1 = NewFile(CommitSHA, FileName, RoutesHasError);
//	File2 = NewFile(CommitSHA, FileName, Routes);
//	Files = New Array;
//	Files.Add(File1);
//	Files.Add(File2);	
	
	Jobs = Endpoints.BackgroundSendFiles( Stab );
//	LogRunBackgroundSendFiles( Jobs, RequestHandler, CheckoutSHA );
	
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

Procedure LogDowloadErrors( Val Files, Val RequestHandler, Val CheckoutSHA )
	
	Var Message;
	
	For Each FileMetadata In Files Do
			
		If ( NOT IsBlankString(FileMetadata.ErrorInfo) ) Then
			
			Message = Logs.AddPrefix( FileMetadata.ErrorInfo, CheckoutSHA );
			Logs.Error( Logs.Events().DOWNLOAD_FILE, Message, RequestHandler );
			
		EndIf;
				
	EndDo;
	
EndProcedure

#EndRegion
