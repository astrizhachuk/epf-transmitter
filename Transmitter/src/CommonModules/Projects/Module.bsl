#Region Public

// FindCredentials returns the credentials for the URL of the remote project. 
// 
// Parameters:
// 	URL - String - remote project URL;
// 	
// Returns:
// 	Structure - credentials:
// * Ref - CatalogRef.Webhooks - ref to webhook;
// * SecretToken - String - webhook token; 
//
Function FindCredentials( Val URL ) Export

	Var Items;
	
	Items = Catalogs.Webhooks.FindByURL( URL );
	
	If ( NOT ValueIsFilled(Items) ) Then
		
		Return New Structure();
		
	EndIf;
	
	If ( Items.Count() > 1 ) Then
		
		Raise NStr( "ru = 'Обнаружены повторяющиеся проекты.';en = 'Duplicate projects found.'" );
		
	EndIf;
		
	Return CommonUseServerCall.ValueTableToArray(Items)[0];

EndFunction

#EndRegion
