#Region FormHeaderItemsEventHandlers

&AtClient
Procedure CheckServiceStatus( Command )
	
	ResponseBody = "";
	
	If ( NOT CheckFilling() ) Then
	
		Return;

	EndIf;

	Try

		Result = GetServiceResult( ServiceURL, UseAuthFromSettings );
		FillPropertyValues( ThisObject, Result );

	Except
		
		StatusCode = -1;
		ResponseBody = ErrorProcessing.DetailErrorDescription( ErrorInfo() );

	EndTry;
	
EndProcedure

#EndRegion

#Region Private

&AtServerNoContext
Function GetAuthentication()
	
	Var Result;
		
	Result = New Structure();
	Result.Insert( "User", ServicesSettings.EndpointUserName() );
	Result.Insert( "Password", ServicesSettings.EndpointUserPassword() );
	
	Return Result;
	
EndFunction

&AtServerNoContext
Function GetServiceResult( Val URL, Val UseAuth )

	Var AdditionalParameters;
	Var Response;
	Var Result;
	
	AdditionalParameters = Undefined;
	
	If ( UseAuth ) Then

		AdditionalParameters = New Structure();
		AdditionalParameters.Insert( "Authentication", GetAuthentication() );
	
	EndIf;
	
	Response = HTTPConnector.Get( URL, Undefined, AdditionalParameters );
	
	Result = New Structure();
	Result.Insert( "StatusCode", Response.StatusCode );
	Result.Insert( "ResponseBody", HTTPConnector.AsText( Response ) );
	
	Return Result;
	
EndFunction

#EndRegion