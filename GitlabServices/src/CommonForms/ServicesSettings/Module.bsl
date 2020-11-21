#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer( Cancel, StandardProcessing )
	
	Var CurrentSettings;
	
	CurrentSettings = ServicesSettings.CurrentSettings();
	FillPropertyValues( ThisObject, CurrentSettings );

EndProcedure

#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure Write( Command )
	
	WriteDataForm();
	
EndProcedure

&AtClient
Procedure WriteAndClose( Command )
	
	If ( WriteDataForm() ) Then
		
		Close();
		
	EndIf;

EndProcedure

&AtClient
Procedure TestConnections( Command )
	
	OpenForm( "CommonForm.TestConnections", , , , , , , FormWindowOpeningMode.Independent );

EndProcedure

#EndRegion

#Region Private

&AtClient
Функция WriteDataForm()
	
	Var Result;

	Result = False;
	
	If ( CheckFilling() ) Then
		
		WriteAtServer();
		RefreshInterface();
		
		Result = True;
		
	EndIf;
	
	Return Result;
	
КонецФункции

&AtServer
Procedure WriteAtServer()
	
	SetPrivilegedMode( True );
	
	Constants.HandleRequests.Set( ThisObject.HandleRequests );
	Constants.TokenGitLab.Set( ThisObject.TokenGitLab );
	Constants.RoutingFileName.Set( ThisObject.RoutingFileName );
	Constants.TokenReceiver.Set( ThisObject.TokenReceiver );
	Constants.TimeoutGitLab.Set( ThisObject.TimeoutGitLab );
	Constants.TimeoutDeliveryFile.Set( ThisObject.TimeoutDeliveryFile );
	
	SetPrivilegedMode( False );
	
EndProcedure

#EndRegion
