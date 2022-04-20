#Region Private

#Region Methods

Function StatusGet(Request)
	
	Return HTTPServices.GetHandleRequestStatus( Enums.RequestSource.GitLab );
	
EndFunction

Function EventsPost( Request )

	Var ExternalRequest;
	Var Token;
	Var Credential;
	Var Response;
	
	Logs.Info( Logs.Events().WS_REQUEST, Logs.Messages().REQUEST_RECEIVED );
	
	Response = New HTTPServiceResponse( HTTPServices.StatusCodes().FindCodeById("OK") );
	
	CheckHandleRequestsEnabled( Response );

// TODO заголовки тоже вынести в объект ExternalRequest, правда заголовки проверяются раньше создания объекта... на подумать
	CheckHeaders( Request, Response );
	
	If ( NOT HTTPServices.StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return Response;
		
	EndIf;
	
	Try
		
		ExternalRequest = ExternalRequests.Create( Request.GetBodyAsString(), "gitlab" );
		ExternalRequest.Verify();
	
	Except
		
		Logs.Error( Logs.Events().WS_REQUEST, ErrorProcessing.DetailErrorDescription(ErrorInfo()) );
		Raise;
		
	EndTry;
	
	Credential = Credentials.FindByURL( ExternalRequest.GetProjectURL() );

	Token = HTTPServices.FindHeader( Request, "X-Gitlab-Token" );
	
	Authenticate( Credential, Token, Response );
	
	If ( HTTPServices.StatusCodes().isOk(Response.StatusCode) ) Then
		
		DataProcessing.Start( Credential.Ref, ExternalRequest );
		
	EndIf;	
	
	Logs.Info( Logs.Events().WS_REQUEST, Logs.Messages().REQUEST_PROCESSED, , , Response );

	Return Response;
	
EndFunction

#EndRegion

Function EventEqualMethodName( Val Request, Val Event )
	
	Var MethodName;
	
	MethodName = Request.URLParameters.Get( "MethodName" );
	
	Return ( StrFind(Lower(Event), Lower(MethodName)) <> 0 );
	
EndFunction

#Region Validations

Procedure CheckHeaders( Val Request, Response )
	
	Var Token;
	Var Event;
	
	If ( NOT HTTPServices.StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return;
		
	EndIf;
	
	Token = HTTPServices.FindHeader( Request, "X-Gitlab-Token" );
	
	If ( NOT ValueIsFilled(Token) ) Then
		
		Response = New HTTPServiceResponse( HTTPServices.StatusCodes().FindCodeById("BAD_REQUEST") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().NO_TOKEN, , , Response );
		Return;
		
	EndIf;	
	
	Event = HTTPServices.FindHeader( Request, "X-Gitlab-Event" );
	
	If ( NOT ValueIsFilled(Event) ) Then
		
		Response = New HTTPServiceResponse( HTTPServices.StatusCodes().FindCodeById("BAD_REQUEST") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().NO_EVENT, , , Response );
		Return;
		
	EndIf;
	
	If ( NOT EventEqualMethodName(Request, Event) ) Then
		
		Response = New HTTPServiceResponse( HTTPServices.StatusCodes().FindCodeById("BAD_REQUEST") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().EVENT_WRONG, , , Response );
		Return;
				
	EndIf;

EndProcedure

Procedure Authenticate( Val Credentials, Val Token, Response )
	
	If ( NOT HTTPServices.StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return;
		
	EndIf;
	
	If ( NOT ValueIsFilled(Credentials) ) Then

		Response = New HTTPServiceResponse( HTTPServices.StatusCodes().FindCodeById("NOT_FOUND") );
		Logs.Error( Logs.Events().AUTHENTICATION, Logs.Messages().REQUEST_HANDLER_NOT_FOUND, , , Response );
		
		Return;

	EndIf;
	
	If ( Credentials.SecretToken <> Token ) Then

		Response = New HTTPServiceResponse( HTTPServices.StatusCodes().FindCodeById("UNAUTHORIZED") );
		Logs.Error( Logs.Events().AUTHENTICATION, Logs.Messages().SECRET_TOKEN_NOT_FOUND, , , Response );
		
		Return;

	EndIf;
	
EndProcedure

Procedure CheckHandleRequestsEnabled( Response )
	
	If ( NOT HTTPServices.StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return;
		
	EndIf;
	
	If ( NOT ServicesSettings.IsHandleGitLabRequests() ) Then
		
		Response = New HTTPServiceResponse( HTTPServices.StatusCodes().FindCodeById("LOCKED") );
		Response.Reason = "loading files disabled";
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().LOADING_DISABLED, , , Response );

	EndIf;

EndProcedure

#EndRegion

#EndRegion
