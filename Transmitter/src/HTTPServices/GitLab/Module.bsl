#Region Private

#Область Methods

Function ServicesGET( Request )
	
	Var Service;
	Var Body;
	Var Response;
	
	Response = New HTTPServiceResponse( HTTPStatusCodesClientServerCached.FindCodeById("OK") );
	
	Service = HTTPServices.ServiceDescriptionByName( "gitlab" );
	
	Body = New Structure();
	Body.Insert( "version", Metadata.Version );
	Body.Insert( "services", Service );
	
	Response.Headers.Insert( "Content-Type", "application/json" );
	Response.SetBodyFromString( HTTPConnector.ОбъектВJson(Body) );
	
	Return Response;
	
EndFunction

Function WebhooksPOST( Request )
	
	Var Webhook;
	Var QueryData;
	Var Response;
	
	EVENT_MESSAGE_BEGIN = NStr( "ru = 'WebService.ОбработкаЗапроса.Начало';en = 'WebService.QueryProcessing.Begin'" );
	EVENT_MESSAGE_END = NStr( "ru = 'WebService.ОбработкаЗапроса.Окончание';en = 'WebService.QueryProcessing.End'" );
	
	RECEIVED_REQUEST_MESSAGE = NStr( "ru = 'Получен запрос с сервера GitLab.';
									|en = 'Received a request from the GitLab server.'" );
	
	PROCESSED_REQUEST_MESSAGE = NStr( "ru = 'Запрос с сервера GitLab обработан.';
									|en = 'The request from the GitLab server has been processed.'" );
	
	Response = Новый HTTPСервисОтвет( HTTPStatusCodesClientServerCached.FindCodeById("OK") );
	
	Logging.Info( EVENT_MESSAGE_BEGIN, RECEIVED_REQUEST_MESSAGE );
	
	Webhook = Undefined;
	CheckToken( Webhook, Request, Response );
	CheckHandleRequestsEnabled( Response );
	CheckRequestHeaders( Webhook, Request, Response );

	QueryData = Undefined;
	DeserializeRequestBody( Webhook, Request, Response, QueryData );
	CheckRequiredFields( Webhook, QueryData, Response );
	
	If ( HTTPStatusCodesClientServerCached.isOk(Response.КодСостояния) ) Then

		Logging.Info( EVENT_MESSAGE_END, PROCESSED_REQUEST_MESSAGE, , Response );
		
		DataProcessing.RunBackgroundJob( Webhook, QueryData );
		
	EndIf;

	Return Response;
	
EndFunction

#EndRegion

Procedure CheckToken( Webhook, Val Request, Response )

	Var Token;
	
	EVENT_MESSAGE = NStr( "ru = 'WebService.ОбработкаЗапроса';en = 'WebService.QueryProcessing'" );
	KEY_NOT_FOUND_MESSAGE = NStr( "ru = 'Секретный ключ не найден.';en = 'The Secret Key is not found.'" );
	
	If ( NOT HTTPStatusCodesClientServerCached.isOk(Response.КодСостояния) ) Then
		
		Return;
		
	EndIf;
	
	Token = Request.Headers.Get( "X-Gitlab-Token" );
	Webhook = Webhooks.FindByToken( Token );

	If ( NOT ValueIsFilled(Webhook) ) Then
		
		Response = New HTTPServiceResponse( HTTPStatusCodesClientServerCached.FindCodeById("FORBIDDEN") );
		
		Logging.Warn( EVENT_MESSAGE, KEY_NOT_FOUND_MESSAGE, , Response );
										 
	EndIf;

EndProcedure

Procedure CheckHandleRequestsEnabled( Response )
	
	EVENT_MESSAGE = NStr( "ru = 'WebService.ОбработкаЗапроса';en = 'WebService.QueryProcessing'" );
	LOADING_DISABLED_MESSAGE = NStr( "ru = 'Загрузка из внешнего хранилища отключена.';
									|en = 'Loading of the files is disabled.'" );
	
	If ( NOT HTTPStatusCodesClientServerCached.isOk(Response.КодСостояния) ) Then
		
		Return;
		
	EndIf;
	
	If ( NOT GetFunctionalOption("HandleRequests") ) Then
		
		Response = New HTTPServiceResponse( HTTPStatusCodesClientServerCached.FindCodeById("LOCKED") );
		Response.Reason = LOADING_DISABLED_MESSAGE;
		
		Logging.Warn( EVENT_MESSAGE, LOADING_DISABLED_MESSAGE, , Response );

	EndIf;

EndProcedure

// IsRepositoryEPF checks that the request belongs to a repository with external reports and processing.
// 
// Parameters:
// 	Request - HTTPServiceRequest - HTTP-request from the GitLab;
//
// Returns:
// 	Boolean - True - this is a repository for external reports and processing, otherwise - False.
//
Function IsRepositoryEPF( Val Request )
	
	Var RepositoryType;
	
	RepositoryType = Request.URLParameters.Get( "RepositoryType" );
	Return ( RepositoryType <> Undefined AND RepositoryType = "epf" );
	
EndFunction

// IsPushHook checks if request is a "Push Hook" event.
// 
// Parameters:
// 	Request - HTTPServiceRequest - HTTP-request from the GitLab;
//
// Returns:
// 	Boolean - True - this is a Push Hook, otherwise - False.
//
Function IsPushHook( Val Request )
	
	Var Event;
	Var MethodName;
	
	Event = Request.Headers.Get( "X-Gitlab-Event" );
	MethodName = Request.URLParameters.Get( "MethodName" );
	
	Return ( ValueIsFilled(Event) AND (Event = "Push Hook") AND (MethodName = "push") );
	
EndFunction

Procedure CheckRequestHeaders( Val Webhook, Val Request, Response )
	
	EVENT_MESSAGE = NStr( "ru = 'WebService.ОбработкаЗапроса';en = 'WebService.QueryProcessing'" );
	ONLY_EPF_MESSAGE = NStr( "ru = ''Сервис доступен только для внешних отчетов и обработок.';
									|en = 'The service is available only for external reports and processing.'" );
	ONLY_PUSH_MESSAGE = NStr( "ru = 'Сервис обрабатывает только события ""Push Hook"".';
									|en = 'Service only handles events ""Push Hook"".'" );
	
	If ( NOT HTTPStatusCodesClientServerCached.isOk(Response.КодСостояния) ) Then
		
		Return;
		
	EndIf;

	If ( NOT IsRepositoryEPF(Request) ) Then

		Response = New HTTPServiceResponse( HTTPStatusCodesClientServerCached.FindCodeById("BAD_REQUEST") );
		Logging.Warn( EVENT_MESSAGE, ONLY_EPF_MESSAGE, Webhook );
												 
		Return;
		
	EndIf;
	
	If ( NOT IsPushHook(Request) ) Then
		
		Response = New HTTPServiceResponse( HTTPStatusCodesClientServerCached.FindCodeById("BAD_REQUEST") );
		Logging.Warn( EVENT_MESSAGE, ONLY_PUSH_MESSAGE, Webhook );
												 
		Return;
	
	EndIf;
	
EndProcedure

// DeserializeRequestBody deserializes the GitLab request body from JSON format.
// The original text of the request body is added to the structure with the "json" key.
// 
// Parameters:
// 	Webhook - CatalogRef.Webhooks - a ref to webhook;
// 	Request - HTTPServiceRequest - HTTP-request;
// 	Response - HTTPServiceResponse - HTTP-response;
// 	QueryData - Map - (returned) GitLab request body deserialized from JSON;
//
Procedure DeserializeRequestBody( Val Webhook, Val Request, Val Response, QueryData = Undefined )
	
	Var Stream;
	Var ConversionParams;
	
	EVENT_MESSAGE_BEGIN = NStr( "ru = 'WebService.Десериализация.Начало';en = 'WebService.Deserialization.Begin'" );
	EVENT_MESSAGE = NStr( "ru = 'WebService.Десериализация';en = 'WebService.Deserialization'" );
	EVENT_MESSAGE_END = NStr( "ru = 'WebService.Десериализация.Окончание';en = 'WebService.Deserialization.End'" );
	
	DESERIALIZATION_MESSAGE = NStr( "ru = 'десериализация запроса...';en = 'deserialization from a request...'" );
	
	If ( NOT HTTPStatusCodesClientServerCached.isOk(Response.КодСостояния) ) Then
		
		Return;
		
	EndIf;

	Logging.Info( EVENT_MESSAGE_BEGIN, DESERIALIZATION_MESSAGE, Webhook );
	
	Try
		
		Stream = Request.GetBodyAsStream();
		
		ConversionParams = New Structure();
		ConversionParams.Insert( "ReadToMap", True );
		ConversionParams.Insert( "PropertiesWithDateValuesNames", "timestamp" );
		
		QueryData = HTTPConnector.JsonВОбъект( Stream, , ConversionParams );
		CommonUseServerCall.AppendCollectionFromStream( QueryData, "json", Stream );
		
		Stream.Close();
		
		Logging.Info( EVENT_MESSAGE_END, DESERIALIZATION_MESSAGE, Webhook );

	Except
		
		Stream.Close();
		Logging.Error( EVENT_MESSAGE, ErrorInfo().Description, Webhook );
		
		Raise;
		
	EndTry;
	
EndProcedure

Function RequiredFields( Val QueryData )
	
	Var Project;
	Var Commits;
	Var Result;
	
	Result = New Map();
	Result.Insert( "тело запроса" , QueryData ); //TODO что за шляпа "тело запроса", непонятно, может root?		
	Result.Insert( "checkout_sha" , QueryData.Get("checkout_sha") );
	
	Project = QueryData.Get( "project" );
	Result.Вставить( "project", Project );
	
	If ( Project <> Undefined ) Then
		
		Result.Insert( "project/web_url" , Project.Get("web_url") );
		Result.Insert( "project/id" , Project.Get("id") );
		
	EndIf;
	
	Commits = QueryData.Get( "commits" );
	
	Result.Insert( "commits" , Commits );
	
	If ( Commits <> Undefined ) Then
		
		For Index = 0 To Commits.UBound() Do
			
			Result.Insert( "commits[" + String(Index) + "]/id", Commits[Index].Get("id") );
			
		EndDo;
		
	EndIf;
	
	Return Result;
	
EndFunction

// CheckRequiredFields checks the deserialized request body for required data.
// 
// Parameters:
// 	Webhook - CatalogRef.Webhooks - a ref to webhook;
// 	QueryData - Map - GitLab request body deserialized from JSON;
// 	Response - HTTPServiceResponse - HTTP-response;
//
Procedure CheckRequiredFields( Val Webhook, Val QueryData, Response )
	
	Var RequiredFields;
	Var Message;
	
	EVENT_MESSAGE_BEGIN = NStr( "ru = 'WebService.ПроверкаЗапроса.Начало';en = 'WebService.RequestValidation.Begin'" );
	EVENT_MESSAGE = NStr( "ru = 'WebService.ПроверкаЗапроса';en = 'WebService.RequestValidation'" );
	EVENT_MESSAGE_END = NStr( "ru = 'WebService.ПроверкаЗапроса.Окончание';en = 'WebService.RequestValidation.End'" );

	VALIDATION_MESSAGE = NStr( "ru = 'проверка данных запроса...';en = 'query data validation...'" );
	MISSING_DATA_MESSAGE = NStr( "ru = 'В данных запроса отсутствует %1.';en = '%1 is missing in the request data.'" );
	
	If ( NOT HTTPStatusCodesClientServerCached.isOk(Response.КодСостояния) ) Then
		
		Return;
		
	EndIf;

	Logging.Info( EVENT_MESSAGE_BEGIN, VALIDATION_MESSAGE, Webhook );
	
	RequiredFields = RequiredFields( QueryData );
	
	For Each Field In RequiredFields Do
		
		If ( Field.Value = Undefined ) Then
			
			Response = New HTTPServiceResponse( HTTPStatusCodesClientServerCached.FindCodeById("BAD_REQUEST") );
			
			Message = StrTemplate( MISSING_DATA_MESSAGE, Field.Key );
			Logging.Error( EVENT_MESSAGE, Message, Webhook );
			
			Return;		
			
		EndIf;		
		
	EndDo;
	
	Logging.Info( EVENT_MESSAGE_END, VALIDATION_MESSAGE, Webhook );
	
EndProcedure

#EndRegion