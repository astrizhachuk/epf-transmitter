#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer( Cancel, StandardProcessing )
	
	Var CurrentSettings;
	
	CurrentSettings = ServicesSettings.GetCurrentSettings();
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
Procedure CheckServiceStatus( Command )
	
	OpenForm( "CommonForm.CheckingServiceStatus", , , , , , , FormWindowOpeningMode.Independent );

EndProcedure

#EndRegion

#Region Private

&AtClient
Function WriteDataForm()
	
	Var Settings;
	Var Result;

	Result = False;
	
	If ( CheckFilling() ) Then
		
		Settings = ServicesSettingsClientServer.Settings();
		FillPropertyValues( Settings, ThisObject );
		SaveSettings( Settings );
		RefreshInterface();
		
		Result = True;
		
	EndIf;
	
	Return Result;
	
EndFunction

&AtServerNoContext
Procedure SaveSettings( Val Settings )
	
	ServicesSettings.SetCurrentSettings( Settings );
	
EndProcedure

#EndRegion
