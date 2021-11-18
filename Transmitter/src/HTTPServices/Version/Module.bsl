#Region Private

#Region Methods

Function VersionGet( Request )
	
	Var Response;
	
	Response = New HTTPServiceResponse( FindCodeById("OK") );
	HTTPServices.SetBodyAsJSON( Response, GetVersion() );
	
	Return Response;
	
EndFunction

#EndRegion

Function FindCodeById( Val Id )
	
	Return HTTPStatusCodesClientServerCached.FindCodeById( Id );
	
EndFunction

Function GetVersion()
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "version", CommonUseServerCall.GetVersion() );
	
	Return Result;
	
EndFunction

#EndRegion
