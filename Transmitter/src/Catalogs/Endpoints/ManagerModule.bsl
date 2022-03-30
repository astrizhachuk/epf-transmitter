#Region Public

// FindByBaseURL returns the search result by infobase URL from records not marked for deletion.
// 
// Parameters:
// 	URL - String - endpoint infobase URL;
// 	
// Returns:
// 	Array of CatalogRef.Endpoints - list of ref to endpoints;
//
Function FindByBaseURL( Val URL ) Export
	
	Var Query;
	
	If ( TypeOf(URL) <> Type("String") ) Then
		
		Return New Array();
		
	EndIf;
	
	Query = New Query();
	Query.SetParameter( "URL", URL );
	Query.Text = 	"SELECT
					|	Endpoints.Ref AS Ref
					|FROM
					|	Catalog.Endpoints AS Endpoints
					|WHERE
					|	NOT Endpoints.DeletionMark
					|	AND Endpoints.BaseURL = &URL";
	
	Return Query.Execute().Unload().UnloadColumn( "Ref" );
	
EndFunction

#EndRegion