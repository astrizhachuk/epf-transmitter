#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer( Cancel, StandardProcessing )
	
	Var CurrentSettings;
	
	CurrentSettings = НастройкаСервисов.CurrentSettings();
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
Процедура WriteAtServer()
	
	SetPrivilegedMode( True );
	
	Constants.ОбрабатыватьЗапросыВнешнегоХранилища.Set( ThisObject.ОбрабатыватьЗапросыВнешнегоХранилища );
	Constants.GitLabUserPrivateToken.Set( ThisObject.GitLabUserPrivateToken );
	Constants.ИмяФайлаНастроекМаршрутизации.Set( ThisObject.ИмяФайлаНастроекМаршрутизации );
	Constants.AccessTokenReceiver.Set( ThisObject.AccessTokenReceiver );
	Constants.ТаймаутGitLab.Set( ThisObject.ТаймаутGitLab );
	Constants.ТаймаутДоставкиФайла.Set( ThisObject.ТаймаутДоставкиФайла );
	
	SetPrivilegedMode( False );
	
КонецПроцедуры

#EndRegion
