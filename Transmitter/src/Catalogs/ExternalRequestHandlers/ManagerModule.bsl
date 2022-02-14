#Region Public

// FindByURL returns the search result by URL from records not marked for deletion.
// 
// Parameters:
// 	URL - String - remote project URL;
// 	
// Returns:
// 	ValueTable - search result:
// 	* Ref - CatalogRef.ExternalRequestHandlers - ref to external request handler;
// 	* SecretToken - String - remote repository token;
//
Function FindByURL( Val URL ) Export
	
	Var Query;
	
	If ( TypeOf(URL) <> Type("String") ) Then
		
		Return New Array();
		
	EndIf;
	
	Query = New Query();
	Query.SetParameter( "URL", URL );
	Query.Text = 	"SELECT
					|	ExternalRequestHandlers.Ref AS Ref,
					|	ExternalRequestHandlers.SecretToken AS SecretToken
					|FROM
					|	Catalog.ExternalRequestHandlers AS ExternalRequestHandlers
					|WHERE
					|	NOT ExternalRequestHandlers.DeletionMark
					|	AND ExternalRequestHandlers.ProjectURL = &URL";
	
	Return Query.Execute().Unload();
	
EndFunction

#EndRegion
