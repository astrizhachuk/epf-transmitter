#Region Public

// ServiceDescriptionByName returns a deserializated description of a web service by service name (see the REST API).
// 
// Parameters:
// 	Name - String - service metadata name;
//
// Returns:
// 	- Undefined - the service is not found;
// 	- Structure - description:
//		* name - String - service name;
//		* desc - String - service comment;
// 		* enabled - Boolean - True - handle requests enabled, otherwise - False;
// 		* templates - Array of Structure - URL templates:
//			** name - String - URL template name;
//			** desc - String - URL template comment;
//			** template - String - template;
//			** methods - Array of Structure - methods:
//				*** name - String - service method name;
//				*** desc - String - service method comment;
//				*** method - String - service HTTP-method;
//			
Function ServiceDescriptionByName( Val Name ) Export
	
	Var ServiceMetadata;
	
	ServiceMetadata = Metadata.HTTPServices.Find( Name );
	
	If (ServiceMetadata = Undefined) Then
		
		Return Undefined;
		
	EndIf;
	
	Return Service( Name, ServiceMetadata );
	
EndFunction

// ServiceDescriptionByURL returns a description of a web service by URL with deserialization.
// 
// Parameters:
// 	URL - String - service UR;
// 
// Returns:
// 	- Undefined - if the service is not found or the service description is not JSON-format;
// 	- FixedStructure - the response body and the results of converting it to various formats:
//		* Response - Structure - (See. HTTPConnector.Get)
//		* Data - Map - (See. HTTPConnector.КакJson)
// 		* JSON - String - (See HTTPConnector.КакТекст)
//			
Function ServiceDescriptionByURL( Val URL ) Export
	
	Var HTTPStatusCodes;
	Var Response;
	Var Result;

	Result = Undefined;
	
	If ( TypeOf(URL) <> Type("String") OR IsBlankString(URL) ) Then
		
		Return Result;
		 					
	EndIf;
	
	Response = HTTPConnector.Get( URL );
	
	HTTPStatusCodes = HTTPStatusCodesClientServerCached;
			
	If ( ValueIsFilled(Response) AND HTTPStatusCodes.isOk(Response.КодСостояния) AND ValueIsFilled(Response.Тело) ) Then
	
		Try

			
			Result = New Structure();
			Result.Insert( "Response", Response );
			Result.Insert( "Data", HTTPConnector.КакJson(Response) );
			Result.Insert( "JSON", HTTPConnector.КакТекст(Response, TextEncoding.UTF8) );
			
		Except
			
			Return Undefined;
			
		EndTry;
		
		Result = New FixedStructure( Result );
		
	EndIf;
		
	Return Result;
	
EndFunction

// ResponseTemplate returns the response scheme (see the REST API).
// 
// Returns:
// 	Structure - description:
// * type - String - response type, "info" or "error";
// * message - String - message;
//
Function ResponseTemplate() Export

	Var Result;
	
	Result = New Structure();
	Result.Insert( "type" );
	Result.Insert( "message" );
	
	Return Result;

EndFunction

#EndRegion

#Region Private

Function Service( Val Name, Val ServiceMetadata )

	Var Result;
	
	Result = New Structure();
	Result.Insert( "name", Name );
	Result.Insert( "desc", ServiceMetadata.Comment );
	Result.Insert( "enabled", GetFunctionalOption( "HandleRequests" ) );
	Result.Insert( "templates", URLTemplates( ServiceMetadata.URLTemplates ) );
	
	Return Result;

EndFunction

Function Methods( Val Methods )
	
	Var NewMethod;
	Var Result;
	
	Result = New Array();
	
	For Each Method In Methods Do
		
		NewMethod =  New Structure();
		NewMethod.Insert( "name", Method.Name );
		NewMethod.Insert( "desc", Method.Comment );
		NewMethod.Insert( "method", String(Method.HTTPMethod) );

		Result.Add( NewMethod );
		
	КонецЦикла;
	
	Return Result;

EndFunction

Function URLTemplates( Val Templates )
	
	Var NewTemplate;
	Var Result;

	Result = New Array();
	
	For Each Template In Templates Do
		
		NewTemplate = New Structure();
		NewTemplate.Insert( "name", Template.Name );
		NewTemplate.Insert( "desc", Template.Comment );
		NewTemplate.Insert( "template", Template.Template );
		NewTemplate.Insert( "methods", Methods(Template.Methods) );
		
		Result.Add( NewTemplate );
		
	EndDo;
	
	Return Result;

EndFunction

#EndRegion