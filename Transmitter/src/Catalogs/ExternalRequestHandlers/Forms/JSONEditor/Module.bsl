#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer( Cancel, StandardProcessing )
	
	If ( Parameters.RecordKey.IsEmpty() ) Then
		
		Return;
		
	EndIf;
	
	SetFormType( Parameters.CommandName );
	FillFormValues( Parameters.RecordKey );

EndProcedure

&AtClient
Procedure OnOpen( Cancel )

	SetFormElementsVisibility();
	
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure CommitsIsCustomSettingOnChange( Element )
	
	Var CurrentData;
	
	CurrentData = Items.Commits.CurrentData;
	
	If ( CurrentData = Undefined ) Then
		
		Return;
		
	EndIf;
	
	If ( CurrentData.IsCustomSetting ) Then
		
		SetEditorAccessibility( CurrentData.IsCustomSetting );
		
	Else
		
		ResetSettings( CurrentData );
		
	EndIf;
	
EndProcedure

#EndRegion

#Область FormTableItemsEventHandlers

&AtClient
Procedure CommitsOnActivateRow( Element )
	
	If ( Element.CurrentData = Undefined ) Then
		
		Return;
		
	EndIf;
	
	SetEditorAccessibility( Element.CurrentData.IsCustomSetting );
	
EndProcedure

#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure SaveSettings( Command )
	
	Var CurrentData;
	
	CurrentData = Items.Commits.CurrentData;
	
	If ( CurrentData = Undefined ) Then
		
		Return;
		
	EndIf;

	Save( SelectedData(CurrentData) );
		
EndProcedure

#EndRegion

#Region Private

&AtClient
Function SelectedData( Val CurrentData )
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "RecordKey", Parameters.RecordKey );
	Result.Insert( "CurrentData", CurrentData );
	
	Return Result;
	
EndFunction

&AtServer
Procedure FillRouting( Val RequestData )
	
	Var Commits;

	Commits = ExternalRequests.GetCommitsOrRaise( RequestData );
	
	For Each Commit In Commits Do
		
		AddSettings( Commit );
		
	EndDo;
	
EndProcedure

&AtServer
Procedure AddSettings( Val Commit )
	
	Var NewRoute;

	NewRoute = Routing.Add();
	
	NewRoute.CommitSHA = Commit.Get( "id" );
	
	Settings = ExternalRequests.GetCustomSettingsJSON( Commit );
	
	If ( Settings <> Undefined ) Then
		
		NewRoute.JSON = Settings;
		NewRoute.IsCustomSetting = True;
	
	Else
		
		NewRoute.JSON = ExternalRequests.GetDefaultSettingsJSON( Commit );
		NewRoute.IsCustomSetting = False;
		
	EndIf;
	
EndProcedure

&AtServer
Procedure FillFormValues( Val RecordKey )
	
	Var RequestData;

	RequestData = ExternalRequests.GetFromIB( RecordKey.RequestHandler, RecordKey.CheckoutSHA );
	
	If ( RequestData = Undefined ) Then
		
		Return;
		
	EndIf;
	
	If ( IsRequest ) Then
		
		RequestJSON = RequestData.Get( "json" );
		
	Else
		
		FillRouting( RequestData );

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
Procedure SetFormElementsVisibility()
	
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

#EndRegion

#Region Settings

&AtClient
Procedure ResetSettings( Val CurrentData )
	
	Var Data;
	Var Notify;
	Var Question;
	
	Data = SelectedData( CurrentData );
	
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
		
		CurrentData.IsCustomSetting = True;
		
        Return;
        
	EndIf;

	CurrentData.JSON = RemoveCustomSettings( AdditionalParameters.RecordKey, CurrentData.CommitSHA );

	SetEditorAccessibility( CurrentData.IsCustomSetting );
	
EndProcedure

&AtServerNoContext
Function RemoveCustomSettings( Val RecordKey, Val CommitSHA )
	
	Return ExternalRequests.RemoveCustomRoutingSettings(RecordKey.RequestHandler, RecordKey.CheckoutSHA, CommitSHA );
	
EndFunction

#EndRegion

#Region Save

&AtClient
Procedure Save( Val Data )
	
	Var ErrorInfo;
	Var CauseText;
	Var Additional; 
	
	Try

		SaveAtServer( Data.RecordKey, Data.CurrentData.CommitSHA, Data.CurrentData.JSON );
		
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
Procedure SaveAtServer( Val RecordKey, Val CommitSHA, Val JSON )
	
	Var RequestData;
	
	RequestData = ExternalRequests.GetFromIB( RecordKey.RequestHandler, RecordKey.CheckoutSHA );
	
	If ( RequestData = Undefined ) Then
		
		Return;
		
	EndIf;
	
	ExternalRequests.AppendCustomRoutingSettings( RequestData, CommitSHA, JSON );
	
	InformationRegisters.ExternalRequests.SaveData( RecordKey.RequestHandler, RecordKey.CheckoutSHA, RequestData );
	
EndProcedure

#EndRegion

#EndRegion