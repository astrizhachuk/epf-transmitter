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
		
	Var LoggingOptions;
	Var Message;
	
	Var BackgroundJobParams;
	Var BackgroundJob;
	
	EVENT_MESSAGE = NStr( "ru = 'Core.ОбработкаДанных';en = 'Core.DataProcessing'" );
	
	JOB_WAS_STARTED_MESSAGE = NStr( "ru = 'фоновое задание уже запущено.';en = 'background job is already running.'" );
	JOB_RUNNING_ERROR_MESSAGE = NStr( "ru = 'ошибка запуска задания обработки данных:';
										|en = 'an error occurred while starting the job:'" );									
	
	Message = "";
	LoggingOptions = Логирование.ДополнительныеПараметры( Webhook );

	QueryData = Undefined;
	CheckoutSHA = "";
	
	FillProcessingData( CheckoutSHA, QueryData, Message, DataSource );

	BackgroundJob = Undefined;
	
	If ( NOT IsBlankString(Message) ) Then
	
		Логирование.Ошибка( EVENT_MESSAGE, Message, LoggingOptions );
		
		Return BackgroundJob;
	
	EndIf;
	
	If ( IsActiveBackgroundJob(CheckoutSHA) ) Then
		
		Message = Логирование.ДополнитьСообщениеПрефиксом( JOB_WAS_STARTED_MESSAGE, CheckoutSHA );
		Логирование.Предупреждение( EVENT_MESSAGE, Message, LoggingOptions );
		
		Return BackgroundJob;
		
	EndIf;
	
	BackgroundJobParams = New Array();
	BackgroundJobParams.Add( WebhookParams( Webhook, CheckoutSHA ) );
	BackgroundJobParams.Add( QueryData );

	Try
		
		BackgroundJob = BackgroundJobs.Execute( "DataProcessing.Run", BackgroundJobParams, CheckoutSHA );
		
	Except
		
		Message = Логирование.ДополнитьСообщениеПрефиксом( JOB_RUNNING_ERROR_MESSAGE, CheckoutSHA );
		Message = Message + Chars.LF + ErrorProcessing.DetailErrorDescription( ErrorInfo() );
		Логирование.Ошибка( EVENT_MESSAGE, Message, LoggingOptions );
		
	EndTry;
 
	Return BackgroundJob;
											
EndFunction

#EndRegion

#Region Internal

Procedure Run( Val WebhookParams, Val QueryData ) Export
	
	Var RemoteFiles;
	Var Commits;
	Var LoggingOptions;
	Var Message;
	
	EVENT_MESSAGE_BEGIN = NStr( "ru = 'Core.ОбработкаДанных.Начало';en = 'Core.DataProcessing.Begin'" );
	EVENT_MESSAGE_END = NStr( "ru = 'Core.ОбработкаДанных.Окончание';en = 'Core.DataProcessing.End'" );
	
	DATA_PROCESSING_MESSAGE = NStr( "ru = 'обработка данных...';en = 'data processing...'" );
	NO_DATA_MESSAGE = NStr( "ru = 'нет данных для отправки.';en = 'no data to send.'" );
	
	LoggingOptions = Логирование.ДополнительныеПараметры( WebhookParams.Webhook );

	Message = Логирование.ДополнитьСообщениеПрефиксом( DATA_PROCESSING_MESSAGE, WebhookParams.CheckoutSHA );
	Логирование.Информация( EVENT_MESSAGE_BEGIN, Message, LoggingOptions );	
	
	RemoteFiles = Undefined;
	
	PrepareData( WebhookParams, QueryData, RemoteFiles );
	
	If ( NOT ValueIsFilled(QueryData) OR NOT ValueIsFilled(RemoteFiles) ) Then

		Message = Логирование.ДополнитьСообщениеПрефиксом( NO_DATA_MESSAGE, WebhookParams.CheckoutSHA );
		Логирование.Информация( EVENT_MESSAGE_END, Message, LoggingOptions );
		
		Return;
		
	EndIf;
	
	Commits = QueryData.Get( "commits" );
	RemoteFiles = Routing.FilesByRoutes( RemoteFiles, Commits );
			
	SendFiles( WebhookParams, RemoteFiles );

	Логирование.Информация( EVENT_MESSAGE_END, Message, LoggingOptions );	
	
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

Процедура PrepareData( Val WebhookParams, QueryData, RemoteFiles )

	Var ОбработчикСобытия;
	Var CheckoutSHA;
	Var LoggingOptions;	
	Var Сообщение;
	
	EVENT_MESSAGE_BEGIN = NStr( "ru = 'Core.ПодготовкаДанных.Начало';en = 'Core.DataPreparation.Begin'" );
	EVENT_MESSAGE = NStr( "ru = 'Core.ПодготовкаДанных';en = 'Core.DataPreparation'" );
	EVENT_MESSAGE_END = NStr( "ru = 'Core.ПодготовкаДанных.Окончание';en = 'Core.DataPreparation.End'" );
	
	PREPARING_DATA_MESSAGE = NStr( "ru = 'подготовка данных к отправке.';en = 'preparing data for sending.'" );
	LOADING_DATA_MESSAGE = NStr( "ru = 'загрузка ранее сохраненных данных.';en = 'loading previously saved data.'" );
	
	ОбработчикСобытия = WebhookParams.Webhook;
	CheckoutSHA = WebhookParams.CheckoutSHA;

	LoggingOptions = Логирование.ДополнительныеПараметры( ОбработчикСобытия );
	Сообщение = Логирование.ДополнитьСообщениеПрефиксом( PREPARING_DATA_MESSAGE, CheckoutSHA );
	Логирование.Информация( EVENT_MESSAGE_BEGIN, Сообщение, LoggingOptions );

	Если ( QueryData <> Неопределено ) Тогда
		
		ПараметрыПроекта = GitLab.ProjectDescription( QueryData );
		Commits = QueryData.Получить( "commits" );
		RemoteFiles = GitLab.RemoteFilesWithDescription( ОбработчикСобытия, Commits, ПараметрыПроекта );
		Routing.AppendQueryDataByRoutingSettings(Commits, RemoteFiles );
		
		СохранитьДанные( WebhookParams, QueryData, RemoteFiles );
		
	Иначе
		
		Сообщение = Логирование.ДополнитьСообщениеПрефиксом( LOADING_DATA_MESSAGE, CheckoutSHA );
		Логирование.Информация( EVENT_MESSAGE, Сообщение, LoggingOptions );
				
		ЗагрузитьДанные( WebhookParams, QueryData, RemoteFiles );
		
	КонецЕсли;

	Сообщение = Логирование.ДополнитьСообщениеПрефиксом( PREPARING_DATA_MESSAGE, CheckoutSHA );
	Логирование.Информация( EVENT_MESSAGE_END, Сообщение, LoggingOptions );
	
КонецПроцедуры

Процедура SendFiles( Val ПараметрыСобытия, Val ОтправляемыеДанные )
	
	Var ОбработчикСобытия;
	Var CheckoutSHA;
	Var LoggingOptions;
	Var ПараметрыДоставки;
	Var КлючФоновогоЗадания;
	Var Сообщение;
	Var ОтправляемыхФайлов;
	Var ЗапущенныхЗаданий;
	
	EVENT_MESSAGE = NStr( "ru = 'Core.ОбработкаДанных';en = 'Core.DataProcessing'" );
	GET_FILE_ERROR_MESSAGE = NStr( "ru = 'ошибка получения файла:';en = 'failed to get the file:'" );
	JOB_WAS_STARTED_MESSAGE = NStr( "ru = 'фоновое задание уже запущено.';en = 'background job is already running.'" );
	KEY_MESSAGE = NStr( "ru = 'Ключ: ';en = 'Key: '" );
	FILES_SENT_MESSAGE = NStr( "ru = 'отправляемых файлов: ';en = 'files sent: '" );
	RUNNING_JOBS_MESSAGE = NStr( "ru = 'запущенных заданий: ';en = 'running jobs: '" );
	
	ОбработчикСобытия = ПараметрыСобытия.Webhook;
	CheckoutSHA = ПараметрыСобытия.CheckoutSHA;
	LoggingOptions = Логирование.ДополнительныеПараметры( ОбработчикСобытия );
	ПараметрыДоставки = Receivers.ConnectionParams();
	
	ОтправляемыхФайлов = 0;
	ЗапущенныхЗаданий = 0; 
	
	Для каждого ОтправляемыйФайл Из ОтправляемыеДанные Цикл
		
		Если ( НЕ ПустаяСтрока(ОтправляемыйФайл.ErrorInfo) ) Тогда
			
			Сообщение = Логирование.ДополнитьСообщениеПрефиксом( GET_FILE_ERROR_MESSAGE, CheckoutSHA );
			Сообщение = Сообщение + Символы.ПС + ОтправляемыйФайл.ErrorInfo;
			Логирование.Предупреждение( EVENT_MESSAGE, Сообщение, LoggingOptions );
			
			Продолжить;
			
		КонецЕсли;

		ОтправляемыхФайлов = ОтправляемыхФайлов + 1;
		
		Для Каждого Адрес Из ОтправляемыйФайл.Routes Цикл
			
			ПараметрыДоставки.URL = Адрес;
			
			КлючФоновогоЗадания = CheckoutSHA + "|" + Адрес + "|" + ОтправляемыйФайл.FileName;
				
			Если ( IsActiveBackgroundJob(КлючФоновогоЗадания) ) Тогда
				
				Сообщение = Логирование.ДополнитьСообщениеПрефиксом( JOB_WAS_STARTED_MESSAGE, CheckoutSHA );
				Сообщение = Сообщение + Символы.ПС + KEY_MESSAGE + КлючФоновогоЗадания;
				Логирование.Предупреждение( EVENT_MESSAGE, Сообщение, LoggingOptions );
				
				Продолжить;
				
			КонецЕсли;
			
			ПараметрыЗадания = Новый Массив();
			ПараметрыЗадания.Добавить( ОтправляемыйФайл.FileName );
			ПараметрыЗадания.Добавить( ОтправляемыйФайл.BinaryData );
			ПараметрыЗадания.Добавить( ПараметрыДоставки );
			ПараметрыЗадания.Добавить( ПараметрыСобытия );
			
			ФоновыеЗадания.Выполнить( "Receivers.SendFile", ПараметрыЗадания, КлючФоновогоЗадания, CheckoutSHA );
															
			ЗапущенныхЗаданий = ЗапущенныхЗаданий + 1;
				
		КонецЦикла;
		
	КонецЦикла;
	
	Сообщение = Логирование.ДополнитьСообщениеПрефиксом( FILES_SENT_MESSAGE + ОтправляемыхФайлов, CheckoutSHA );
	Логирование.Информация( EVENT_MESSAGE, Сообщение, LoggingOptions );
	
	Сообщение = Логирование.ДополнитьСообщениеПрефиксом( RUNNING_JOBS_MESSAGE + ЗапущенныхЗаданий, CheckoutSHA );
	Логирование.Информация( EVENT_MESSAGE, Сообщение, LoggingOptions );
	
КонецПроцедуры

Процедура ЛогироватьРезультатОперации( Val ПараметрыСобытия, Val Action, Val Результат = Undefined )
	
	Var LoggingOptions;
	Var Сообщение;
	
	EVENT_MESSAGE = NStr( "ru = 'Core';en = 'Core'" );
	OPERATION_SUCCEEDED_MESSAGE = NStr( "ru = 'операция выполнена успешно.';en = 'the operation was successful.'" );
	OPERATION_FAILED_MESSAGE = NStr( "ru = 'операция не выполнена.';en = 'operation failed.'" );
	
	LoggingOptions = Логирование.ДополнительныеПараметры( ПараметрыСобытия.Webhook );
	
	Если ( Результат = Undefined ИЛИ ЗначениеЗаполнено(Результат) ) Тогда
		
		Сообщение = "[" + Action + "]: " + OPERATION_SUCCEEDED_MESSAGE;
		Сообщение = Логирование.ДополнитьСообщениеПрефиксом( Сообщение, ПараметрыСобытия.CheckoutSHA );
		Логирование.Информация( "Core." + Action, Сообщение, LoggingOptions );
		
	Иначе

		Сообщение = "[" + Action + "]: " + OPERATION_FAILED_MESSAGE;		
		Сообщение = Логирование.ДополнитьСообщениеПрефиксом( Сообщение, ПараметрыСобытия.CheckoutSHA );
		
		Если ( ТипЗнч(Результат) = Тип("ИнформацияОбОшибке") ) Тогда
			
			Сообщение = Сообщение + Символы.ПС + ОбработкаОшибок.ПодробноеПредставлениеОшибки( Результат );
			
		КонецЕсли;
					
		Логирование.Предупреждение( EVENT_MESSAGE + "." + Action, Сообщение, LoggingOptions );
			
	КонецЕсли;
		
КонецПроцедуры

Процедура ЗагрузитьДанные( Val ПараметрыСобытия, ДанныеЗапроса, ОтправляемыеДанные )
	
	Var ОбработчикСобытия;
	Var CheckoutSHA;
	
	LOAD_QUERY_MESSAGE = NStr( "ru = 'ЗагрузкаЗапросаИзБазыДанных';en = 'LoadingRequestFromDatabase'" );
	LOAD_FILES_MESSAGE = NStr( "ru = 'ЗагрузкаВнешнихФайловИзБазыДанных';en = 'LoadingFilesFromDatabase'" );
	
	ОбработчикСобытия = ПараметрыСобытия.Webhook;
	CheckoutSHA = ПараметрыСобытия.CheckoutSHA;

	ДанныеЗапроса = Webhooks.LoadQueryData( ОбработчикСобытия, CheckoutSHA );
	ЛогироватьРезультатОперации( ПараметрыСобытия, LOAD_QUERY_MESSAGE, ДанныеЗапроса );

	ОтправляемыеДанные = Webhooks.LoadRemoteFiles( ОбработчикСобытия, CheckoutSHA );
	ЛогироватьРезультатОперации( ПараметрыСобытия, LOAD_FILES_MESSAGE, ОтправляемыеДанные );
	
КонецПроцедуры

Процедура СохранитьДанныеЗапроса( Val ПараметрыСобытия, Val ДанныеЗапроса )
	
	Var ОбработчикСобытия;
	Var CheckoutSHA;
	Var ИнформацияОбОшибке;
	
	SAVE_QUERY_MESSAGE = NStr( "ru = 'СохранениеЗапросаВБазуДанных';en = 'SaveRequestToDatabase'" );
	
	ОбработчикСобытия = ПараметрыСобытия.Webhook;
	CheckoutSHA = ПараметрыСобытия.CheckoutSHA;
	
	ИнформацияОбОшибке = Undefined;
	
	Попытка
		
		Webhooks.SaveQueryData( ОбработчикСобытия, CheckoutSHA, ДанныеЗапроса );
		
	Исключение
		
		ИнформацияОбОшибке = ИнформацияОбОшибке();

	КонецПопытки;
	
	ЛогироватьРезультатОперации( ПараметрыСобытия, SAVE_QUERY_MESSAGE, ИнформацияОбОшибке );
	
КонецПроцедуры

Процедура СохранитьВнешниеФайлы( Val ПараметрыСобытия, Val ОтправляемыеДанные )
	
	Var ОбработчикСобытия;
	Var CheckoutSHA;
	Var ИнформацияОбОшибке;
	
	SAVE_FILES_MESSAGE = NStr( "ru = 'СохранениеВнешнихФайловВБазуДанных';en = 'SaveFilesToDatabase'" );
	
	ОбработчикСобытия = ПараметрыСобытия.Webhook;
	CheckoutSHA = ПараметрыСобытия.CheckoutSHA;
	
	ИнформацияОбОшибке = Undefined;
	
	Попытка
		
		Webhooks.SaveRemoteFiles( ОбработчикСобытия, CheckoutSHA, ОтправляемыеДанные );
		
	Исключение
		
		ИнформацияОбОшибке = ИнформацияОбОшибке();

	КонецПопытки;
	
	ЛогироватьРезультатОперации( ПараметрыСобытия, SAVE_FILES_MESSAGE, ИнформацияОбОшибке );
	
КонецПроцедуры

Процедура СохранитьДанные( Val ПараметрыСобытия, ДанныеЗапроса, ОтправляемыеДанные )

	СохранитьДанныеЗапроса( ПараметрыСобытия, ДанныеЗапроса );
	СохранитьВнешниеФайлы( ПараметрыСобытия, ОтправляемыеДанные );
	
КонецПроцедуры

#EndRegion
