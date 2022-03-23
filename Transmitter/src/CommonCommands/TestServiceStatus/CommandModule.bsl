#Region EventHandlers

// Contract.
//
// Any form. The connection parameters are taken first from the Object, if it exists, and then from the form items.
// Parameter matching is performed by name (see EndpointsClientServer.GetConnectionParams).
// Connection.URL is overwritten by Form.ServiceURL. The service response is displayed on the form items:
// StatusCode, ResponseBody, and FileUploadStatus (see EndpointsServerCall.GetServiceStatus).
//
// If there are no elements on the form, no exception is thrown.

&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	
	Var Form;
	Var Connector;
	
	If ( TypeOf(CommandExecuteParameters.Source) <> Type("ClientApplicationForm") ) Then
		
		Return;
		
	EndIf;
	
	Form = CommandExecuteParameters.Source;
		
	If ( NOT Form.CheckFilling() ) Then
	
		Return;

	EndIf;
	
	Connector = EndpointsClientServer.GetConnectionParams();
	
	Fill( Connector, Form );
	
	SetResult( Form, EndpointsServerCall.GetServiceStatus(Connector) );

EndProcedure

#EndRegion

#Region Private

&AtClient
Procedure SetUploadStatus( Val Form, Val Response )
	
	FILE_UPLOAD_ENABLED = NStr( "ru = 'загрузка файлов включена';en = 'file uploads enabled'" );
	
	If ( NOT CommonUseClientServer.HasObjectAttributeOrProperty(Form, "FileUploadStatus") ) Then
	
		Return;

	EndIf;
	
	Form.FileUploadStatus = ( StrFind(Response.ResponseBody, FILE_UPLOAD_ENABLED) > 0 );
		
EndProcedure

&AtClient
Procedure SetResult( Val Form, Val Response)
	
	FillPropertyValues( Form, Response );
	
	SetUploadStatus( Form, Response );
	
EndProcedure

&AtClient
Procedure Fill( Connection, Val Form )
	
	If ( CommonUseClientServer.HasObjectAttributeOrProperty(Form, "Object") ) Then
		
		FillPropertyValues( Connection, Form.Object );
			
	EndIf;
	
	FillPropertyValues( Connection, Form );
	
	If ( CommonUseClientServer.HasObjectAttributeOrProperty(Form, "ServiceURL") ) Then
		
		Connection.URL = Form.ServiceURL;
			
	EndIf;
	
EndProcedure

#EndRegion
