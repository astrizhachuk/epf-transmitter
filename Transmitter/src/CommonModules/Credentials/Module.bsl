#Region Public

// FindByURL looks for the project credentials at the remote project URL.
// 
// Parameters:
// 	URL - String - remote project URL;
// 	
// Returns:
// 	Structure - credentials:
// * Ref - CatalogRef.ExternalRequestHandlers - ref to external request handler;
// * SecretToken - String - remote project token; 
//
Function FindByURL( Val URL ) Export

	Var Items;
	
	Items = Catalogs.ExternalRequestHandlers.FindByURL( URL );
	
	If ( NOT ValueIsFilled(Items) ) Then
		
		Return New Structure();
		
	EndIf;
	
	If ( Items.Count() > 1 ) Then
		
		Raise NStr( "ru = 'Обнаружены повторяющиеся проекты.';en = 'Duplicate projects found.'" );
		
	EndIf;
		
	Return CommonUseServerCall.ValueTableToArray(Items)[0];

EndFunction

#EndRegion
