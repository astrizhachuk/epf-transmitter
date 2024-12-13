// @strict-types

#Region EventHandlers

// Contract.
//
// Any form. The connection parameters are taken first from the Object, if it exists, and then from the form items.
// Parameter matching is performed by name (see ПолучателиКлиентСервер.ПараметрыСоединения).
// Connection.URL is overwritten by Form.ServiceURL. The service response is displayed on the form items:
// StatusCode, ResponseBody, and FileUploadStatus (see ПолучателиВызовСервера.ПолучитьСтатус).
//
// If there are no elements on the form, no exception is thrown.

&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	
	If ( TypeOf(CommandExecuteParameters.Source) <> Type("ClientApplicationForm") ) Then
		
		Return;
		
	EndIf;
	
	Form = CommandExecuteParameters.Source;
		
	If ( NOT Form.CheckFilling() ) Then
	
		Return;

	EndIf;
	
	Connector = ПолучателиКлиентСервер.ПараметрыСоединения();
	
	Fill( Connector, Form );
	
	SetResult( Form, ПолучателиВызовСервера.ПолучитьСтатус(Connector) );

EndProcedure

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&AtClient
Procedure SetUploadStatus( Val Form, Val Response )
	
	FILE_UPLOAD_ENABLED = NStr( "ru = 'загрузка файлов включена';en = 'file uploads enabled'" );
	
	If ( NOT ОбщегоНазначенияКлиентСервер.ЕстьРеквизитИлиСвойствоОбъекта(Form, "FileUploadStatus") ) Then
	
		Return;

	EndIf;
	
	Form.FileUploadStatus = ( StrFind(Response.ТелоОтвета, FILE_UPLOAD_ENABLED) > 0 );
		
EndProcedure

&AtClient
Procedure SetResult( Val Form, Val Response)
	
	FillPropertyValues( Form, Response );
	
	SetUploadStatus( Form, Response );
	
EndProcedure

&AtClient
Procedure Fill( Connection, Val Form )
	
	If ( ОбщегоНазначенияКлиентСервер.ЕстьРеквизитИлиСвойствоОбъекта(Form, "Объект") ) Then
		
		FillPropertyValues( Connection, Form.Объект );
			
	EndIf;
	
	FillPropertyValues( Connection, Form );
	
	If ( ОбщегоНазначенияКлиентСервер.ЕстьРеквизитИлиСвойствоОбъекта(Form, "ServiceURL") ) Then
		
		Connection.URL = Form.ServiceURL;
			
	EndIf;
	
EndProcedure

#КонецОбласти
