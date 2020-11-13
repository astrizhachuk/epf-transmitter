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
	Var DeletedData;
	Var QuestionText;
	Var Notify;
	
	CurrentData = Items.Commits.CurrentData;
	
	If ( CurrentData = Undefined ) Then
		
		Return;
		
	EndIf;
	
	If ( CurrentData.IsCustomSetting ) Then
		
		SetAllowEditJSON( CurrentData.IsCustomSetting );
		
	Else
		
		DeletedData = New Structure( "RecordKey, CurrentData", Parameters.RecordKey, CurrentData );
		Notify = New NotifyDescription( "DoAfterCloseQuestionResetSettings", ThisObject, DeletedData );
		QuestionText = NStr( "ru = 'Сбросить настройку маршрутизации на значение по умолчанию?';
							|en = 'Reset Routing Settings to default values?'" );
		ShowQueryBox( Notify, QuestionText, QuestionDialogMode.YesNo );
		
	EndIf;
	
EndProcedure

#EndRegion

#Область FormTableItemsEventHandlers

&AtClient
Procedure CommitsOnActivateRow( Element )
	
	If ( Element.CurrentData = Undefined ) Then
		
		Return;
		
	EndIf;
	
	SetAllowEditJSON( Element.CurrentData.IsCustomSetting );
	
EndProcedure

#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure ExecuteSaveJSON( Command )
	
	Var CurrentData;
	Var StoredData;
	Var Notify;
	Var QuestionText;
	
	CurrentData = Items.Commits.CurrentData;
	
	If ( CurrentData = Undefined ) Then
		
		Return;
		
	EndIf;

	StoredData = New Structure( "RecordKey, CurrentData", Parameters.RecordKey, CurrentData );
	
	If ( NOT IsCustomSettingsExists( Parameters.RecordKey, CurrentData.CommitSHA ) ) Then
		
		SaveJSON( StoredData );
		
	Else
		
		Notify = New NotifyDescription( "DoAfterCloseQuestionSaveJSON", ThisObject, StoredData );
		QuestionText = NStr( "ru = 'Пользовательская настройка уже существуют, перезаписать?';
							|en = 'Custom Settings already exist, overwrite?'" );
		ShowQueryBox( Notify, QuestionText, QuestionDialogMode.YesNo );
		
	EndIf;
	
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure SetFormType( Val CommandName )
	
	If ( CommandName = "OpenQueryJSON" ) Then

		ThisObject.IsQuery = True;
		ThisObject.Title = NStr( "ru = 'Запрос';en = 'Query'" );

	ElsIf ( CommandName = "OpenRoutingJSON" ) Then
		
		ThisObject.IsQuery = False;
		ThisObject.Title = NStr( "ru = 'Настройка маршрутизации';en = 'Routing Settings'" );
		
	Else

 		Raise NStr( "ru = 'Недопустимая команда открытия редактора JSON.';
 					|en = 'Invalid command to open JSON editor.'" );		
		
	EndIf;

EndProcedure

&AtServer
Procedure FillFormValues( Val RecordKey )
	
	Var QueryData;
	Var QueryCommits;
	Var Settings;
	Var CustomSettings;
	Var NewRaw;
	
	QueryData = ОбработчикиСобытий.LoadQueryData( RecordKey.ОбработчикСобытия, RecordKey.Ключ );
	
	If ( QueryData = Undefined ) Then
		
		Return;
		
	EndIf;
	
	If ( ThisObject.IsQuery ) Then
		
		NewRaw = ThisObject.Commits.Add();
		NewRaw.JSON = QueryData.Get( "json" );
		
	Else

		QueryCommits = QueryData.Get( "commits" );
		
		For Each Commit In QueryCommits Do
			
			NewRaw = ThisObject.Commits.Add();
			NewRaw.CommitSHA = Commit.Get( "id" );
			
			CustomSettings = Commit.Get( "custom_settings" );
			
			Settings = ?( CustomSettings = Undefined, Commit.Get("settings"),  CustomSettings );
			
			If ( Settings = Undefined ) Then

				Continue;
				
			EndIf;
			
			NewRaw.JSON = Settings.Get( "json" );
			NewRaw.IsCustomSetting = ( CustomSettings <> Undefined );
			
		EndDo;

	EndIf;

EndProcedure

&AtClient
Procedure SetFormElementsVisibility()
	
	If ( ThisObject.IsQuery ) Then
		
		Items.GroupCommits.Visible = False;
		Items.GroupCustomSettings.Visible = False;
		Items.CommitsQueryJSON.Visible = True;
		
	Else
		
		Items.CommitsRoutingJSON.Visible = True;
		
	EndIf;

EndProcedure

&AtClient
Procedure SetAllowEditJSON( Val Edit = False )
	
	Var EditorJSON;
	
	If ( ThisObject.IsQuery ) Then
		
		EditorJSON  = Items.CommitsQueryJSON;
		
	Else

		EditorJSON = Items.CommitsRoutingJSON;
		
	EndIf;
	
	EditorJSON.ReadOnly = ( NOT Edit );
	Items.SaveJSON.Enabled = Edit;
		
EndProcedure

&AtServerNoContext 
Function FindCommitById( Val QueryData, Val CommitSHA )
	
	Var QueryCommits;

	QueryCommits = QueryData.Get( "commits" );
	
	For Each Commit In QueryCommits Do

		If ( Commit.Get("id") <> CommitSHA ) Then
			
			Continue;
			
		EndIf;
		
		Return Commit;
		
	EndDo;
	
	Return New Map();
	
EndFunction

&AtServerNoContext
Procedure DeleteCustomSetting( Val RecordKey, Val CommitSHA, CurrentSetting )
	
	Var QueryData;
	Var Commit;
	Var DefaultSetting;

	QueryData = ОбработчикиСобытий.LoadQueryData( RecordKey.ОбработчикСобытия, RecordKey.Ключ );
	
	If ( NOT ValueIsFilled(QueryData) ) Then
		
		Return;
		
	EndIf;

	Commit = FindCommitById( QueryData, CommitSHA );
	DefaultSetting = Commit.Get( "settings" ).Get( "json" );
	
	If ( IsBlankString(DefaultSetting) OR DefaultSetting = CurrentSetting ) Then
		
		Return;
		
	EndIf;		

	Commit.Delete( "custom_settings" );				
	ОбработчикиСобытий.SaveQueryData( RecordKey.ОбработчикСобытия, RecordKey.Ключ, QueryData );
	
	CurrentSetting = DefaultSetting; 

EndProcedure

&AtClient
Procedure DoAfterCloseQuestionResetSettings( QuestionResult, AdditionalParameters ) Export
	
	Var CurrentData;
	
	CurrentData = AdditionalParameters.CurrentData;
	
	If ( QuestionResult = DialogReturnCode.No ) Then
		
		CurrentData.IsCustomSetting = True;
		
        Return;
        
	EndIf;

	DeleteCustomSetting( AdditionalParameters.RecordKey, CurrentData.CommitSHA, CurrentData.JSON );
	
	SetAllowEditJSON( False );

EndProcedure

&AtServerNoContext
Function IsCustomSettingsExists( Val RecordKey, Val CommitSHA )

	Var QueryData;
	Var Commit;
	
	QueryData = ОбработчикиСобытий.LoadQueryData( RecordKey.ОбработчикСобытия, RecordKey.Ключ );
	Commit = FindCommitById( QueryData, CommitSHA );
	
	Return ( Commit.Get("custom_settings") <> Undefined );
	
EndFunction

&AtServerNoContext
Procedure AddQueryDataCustomSetting( QueryData, Val CommitSHA, Val JSON ) Export
	
	Var Commit;
	Var CustomSetting;
	Var Stream;
	
	Commit = FindCommitById( QueryData, CommitSHA );

	Stream = GetBinaryDataFromString( JSON, TextEncoding.UTF8 ).OpenStreamForRead();
	CustomSetting = HTTPConnector.JsonВОбъект( Stream );
	CommonUseServerCall.AppendCollectionFromStream( CustomSetting, "json", Stream );
	
	Commit.Вставить( "custom_settings", CustomSetting );		

EndProcedure

&AtServerNoContext
Procedure SaveJSONAtServer( Val RecordKey, Val CommitSHA, Val JSON )
	
	Var QueryData;
	
	QueryData = ОбработчикиСобытий.LoadQueryData( RecordKey.ОбработчикСобытия, RecordKey.Ключ );
	
	If ( QueryData = Undefined ) Then
		
		Return;
		
	EndIf;
	
	AddQueryDataCustomSetting( QueryData, CommitSHA, JSON );
	
	ОбработчикиСобытий.SaveQueryData( RecordKey.ОбработчикСобытия, RecordKey.Ключ, QueryData );	

EndProcedure

&AtClient
Procedure SaveJSON( Val StoredData )
	
	Var CurrentData;
	Var ErrorInfo;
	Var CauseText;
	Var Additional; 
	
	Try
		
		CurrentData = StoredData.CurrentData;
		SaveJSONAtServer( StoredData.RecordKey, CurrentData.CommitSHA, CurrentData.JSON );
		
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

&AtClient
Procedure DoAfterCloseQuestionSaveJSON( QuestionResult, AdditionalParameters ) Export
	
	If ( QuestionResult = DialogReturnCode.No ) Then
		
        Return;
        
    EndIf;

	SaveJSON( AdditionalParameters );

EndProcedure

#EndRegion