#Region Private

#Region Methods

Function StatusGet(Request)
	
	Var Response;
	
	Response = New HTTPServiceResponse( FindCodeById("OK") );
	HTTPServices.SetBodyAsJSON( Response, GitLab.GetRequestHandlerStateMessage() );
	
	Return Response;
	
EndFunction

Function EventsPost( Request )
	
	Var Token;
	Var Webhook;
	Var Data;
	Var Response;
	
	Logs.Info( Logs.Events().WS_REQUEST_BEGIN, Logs.Messages().REQUEST_RECEIVED );

	Response = New HTTPServiceResponse( FindCodeById("OK") );
	
	CheckHeaders( Request, Response );
	
	Token = GetHeader( Request, "X-Gitlab-Token" );
	CheckToken( Response, Token );
	
	Webhook = Webhooks.FindByToken( Token );
	Authenticate( Response, Webhook );	
	
	CheckHandleRequestsEnabled( Response );
	
	If ( NOT StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return Response;
		
	EndIf;

	Data = GetData( Request, Response );
	
	If ( StatusCodes().isOk(Response.StatusCode) ) Then

		DataProcessing.RunBackgroundJob( Webhook, Data );
		
	EndIf;
	
	Logs.Info( Logs.Events().WS_REQUEST_END, Logs.Messages().REQUEST_PROCESSED, , Response );

	Return Response;
	
EndFunction

#EndRegion

Function StatusCodes()
	
	Возврат HTTPStatusCodesClientServerCached;
	
EndFunction

Function FindCodeById( Val Id )
	
	Return HTTPStatusCodesClientServerCached.FindCodeById( Id );
	
EndFunction

Function GetHeader( Val Request, Val Key )
	
	Var Result;
	
	Result = Request.Headers.Get( Key );
	
	If ( Result = Undefined ) Then
		
		Result = Request.Headers.Get( Lower(Key) );
		
	EndIf;
	
	Return Result;
	
EndFunction

Function EventEqualMethodName( Val Request, Val Event )
	
	Var MethodName;
	
	MethodName = Request.URLParameters.Get( "MethodName" );
	
	Return ( StrFind(Lower(Event), Lower(MethodName)) <> 0 );
	
EndFunction

Function GetData( Val Request, Val Response )
		
	Var Stream;
	Var ConversionParams;

	Try
		
		Stream = Request.GetBodyAsStream();
		
		ConversionParams = New Structure();
		ConversionParams.Insert( "ReadToMap", True );
		ConversionParams.Insert( "PropertiesWithDateValuesNames", "timestamp" );
		
		Data = HTTPConnector.JsonToObject( Stream, , ConversionParams );
		CommonUseServerCall.AppendCollectionFromStream( Data, "json", Stream );
		
		Stream.Close();
		Logs.Info( Logs.Events().WS_REQUEST, Logs.Messages().DESERIALIZING );

		Return Data;
		
	Except
		
		Stream.Close();
		
		Logs.Error( Logs.Events().WS_REQUEST, ErrorProcessing.DetailErrorDescription( ErrorInfo() ) );
		
		Raise;
		
	EndTry;
	
EndFunction

#Region Validations

Procedure CheckHeaders( Val Request, Response )
	
	Var Token;
	Var Event;
	
	If ( NOT StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return;
		
	EndIf;
	
	Token = GetHeader( Request, "X-Gitlab-Token" );
	
	If ( NOT ValueIsFilled(Token) ) Then
		
		Response = New HTTPServiceResponse( FindCodeById("BAD_REQUEST") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().KEY_MISSING, , Response );

	EndIf;	
	
	Event = GetHeader( Request, "X-Gitlab-Event" );
	
	If ( NOT ValueIsFilled(Event) ) Then
		
		Response = New HTTPServiceResponse( FindCodeById("BAD_REQUEST") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().EVENT_MISSING, , Response );

	EndIf;
	
	If ( NOT EventEqualMethodName(Request, Event) ) Then
		
		Response = New HTTPServiceResponse( FindCodeById("BAD_REQUEST") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().EVENT_WRONG, , Response );
		
	EndIf;

EndProcedure

Procedure CheckToken( Response, Val Token )
	
	If ( NOT StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return;
		
	EndIf;
	
	if ( NOT ValueIsFilled(Token) ) Then
	
		Response = New HTTPServiceResponse( FindCodeById("UNAUTHORIZED") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().KEY_MISSING, , Response );
		
	EndIf;
	
EndProcedure

Procedure Authenticate( Response, Val Webhook )
	
	If ( NOT StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return;
		
	EndIf;
	
	If ( Webhook.IsEmpty() ) Then
		
		Response = New HTTPServiceResponse( FindCodeById("UNAUTHORIZED") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().KEY_NOT_FOUND, , Response );
										 
	EndIf;
	
EndProcedure

Procedure CheckHandleRequestsEnabled( Response )
	
	If ( NOT StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return;
		
	EndIf;
	
	If ( NOT ServicesSettings.IsHandleRequests() ) Then
		
		Response = New HTTPServiceResponse( FindCodeById("LOCKED") );
		Response.Reason = "file upload is disabled";
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().LOADING_DISABLED, , Response );

	EndIf;

EndProcedure

#EndRegion

#EndRegion
