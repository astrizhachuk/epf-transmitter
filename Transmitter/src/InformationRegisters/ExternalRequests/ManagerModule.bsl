#Region Public

// SaveData saves the serializable data to the appropriate ValueStorage resource.
// 
// Parameters:
// 	RequestHandler - CatalogRef.ExternalRequestHandlers - ref to external request handler;
//  CheckoutSHA - String - event identifier;
// 	Data - Arbitrary - serializable data;
//
Procedure SaveData( Val RequestHandler, Val CheckoutSHA, Val Data ) Export
	
	Var RecordSet;
	Var Record;

	Data = New ValueStorage( Data );

	RecordSet = CreateRecordSet();
	RecordSet.Filter.RequestHandler.Set( RequestHandler );
	RecordSet.Filter.CheckoutSHA.Set( CheckoutSHA );

	Record = RecordSet.Add();

	Record.RequestHandler = RequestHandler;
	Record.CheckoutSHA = CheckoutSHA;
	Record.Data = Data;
	
	RecordSet.Write(True);

EndProcedure

#EndRegion
