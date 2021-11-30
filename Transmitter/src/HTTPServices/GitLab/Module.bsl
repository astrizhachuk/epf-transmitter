#Region Private

#Region Methods

Function StatusGet(Request)
	
	Var Response;
	
	Response = New HTTPServiceResponse( FindCodeById("OK") );
	HTTPServices.SetBodyAsJSON( Response, GitLab.GetRequestHandlerStateMessage() );
	
	Return Response;
	
EndFunction

Function EventsPost( Request )

	Var Data;
	Var Credentials;
	Var Token;
	Var Response;
	
	Logs.Info( Logs.Events().WS_REQUEST_BEGIN, Logs.Messages().REQUEST_RECEIVED );

	Response = New HTTPServiceResponse( FindCodeById("OK") );
	
	CheckHandleRequestsEnabled( Response );

	CheckHeaders( Request, Response );
	
	If ( NOT StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return Response;
		
	EndIf;
	
	Data = GetData( Request );
	Credentials = Projects.FindCredentials( GetProjectURL(Data) );

	Token = GetHeader( Request, "X-Gitlab-Token" );
	
	Authenticate( Credentials, Token, Response );
	
	If ( StatusCodes().isOk(Response.StatusCode) ) Then

		DataProcessing.RunBackgroundJob( Credentials.Ref, Data );
		
	EndIf;	
	
	Logs.Info( Logs.Events().WS_REQUEST_END, Logs.Messages().REQUEST_PROCESSED, , Response );

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

Function GetData( Val Request )
		
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

Function GetProjectURL( Val Data )

	Var Result;
	
	Try
		
		Result = Data.Get( "project" ).Get( "web_url" );
		
		If ( Result = Undefined ) Then
			
			Raise Logs.Messages().URL_MISSING;
			
		EndIf;
		
	Except
		
		Logs.Error( Logs.Events().WS_REQUEST, ErrorProcessing.DetailErrorDescription( ErrorInfo() ) );
		
		Raise;
		
	EndTry;
	
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
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().KEY_MISSING, , Response );
		Return;
		
	EndIf;	
	
	Event = GetHeader( Request, "X-Gitlab-Event" );
	
	If ( NOT ValueIsFilled(Event) ) Then
		
		Response = New HTTPServiceResponse( FindCodeById("BAD_REQUEST") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().EVENT_MISSING, , Response );
		Return;
		
	EndIf;
	
	If ( NOT EventEqualMethodName(Request, Event) ) Then
		
		Response = New HTTPServiceResponse( FindCodeById("BAD_REQUEST") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().EVENT_WRONG, , Response );
		Return;
				
	EndIf;

EndProcedure

Procedure Authenticate( Val Credentials, Val Token, Response )
	
	If ( NOT StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return;
		
	EndIf;
	
	If ( NOT ValueIsFilled(Credentials) ) Then

		Response = New HTTPServiceResponse( FindCodeById("NOT_FOUND") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().WEBHOOK_NOT_FOUND, , Response );
		Return;
		
	EndIf;
	
	If ( Credentials.SecretToken <> Token ) Then
		
		Response = New HTTPServiceResponse( FindCodeById("UNAUTHORIZED") );
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().KEY_NOT_FOUND, , Response );
		Return;
										 
	EndIf;
	
EndProcedure

Procedure CheckHandleRequestsEnabled( Response )
	
	If ( NOT StatusCodes().isOk(Response.StatusCode) ) Then
		
		Return;
		
	EndIf;
	
	If ( NOT ServicesSettings.HandleRequests() ) Then
		
		Response = New HTTPServiceResponse( FindCodeById("LOCKED") );
		Response.Reason = "file upload is disabled";
		Logs.Error( Logs.Events().WS_REQUEST, Logs.Messages().LOADING_DISABLED, , Response );

	EndIf;

EndProcedure

#EndRegion

#EndRegion
