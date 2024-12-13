// @strict-types

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer( Cancel, StandardProcessing )
	
	Var CurrentSettings;
	
	CurrentSettings = НастройкиСервисов.ПолучитьНастройкиСервисаОбработкиЗапросаГитлаб();
	FillPropertyValues( ThisObject, CurrentSettings );

EndProcedure

#КонецОбласти

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

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&AtClient
Function WriteDataForm()
	
	Var Settings;
	Var Result;

	Result = False;
	
	If ( CheckFilling() ) Then
		
		Settings = НастройкиСервисовКлиентСервер.НастройкиСервисаОбработкиЗапросаГитлаб();
		FillPropertyValues( Settings, ThisObject );
		SaveSettings( Settings );
		RefreshInterface();
		
		Result = True;
		
	EndIf;
	
	Return Result;
	
EndFunction

&AtServerNoContext
Procedure SaveSettings( Val Settings )
	
	НастройкиСервисов.УстановитьНастройкиСервисаОбработкиЗапросаГитлаб( Settings );
	
EndProcedure

#КонецОбласти
