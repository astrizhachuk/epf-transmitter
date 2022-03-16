#Region Private

#Region Methods

Function StatusGet(Request)
	
	Var Response;
	
	Response = New HTTPServiceResponse( FindCodeById("OK") );
	HTTPServices.SetBodyAsJSON( Response, GetHandleRequestsStatus() );
	
	Return Response;
	
EndFunction

Function EventsPost( Request )

	Var ExternalRequest;
	Var Token;
	Var Credential;
	Var Response;
	
	Logs.Info( Logs.Events().WS_REQUEST, Logs.Messages().REQUEST_RECEIVED );
	
	Response = New HTTPServiceResponse( FindCodeById("OK") );
	
	CheckHandleRequestsEnabled( Response );

// TODO заголовки тоже вынести в объект ExternalRequest, правда заголовки проверяются раньше создания объекта... на подумать
	CheckHeaders( Request, Response );
	
	If ( NOT StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return Response;
		
	EndIf;
	
	Try
		
		ExternalRequest = ExternalRequests.Create( Request.GetBodyAsString(), "gitlab" );
		ExternalRequest.Validate();
	
	Except
		
		Logs.Error( Logs.Events().WS_REQUEST, ErrorProcessing.DetailErrorDescription(ErrorInfo()) );
		Raise;
		
	EndTry;
	
	Credential = Credentials.FindByURL( ExternalRequest.GetProjectURL() );

	Token = GetHeader( Request, "X-Gitlab-Token" );
	
	Authenticate( Credential, Token, Response );
	
	If ( StatusCodes().isOk(Response.StatusCode) ) Then
		
		DataProcessing.Start( Credential.Ref, ExternalRequest );
		
	EndIf;	
	
	Logs.Info( Logs.Events().WS_REQUEST, Logs.Messages().REQUEST_PROCESSED, , , Response );

	Return Response;
	
EndFunction

#EndRegion

Function StatusCodes()
	
	Возврат HTTPStatusCodesClientServerCached;
	
EndFunction

Function FindCodeById( Val Id )
	
	Return StatusCodes().FindCodeById( Id );
	
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

// GetHandleRequestsStatus returns the current setting state for handling requests
// from external stores as a message object.
// 
// Returns:
// 	Structure - message object:
// * message - String - message text;
//
Function GetHandleRequestsStatus()
	
	Var Result;
	
	MESSAGE_ENABLED = NStr( "ru = 'обработка запросов включена';en = 'request handler enabled'" );
	MESSAGE_DISABLED = NStr( "ru = 'обработка запросов отключена';en = 'request handler disabled'" );
	
	If ( ServicesSettings.HandleRequests() ) Then
		
		Result = HTTPServices.CreateMessage( MESSAGE_ENABLED );
		
	Else
		
		Result = HTTPServices.CreateMessage( MESSAGE_DISABLED );
		
	EndIf;
	
	Return Result;
	
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
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().NO_TOKEN, , , Response );
		Return;
		
	EndIf;	
	
	Event = GetHeader( Request, "X-Gitlab-Event" );
	
	If ( NOT ValueIsFilled(Event) ) Then
		
		Response = New HTTPServiceResponse( FindCodeById("BAD_REQUEST") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().NO_EVENT, , , Response );
		Return;
		
	EndIf;
	
	If ( NOT EventEqualMethodName(Request, Event) ) Then
		
		Response = New HTTPServiceResponse( FindCodeById("BAD_REQUEST") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().EVENT_WRONG, , , Response );
		Return;
				
	EndIf;

EndProcedure

Procedure Authenticate( Val Credentials, Val Token, Response )
	
	If ( NOT StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return;
		
	EndIf;
	
	If ( NOT ValueIsFilled(Credentials) ) Then

		Response = New HTTPServiceResponse( FindCodeById("NOT_FOUND") );
		Logs.Error( Logs.Events().AUTHENTICATION, Logs.Messages().REQUEST_HANDLER_NOT_FOUND, , , Response );
		
		Return;

	EndIf;
	
	If ( Credentials.SecretToken <> Token ) Then

		Response = New HTTPServiceResponse( FindCodeById("UNAUTHORIZED") );
		Logs.Error( Logs.Events().AUTHENTICATION, Logs.Messages().SECRET_TOKEN_NOT_FOUND, , , Response );
		
		Return;

	EndIf;
	
EndProcedure

Procedure CheckHandleRequestsEnabled( Response )
	
	If ( NOT StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return;
		
	EndIf;
	
	If ( NOT ServicesSettings.HandleRequests() ) Then
		
		Response = New HTTPServiceResponse( FindCodeById("LOCKED") );
		Response.Reason = "loading files disabled";
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().LOADING_DISABLED, , , Response );

	EndIf;

EndProcedure

#EndRegion

#EndRegion
