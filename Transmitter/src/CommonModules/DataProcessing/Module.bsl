#Region Public

// @Deprecated - просто шляпа какая-то

// RunBackgroundJob prepares and run background job to process "webhooked" or saved GitLab server request.
// 
// Parameters:
//	Webhook - CatalogRef.ExternalRequestHandlers - ref to external request handler;
// 	DataSource - Map, String - GitLab request body deserialized from JSON or "checkout_sha" of previously saved request;
//
// Returns:
// 	Undefined, BackgroundJob - created BackgroundJob or Undefined if there were errors;
//
Function RunBackgroundJob( Val Webhook, Val DataSource ) Export

	Var QueryData;
	Var CheckoutSHA;

	Var BackgroundJobParams;
	Var BackgroundJob;

	Var Message;
	
	EVENT_MESSAGE = NStr( "ru = 'Core.ОбработкаДанных';en = 'Core.DataProcessing'" );
	
	JOB_WAS_STARTED_MESSAGE = NStr( "ru = 'фоновое задание уже запущено.';en = 'background job is already running.'" );
	JOB_RUNNING_ERROR_MESSAGE = NStr( "ru = 'ошибка запуска задания обработки данных:';
										|en = 'an error occurred while starting the job:'" );									
	
	Message = "";
	
	QueryData = Undefined;
	CheckoutSHA = "";
	
	FillProcessingData( CheckoutSHA, QueryData, Message, DataSource );

	BackgroundJob = Undefined;
	
	If ( NOT IsBlankString(Message) ) Then
	
		Logs.Error( EVENT_MESSAGE, Message, Webhook );
		
		Return BackgroundJob;
	
	EndIf;
	
	If ( BackgroundJobsExt.IsActive(CheckoutSHA) ) Then
		
		Message = Logs.AddPrefix( JOB_WAS_STARTED_MESSAGE, CheckoutSHA );
		Logs.Warn( EVENT_MESSAGE, Message, Webhook );
		
		Return BackgroundJob;
		
	EndIf;
	
	BackgroundJobParams = New Array();
	BackgroundJobParams.Add( WebhookParams( Webhook, CheckoutSHA ) );
	BackgroundJobParams.Add( QueryData );

	Try
		
		BackgroundJob = BackgroundJobs.Execute( "DataProcessing.Run", BackgroundJobParams, CheckoutSHA );
		
	Except
		
		Message = Logs.AddPrefix( JOB_RUNNING_ERROR_MESSAGE, CheckoutSHA );
		Message = Message + Chars.LF + ErrorProcessing.DetailErrorDescription( ErrorInfo() );
		Logs.Error( EVENT_MESSAGE, Message, Webhook );
		
	EndTry;
 
	Return BackgroundJob;
											
EndFunction

#EndRegion

#Region Internal

Procedure Run( Val WebhookParams, Val QueryData ) Export
	
	Var RemoteFiles;
	Var Commits;
	Var Message;
	
	EVENT_MESSAGE_BEGIN = NStr( "ru = 'Core.ОбработкаДанных.Начало';en = 'Core.DataProcessing.Begin'" );
	EVENT_MESSAGE_END = NStr( "ru = 'Core.ОбработкаДанных.Окончание';en = 'Core.DataProcessing.End'" );
	
	DATA_PROCESSING_MESSAGE = NStr( "ru = 'обработка данных...';en = 'data processing...'" );
	NO_DATA_MESSAGE = NStr( "ru = 'нет данных для отправки.';en = 'no data to send.'" );
	
	Message = Logs.AddPrefix( DATA_PROCESSING_MESSAGE, WebhookParams.CheckoutSHA );
	Logs.Info( EVENT_MESSAGE_BEGIN, Message, WebhookParams.ExternalRequestHandler );
	
	RemoteFiles = Undefined;
	
	PrepareData( WebhookParams, QueryData, RemoteFiles );
	
	If ( NOT ValueIsFilled(QueryData) OR NOT ValueIsFilled(RemoteFiles) ) Then

		Message = Logs.AddPrefix( NO_DATA_MESSAGE, WebhookParams.CheckoutSHA );
		Logs.Info( EVENT_MESSAGE_END, Message, WebhookParams.ExternalRequestHandler );
		
		Return;
		
	EndIf;
	
	Commits = QueryData.Get( "commits" );
	RemoteFiles = Routing.FilesByRoutes( RemoteFiles, Commits );
			
	SendFiles( WebhookParams, RemoteFiles );

	Logs.Info( EVENT_MESSAGE_END, Message, WebhookParams.ExternalRequestHandler );
	
EndProcedure

#EndRegion

#Region Private

Function WebhookParams( Val Webhook, Val CheckoutSHA )
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "ExternalRequestHandler", Webhook );
	Result.Insert( "CheckoutSHA", CheckoutSHA );
	
	Return Result;
	
EndFunction

Procedure FillProcessingData( CheckoutSHA, QueryData, Message, Val DataSource )
	
	CHECKOUT_SHA_MISSING_MESSAGE = NStr( "ru = 'отсутствует ""checkout_sha"".';
									|en = '""checkout_sha"" is missing.'" );
	UNSUPPORTED_FORMAT_MESSAGE = NStr( "ru = 'неподдерживаемый формат данных.';en = 'unsupported data format.'" );
	
	If ( TypeOf(DataSource) = Type("String") ) Then
		
		CheckoutSHA = DataSource;
		QueryData = Undefined;
	
	ElsIf ( TypeOf(DataSource) = Type("Map") ) Then
		
		CheckoutSHA = DataSource.Get( "checkout_sha" );
		QueryData = DataSource;
		
		If ( CheckoutSHA = Undefined ) Then
			
			Message = CHECKOUT_SHA_MISSING_MESSAGE;
			
		EndIf;

	Else
		
		Message = UNSUPPORTED_FORMAT_MESSAGE;
		
	EndIf;
	
EndProcedure

Procedure PrepareData( Val WebhookParams, QueryData, RemoteFiles )

	Var ProjectParams;
	Var Commits;
	Var Message;
	
	EVENT_MESSAGE_BEGIN = NStr( "ru = 'Core.ПодготовкаДанных.Начало';en = 'Core.DataPreparation.Begin'" );
	EVENT_MESSAGE = NStr( "ru = 'Core.ПодготовкаДанных';en = 'Core.DataPreparation'" );
	EVENT_MESSAGE_END = NStr( "ru = 'Core.ПодготовкаДанных.Окончание';en = 'Core.DataPreparation.End'" );
	
	PREPARING_DATA_MESSAGE = NStr( "ru = 'подготовка данных к отправке.';en = 'preparing data for sending.'" );
	LOADING_DATA_MESSAGE = NStr( "ru = 'загрузка ранее сохраненных данных.';en = 'loading previously saved data.'" );
	
	Message = Logs.AddPrefix( PREPARING_DATA_MESSAGE, WebhookParams.CheckoutSHA );
	Logs.Info( EVENT_MESSAGE_BEGIN, Message, WebhookParams.ExternalRequestHandler );

	If ( QueryData <> Undefined ) Then
		
		ProjectParams = GitLab.ProjectDescription( QueryData );
		Commits = QueryData.Get( "commits" );
		RemoteFiles = GitLab.RemoteFilesWithDescription( WebhookParams.ExternalRequestHandler, Commits, ProjectParams );
		Routing.ExtendQueryDataWithRoutingSettings( Commits, RemoteFiles );
		
		SaveData( WebhookParams, QueryData, RemoteFiles );
		
	Else
		
		Message = Logs.AddPrefix( LOADING_DATA_MESSAGE, WebhookParams.CheckoutSHA );
		Logs.Info( EVENT_MESSAGE, Message, WebhookParams.ExternalRequestHandler );
				
		LoadData( WebhookParams, QueryData, RemoteFiles );
		
	EndIf;

	Message = Logs.AddPrefix( PREPARING_DATA_MESSAGE, WebhookParams.CheckoutSHA );
	Logs.Info( EVENT_MESSAGE_END, Message, WebhookParams.ExternalRequestHandler );
	
EndProcedure

Procedure SendFiles( Val WebhookParams, Val RemoteFiles )
	
	Var DeliveryParams;
	Var JobParams;
	
	Var FilesCounter;
	Var JobsCounter;
	Var JobKey;

	Var Message;
	
	EVENT_MESSAGE = NStr( "ru = 'Core.ОбработкаДанных';en = 'Core.DataProcessing'" );
	GET_FILE_ERROR_MESSAGE = NStr( "ru = 'ошибка получения файла:';en = 'failed to get the file:'" );
	JOB_WAS_STARTED_MESSAGE = NStr( "ru = 'фоновое задание уже запущено.';en = 'background job is already running.'" );
	KEY_MESSAGE = NStr( "ru = 'Ключ: ';en = 'Key: '" );
	FILES_SENT_MESSAGE = NStr( "ru = 'отправляемых файлов: ';en = 'files sent: '" );
	RUNNING_JOBS_MESSAGE = NStr( "ru = 'запущенных заданий: ';en = 'running jobs: '" );
	
	DeliveryParams = Endpoints.GetConnectionParams();
	
	FilesCounter = 0;
	JobsCounter = 0; 
	
	For Each RemoteFile In RemoteFiles Do
		
		If ( NOT IsBlankString(RemoteFile.ErrorInfo) ) Then
			
			Message = Logs.AddPrefix( GET_FILE_ERROR_MESSAGE, WebhookParams.CheckoutSHA );
			Message = Message + Chars.LF + RemoteFile.ErrorInfo;
			Logs.Warn( EVENT_MESSAGE, Message, WebhookParams.ExternalRequestHandler );
			
			Continue;
			
		EndIf;

		FilesCounter = FilesCounter + 1;
		
		For Each URL In RemoteFile.Routes Do
			
			Endpoints.SetURL( DeliveryParams, URL );
			
			JobKey = WebhookParams.CheckoutSHA + "|" + URL + "|" + RemoteFile.FileName;
				
			If ( BackgroundJobsExt.IsActive(JobKey) ) Then
				
				Message = Logs.AddPrefix( JOB_WAS_STARTED_MESSAGE, WebhookParams.CheckoutSHA );
				Message = Message + Chars.LF + KEY_MESSAGE + JobKey;
				Logs.Warn( EVENT_MESSAGE, Message, WebhookParams.ExternalRequestHandler );
				
				Continue;
				
			EndIf;
			
			JobParams = New Array();
			JobParams.Add( RemoteFile.FileName );
			JobParams.Add( RemoteFile.BinaryData );
			JobParams.Add( DeliveryParams );
			JobParams.Add( WebhookParams );
			
			BackgroundJobs.Execute( "Endpoints.SendFile", JobParams, JobKey, WebhookParams.CheckoutSHA );
															
			JobsCounter = JobsCounter + 1;
				
		EndDo;
		
	EndDo;
	
	Message = Logs.AddPrefix( FILES_SENT_MESSAGE + FilesCounter, WebhookParams.CheckoutSHA );
	Logs.Info( EVENT_MESSAGE, Message, WebhookParams.ExternalRequestHandler );
	
	Message = Logs.AddPrefix( RUNNING_JOBS_MESSAGE + JobsCounter, WebhookParams.CheckoutSHA );
	Logs.Info( EVENT_MESSAGE, Message, WebhookParams.ExternalRequestHandler );
	
EndProcedure

Procedure LogAction( Val WebhookParams, Val Action, Val Result = Undefined )
	
	Var Message;
	
	EVENT_MESSAGE = NStr( "ru = 'Core';en = 'Core'" );
	OPERATION_SUCCEEDED_MESSAGE = NStr( "ru = 'операция выполнена успешно.';en = 'the operation was successful.'" );
	OPERATION_FAILED_MESSAGE = NStr( "ru = 'операция не выполнена.';en = 'operation failed.'" );
	
	If ( Result = Undefined OR ValueIsFilled(Result) ) Then
		
		Message = "[" + Action + "]: " + OPERATION_SUCCEEDED_MESSAGE;
		Message = Logs.AddPrefix( Message, WebhookParams.CheckoutSHA );
		Logs.Info( "Core." + Action, Message, WebhookParams.ExternalRequestHandler );
		
	Else

		Message = "[" + Action + "]: " + OPERATION_FAILED_MESSAGE;		
		Message = Logs.AddPrefix( Message, WebhookParams.CheckoutSHA );
		
		If ( TypeOf(Result) = Type("ErrorInfo") ) Then
			
			Message = Message + Chars.LF + ErrorProcessing.DetailErrorDescription( Result );
			
		EndIf;
					
		Logs.Warn( EVENT_MESSAGE + "." + Action, Message, WebhookParams.ExternalRequestHandler );
			
	EndIf;
		
EndProcedure

Procedure LoadData( Val WebhookParams, QueryData, RemoteFiles )

	LOAD_QUERY_MESSAGE = NStr( "ru = 'ЗагрузкаЗапросаИзБазыДанных';en = 'LoadingRequestFromDatabase'" );
	LOAD_FILES_MESSAGE = NStr( "ru = 'ЗагрузкаВнешнихФайловИзБазыДанных';en = 'LoadingFilesFromDatabase'" );
	
	QueryData = Webhooks.LoadQueryData( WebhookParams.ExternalRequestHandler, WebhookParams.CheckoutSHA );
	LogAction( WebhookParams, LOAD_QUERY_MESSAGE, QueryData );

	RemoteFiles = Webhooks.LoadRemoteFiles( WebhookParams.ExternalRequestHandler, WebhookParams.CheckoutSHA );
	LogAction( WebhookParams, LOAD_FILES_MESSAGE, RemoteFiles );
	
EndProcedure

Procedure SaveQueryData( Val WebhookParams, Val QueryData )
	
	Var ErrorInfo;
	
	SAVE_QUERY_MESSAGE = NStr( "ru = 'СохранениеЗапросаВБазуДанных';en = 'SaveRequestToDatabase'" );
	
	ErrorInfo = Undefined;
	
	Try
		
		Webhooks.SaveQueryData( WebhookParams.ExternalRequestHandler, WebhookParams.CheckoutSHA, QueryData );
		
	Except
		
		ErrorInfo = ErrorInfo();

	EndTry;
	
	LogAction( WebhookParams, SAVE_QUERY_MESSAGE, ErrorInfo );
	
EndProcedure

Procedure SaveRemoteFiles( Val WebhookParams, Val ОтправляемыеДанные )
	
	Var ErrorInfo;
	
	SAVE_FILES_MESSAGE = NStr( "ru = 'СохранениеВнешнихФайловВБазуДанных';en = 'SaveFilesToDatabase'" );
	
	ErrorInfo = Undefined;
	
	Try
		
		Webhooks.SaveRemoteFiles( WebhookParams.ExternalRequestHandler, WebhookParams.CheckoutSHA, ОтправляемыеДанные );
		
	Except
		
		ErrorInfo = ErrorInfo();

	EndTry;
	
	LogAction( WebhookParams, SAVE_FILES_MESSAGE, ErrorInfo );
	
EndProcedure

Procedure SaveData( Val WebhookParams, QueryData, RemoteFiles )

	SaveQueryData( WebhookParams, QueryData );
	SaveRemoteFiles( WebhookParams, RemoteFiles );
	
EndProcedure

#EndRegion
