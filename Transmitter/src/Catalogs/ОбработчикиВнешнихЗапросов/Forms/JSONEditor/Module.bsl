// @strict-types

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer( Cancel, StandardProcessing )
	
	If ( Parameters.RecordKey.IsEmpty() ) Then
		
		Return;
		
	EndIf;
	
	SetFormType( Parameters.CommandName );
	InitFormValues( Parameters.RecordKey );

EndProcedure

&AtClient
Procedure OnOpen( Cancel )

	SetVisibility();
	
EndProcedure

#КонецОбласти

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure CommitsIsCustomOnChange( Element )
	
	Var CurrentData;
	
	CurrentData = Items.Commits.CurrentData;
	
	If ( CurrentData = Undefined ) Then
		
		Return;
		
	EndIf;
	
	If ( CurrentData.IsCustom ) Then
		
		SetEditorAccessibility( CurrentData.IsCustom );
		
	Else
		
		ResetSettings( CurrentData );
		
	EndIf;
	
EndProcedure

#КонецОбласти

#Область FormTableItemsEventHandlers

&AtClient
Procedure CommitsOnActivateRow( Element )
	
	If ( Element.CurrentData = Undefined ) Then
		
		Return;
		
	EndIf;
	
	SetEditorAccessibility( Element.CurrentData.IsCustom );
	
EndProcedure

#КонецОбласти

#Region FormCommandsEventHandlers

&AtClient
Procedure Save( Command )
	
	Var CurrentData;
	
	CurrentData = Items.Commits.CurrentData;
	
	If ( CurrentData = Undefined ) Then
		
		Return;
		
	EndIf;

	SaveRoutes( GetRecord(CurrentData) );
		
EndProcedure

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&AtClient
Function GetRecord( Val CurrentData )
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "RecordKey", Parameters.RecordKey );
	Result.Insert( "CurrentData", CurrentData );
	
	Return Result;
	
EndFunction

&AtServer
Procedure SetRoutes( Val ExternalRequest )
	
	Var NewRoute;
	
	For Each Commit In ExternalRequest.ПолучитьСвойстваСхемМаршрутовКИсполнению() Do
		
		NewRoute = Routing.Add();
		NewRoute.Id = Commit.Key;
		NewRoute.JSON = Commit.Value.JSON;
		NewRoute.IsCustom = Commit.Value.IsCustom;
		
	EndDo;
	
EndProcedure

&AtServer
Procedure InitFormValues( Val RecordKey )
	
	Var ExternalRequest;

	ExternalRequest = ВнешниеЗапросы.Восстановить( RecordKey.RequestHandler, RecordKey.CheckoutSHA );
	
	If ( ExternalRequest = Undefined ) Then
		
		Return;
		
	EndIf;
	
	If ( IsRequest ) Then
		
		RequestJSON = ExternalRequest.ПолучитьТело();
		
	Else
		
		SetRoutes( ExternalRequest );

	EndIf;

EndProcedure

#Region Appearance

&AtServer
Procedure SetFormType( Val CommandName )
	
	If ( CommandName = "OpenRequest" ) Then

		IsRequest = True;
		Title = NStr( "ru = 'Запрос';en = 'Query'" );

	ElsIf ( CommandName = "OpenRoutingSettings" ) Then
		
		IsRequest = False;
		Title = NStr( "ru = 'Маршрутизация';en = 'Routing'" );
		
	Else

 		Raise NStr( "ru = 'Недопустимая команда открытия редактора JSON.';
 					|en = 'Invalid command to open JSON editor.'" );		
		
	EndIf;

EndProcedure

&AtClient
Procedure SetVisibility()
	
	Items.GroupCommits.Visible = ( NOT IsRequest );
	Items.GroupCustomSettings.Visible = ( NOT IsRequest );
	Items.RequestJSON.Visible = IsRequest;
	Items.RoutingJSON.Visible = ( NOT IsRequest );
		
EndProcedure

&AtClient
Procedure SetEditorAccessibility( Val Edit )
	
	Items.GroupEditor.ReadOnly = ( NOT Edit );
	Items.Save.Enabled = Edit;
		
EndProcedure

#КонецОбласти

#Region Settings

&AtClient
Procedure ResetSettings( Val CurrentData )
	
	Var Data;
	Var Notify;
	Var Question;
	
	Data = GetRecord( CurrentData );
	
	Notify = New NotifyDescription( "DoAfterCloseQuestionResetSettings", ThisObject, Data );
	Question = NStr( "ru = 'Сбросить настройку маршрутизации на значение по умолчанию?';
					|en = 'Reset Routing Settings to default values?'" );
	
	ShowQueryBox( Notify, Question, QuestionDialogMode.YesNo );
	
EndProcedure

&AtClient
Procedure DoAfterCloseQuestionResetSettings( QuestionResult, AdditionalParameters ) Export
	
	Var CurrentData;
	
	CurrentData = AdditionalParameters.CurrentData;
	
	If ( QuestionResult = DialogReturnCode.No ) Then
		
		CurrentData.IsCustom = True;
		
        Return;
        
	EndIf;

	CurrentData.JSON = RemoveCustomRoute( AdditionalParameters.RecordKey, CurrentData.Id );

	SetEditorAccessibility( CurrentData.IsCustom );
	
EndProcedure

&AtServerNoContext
Function RemoveCustomRoute( Val RecordKey, Val Id )
	
	Return ВнешниеЗапросы.УдалитьПользовательскуюСхемуМаршрутов( RecordKey.RequestHandler, RecordKey.CheckoutSHA, Id );
	
EndFunction

#КонецОбласти

#Region Save

&AtClient
Procedure SaveRoutes( Val Data )
	
	Var ErrorInfo;
	Var CauseText;
	Var Additional; 
	
	Try

		AddCustomRoute( Data.RecordKey, Data.CurrentData.Id, Data.CurrentData.JSON );
		
	Except
		
		CauseText = NStr( "ru = 'Непредвиденный символ при чтении JSON';en = 'Unexpected token during JSON reading'" );
		
		ErrorInfo = ErrorInfo();

		If ( ErrorInfo.IsErrorOfCategory(ErrorCategory.ScriptRuntimeError)
			AND ErrorProcessing.BriefErrorDescription(ErrorInfo) = CauseText ) Then
	
			Additional = NStr( "ru = 'Текст должен быть в формате JSON.';en = 'The text must be in JSON-format.'" );
			ErrorProcessing.ShowErrorInfo( ErrorInfo, ErrorMessageDisplayVariant.BriefErrorDescription, Additional );
	
		Else
			
			ErrorProcessing.ShowErrorInfo( ErrorInfo );
			
		EndIf;
		
	EndTry;
	
EndProcedure

&AtServerNoContext
Procedure AddCustomRoute( Val RecordKey, Val Id, Val JSON )
	
	ВнешниеЗапросы.СохранитьПользовательскуюСхемуМаршрутов( RecordKey.RequestHandler, RecordKey.CheckoutSHA, Id, JSON );
	
EndProcedure

#КонецОбласти

#КонецОбласти