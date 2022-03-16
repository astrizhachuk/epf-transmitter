#Region Public

// Create returns a new initialized external request object.
// 
// Parameters:
//	Source - String, Structure - data source: JSON or deserialized object (see DataProcessor.ExternalRequest.ToCollect);
// 	Type - String - request source type, only for source with type String;
// 	
// Returns:
// 	DataProcessorObject.ExternalRequest - new external request;
//
Function Create( Val Source, Val Type = Undefined ) Export
	
	Var Result;	

	Result = DataProcessors.ExternalRequest.Create();

	If ( TypeOf(Source) = Type("Structure") ) Then
		
		Result.Load( Source );
	
		Return Result;
		
	Else
	
		If ( Upper(Type) = "GITLAB" ) Then
	
			Result.Type = Enums.RequestSource.GitLab;
			Result.Fill( Source );
			
			Return Result;
			
		EndIf;
	
	EndIf;
	
	Raise NStr( "ru = 'неизвестный тип источника запроса';en = 'unknown request source type'" );

EndFunction

// GetObjectFromIB returns an instance of the external request stored in the infobase.
// 
// Parameters:
// 	RequestHandler - CatalogRef.ExternalRequestHandlers - ref to external request handler;
//  CheckoutSHA - String - event identifier;
// 	
// Returns:
// 	- Undefined - no data found;
// 	- DataProcessorObject.ExternalRequest - external request instance;
//
Function GetObjectFromIB( Val RequestHandler, Val CheckoutSHA ) Export
	
	Var Data;
	
	Data = GetDataFromIB( RequestHandler, CheckoutSHA );
	
	If ( Data = Undefined ) Then
		
		Return Data;
		
	EndIf;
	
	Return Create( Data );

EndFunction

// SaveObject saves the deserialized external request in the infobase.
// 
// Parameters:
// 	RequestHandler - CatalogRef.ExternalRequestHandlers - ref to external request handler;
//  CheckoutSHA - String - event identifier;
// 	ExternalRequest - DataProcessorObject.ExternalRequest - external request instance;
//
Procedure SaveObject( Val RequestHandler, Val CheckoutSHA, Val ExternalRequest ) Export
	
	InformationRegisters.ExternalRequests.SaveData( RequestHandler,	CheckoutSHA, ExternalRequest.ToCollection() );

EndProcedure

#EndRegion

#Region Private

// GetDataFromIB returns the deserialized request body stored in the infobase. 
// 
// Parameters:
// 	RequestHandler - CatalogRef.ExternalRequestHandlers - ref to external request handler;
//  CheckoutSHA - String - event identifier;
// 	
// Returns:
// 	- Undefined - no data found;
// 	- Structure - deserialized request body;
// 	
Function GetDataFromIB( Val RequestHandler, Val CheckoutSHA )
	
	Var Filter;
	
	Filter = New Structure();
	Filter.Insert( "RequestHandler", RequestHandler );
	Filter.Insert( "CheckoutSHA", CheckoutSHA );
	
	Return InformationRegisters.ExternalRequests.Get(Filter).Data.Get();

EndFunction

#EndRegion
