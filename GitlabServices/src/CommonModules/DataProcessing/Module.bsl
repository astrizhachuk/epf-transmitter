#Region Public

// RunBackgroundJob prepares and run background job to process "webhooked" or saved GitLab server request.
// 
// Parameters:
//	Webhook - CatalogRef.Webhooks - a ref to webhook;
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
	
		Logging.Error( EVENT_MESSAGE, Message, Webhook );
		
		Return BackgroundJob;
	
	EndIf;
	
	If ( IsActiveBackgroundJob(CheckoutSHA) ) Then
		
		Message = Logging.AddPrefix( JOB_WAS_STARTED_MESSAGE, CheckoutSHA );
		Logging.Warn( EVENT_MESSAGE, Message, Webhook );
		
		Return BackgroundJob;
		
	EndIf;
	
	BackgroundJobParams = New Array();
	BackgroundJobParams.Add( WebhookParams( Webhook, CheckoutSHA ) );
	BackgroundJobParams.Add( QueryData );

	Try
		
		BackgroundJob = BackgroundJobs.Execute( "DataProcessing.Run", BackgroundJobParams, CheckoutSHA );
		
	Except
		
		Message = Logging.AddPrefix( JOB_RUNNING_ERROR_MESSAGE, CheckoutSHA );
		Message = Message + Chars.LF + ErrorProcessing.DetailErrorDescription( ErrorInfo() );
		Logging.Error( EVENT_MESSAGE, Message, Webhook );
		
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
	
	Message = Logging.AddPrefix( DATA_PROCESSING_MESSAGE, WebhookParams.CheckoutSHA );
	Logging.Info( EVENT_MESSAGE_BEGIN, Message, WebhookParams.Webhook );
	
	RemoteFiles = Undefined;
	
	PrepareData( WebhookParams, QueryData, RemoteFiles );
	
	If ( NOT ValueIsFilled(QueryData) OR NOT ValueIsFilled(RemoteFiles) ) Then

		Message = Logging.AddPrefix( NO_DATA_MESSAGE, WebhookParams.CheckoutSHA );
		Logging.Info( EVENT_MESSAGE_END, Message, WebhookParams.Webhook );
		
		Return;
		
	EndIf;
	
	Commits = QueryData.Get( "commits" );
	RemoteFiles = Routing.FilesByRoutes( RemoteFiles, Commits );
			
	SendFiles( WebhookParams, RemoteFiles );

	Logging.Info( EVENT_MESSAGE_END, Message, WebhookParams.Webhook );
	
EndProcedure

#EndRegion

#Region Private

Function ActiveBackgroundJob( Val Key )
	
	Var Filter;
	
	Filter = New Structure( "Key, State", Key, BackgroundJobState.Active );

	Return BackgroundJobs.GetBackgroundJobs( Filter );
	
EndFunction

Function IsActiveBackgroundJob( Val Key )
	
	Return ValueIsFilled( ActiveBackgroundJob(Key) );
	
EndFunction

Function WebhookParams( Val Webhook, Val CheckoutSHA )
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "Webhook", Webhook );
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
	
	Message = Logging.AddPrefix( PREPARING_DATA_MESSAGE, WebhookParams.CheckoutSHA );
	Logging.Info( EVENT_MESSAGE_BEGIN, Message, WebhookParams.Webhook );

	If ( QueryData <> Undefined ) Then
		
		ProjectParams = GitLab.ProjectDescription( QueryData );
		Commits = QueryData.Get( "commits" );
		RemoteFiles = GitLab.RemoteFilesWithDescription( WebhookParams.Webhook, Commits, ProjectParams );
		Routing.ExtendQueryDataWithRoutingSettings( Commits, RemoteFiles );
		
		SaveData( WebhookParams, QueryData, RemoteFiles );
		
	Else
		
		Message = Logging.AddPrefix( LOADING_DATA_MESSAGE, WebhookParams.CheckoutSHA );
		Logging.Info( EVENT_MESSAGE, Message, WebhookParams.Webhook );
				
		LoadData( WebhookParams, QueryData, RemoteFiles );
		
	EndIf;

	Message = Logging.AddPrefix( PREPARING_DATA_MESSAGE, WebhookParams.CheckoutSHA );
	Logging.Info( EVENT_MESSAGE_END, Message, WebhookParams.Webhook );
	
EndProcedure

Procedure SendFiles( Val WebhookParams, Val RemoteFiles )
	
	Var SendParams;
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
	
	SendParams = Receivers.ConnectionParams();
	
	FilesCounter = 0;
	JobsCounter = 0; 
	
	For Each RemoteFile In RemoteFiles Do
		
		If ( NOT IsBlankString(RemoteFile.ErrorInfo) ) Then
			
			Message = Logging.AddPrefix( GET_FILE_ERROR_MESSAGE, WebhookParams.CheckoutSHA );
			Message = Message + Chars.LF + RemoteFile.ErrorInfo;
			Logging.Warn( EVENT_MESSAGE, Message, WebhookParams.Webhook );
			
			Continue;
			
		EndIf;

		FilesCounter = FilesCounter + 1;
		
		For Each URL In RemoteFile.Routes Do
			
			SendParams.URL = URL;
			
			JobKey = WebhookParams.CheckoutSHA + "|" + URL + "|" + RemoteFile.FileName;
				
			If ( IsActiveBackgroundJob(JobKey) ) Then
				
				Message = Logging.AddPrefix( JOB_WAS_STARTED_MESSAGE, WebhookParams.CheckoutSHA );
				Message = Message + Chars.LF + KEY_MESSAGE + JobKey;
				Logging.Warn( EVENT_MESSAGE, Message, WebhookParams.Webhook );
				
				Continue;
				
			EndIf;
			
			JobParams = New Array();
			JobParams.Add( RemoteFile.FileName );
			JobParams.Add( RemoteFile.BinaryData );
			JobParams.Add( SendParams );
			JobParams.Add( WebhookParams );
			
			BackgroundJobs.Execute( "Receivers.SendFile", JobParams, JobKey, WebhookParams.CheckoutSHA );
															
			JobsCounter = JobsCounter + 1;
				
		EndDo;
		
	EndDo;
	
	Message = Logging.AddPrefix( FILES_SENT_MESSAGE + FilesCounter, WebhookParams.CheckoutSHA );
	Logging.Info( EVENT_MESSAGE, Message, WebhookParams.Webhook );
	
	Message = Logging.AddPrefix( RUNNING_JOBS_MESSAGE + JobsCounter, WebhookParams.CheckoutSHA );
	Logging.Info( EVENT_MESSAGE, Message, WebhookParams.Webhook );
	
EndProcedure

Procedure LogAction( Val WebhookParams, Val Action, Val Result = Undefined )
	
	Var Message;
	
	EVENT_MESSAGE = NStr( "ru = 'Core';en = 'Core'" );
	OPERATION_SUCCEEDED_MESSAGE = NStr( "ru = 'операция выполнена успешно.';en = 'the operation was successful.'" );
	OPERATION_FAILED_MESSAGE = NStr( "ru = 'операция не выполнена.';en = 'operation failed.'" );
	
	If ( Result = Undefined OR ValueIsFilled(Result) ) Then
		
		Message = "[" + Action + "]: " + OPERATION_SUCCEEDED_MESSAGE;
		Message = Logging.AddPrefix( Message, WebhookParams.CheckoutSHA );
		Logging.Info( "Core." + Action, Message, WebhookParams.Webhook );
		
	Else

		Message = "[" + Action + "]: " + OPERATION_FAILED_MESSAGE;		
		Message = Logging.AddPrefix( Message, WebhookParams.CheckoutSHA );
		
		If ( TypeOf(Result) = Type("ErrorInfo") ) Then
			
			Message = Message + Chars.LF + ErrorProcessing.DetailErrorDescription( Result );
			
		EndIf;
					
		Logging.Warn( EVENT_MESSAGE + "." + Action, Message, WebhookParams.Webhook );
			
	EndIf;
		
EndProcedure

Procedure LoadData( Val WebhookParams, QueryData, RemoteFiles )

	LOAD_QUERY_MESSAGE = NStr( "ru = 'ЗагрузкаЗапросаИзБазыДанных';en = 'LoadingRequestFromDatabase'" );
	LOAD_FILES_MESSAGE = NStr( "ru = 'ЗагрузкаВнешнихФайловИзБазыДанных';en = 'LoadingFilesFromDatabase'" );
	
	QueryData = Webhooks.LoadQueryData( WebhookParams.Webhook, WebhookParams.CheckoutSHA );
	LogAction( WebhookParams, LOAD_QUERY_MESSAGE, QueryData );

	RemoteFiles = Webhooks.LoadRemoteFiles( WebhookParams.Webhook, WebhookParams.CheckoutSHA );
	LogAction( WebhookParams, LOAD_FILES_MESSAGE, RemoteFiles );
	
EndProcedure

Procedure SaveQueryData( Val WebhookParams, Val QueryData )
	
	Var ErrorInfo;
	
	SAVE_QUERY_MESSAGE = NStr( "ru = 'СохранениеЗапросаВБазуДанных';en = 'SaveRequestToDatabase'" );
	
	ErrorInfo = Undefined;
	
	Try
		
		Webhooks.SaveQueryData( WebhookParams.Webhook, WebhookParams.CheckoutSHA, QueryData );
		
	Except
		
		ErrorInfo = ErrorInfo();

	EndTry;
	
	LogAction( WebhookParams, SAVE_QUERY_MESSAGE, ErrorInfo );
	
EndProcedure

Процедура SaveRemoteFiles( Val WebhookParams, Val ОтправляемыеДанные )
	
	Var ErrorInfo;
	
	SAVE_FILES_MESSAGE = NStr( "ru = 'СохранениеВнешнихФайловВБазуДанных';en = 'SaveFilesToDatabase'" );
	
	ErrorInfo = Undefined;
	
	Try
		
		Webhooks.SaveRemoteFiles( WebhookParams.Webhook, WebhookParams.CheckoutSHA, ОтправляемыеДанные );
		
	Except
		
		ErrorInfo = ErrorInfo();

	EndTry;
	
	LogAction( WebhookParams, SAVE_FILES_MESSAGE, ErrorInfo );
	
КонецПроцедуры

Procedure SaveData( Val WebhookParams, QueryData, RemoteFiles )

	SaveQueryData( WebhookParams, QueryData );
	SaveRemoteFiles( WebhookParams, RemoteFiles );
	
EndProcedure

#EndRegion
