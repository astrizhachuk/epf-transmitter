#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer( Cancel, StandardProcessing )

	If ( Parameters.RecordKey.IsEmpty() ) Then
		
		Return;
		
	EndIf;

	FillBackgroundJobs( Parameters.RecordKey );
	
EndProcedure

#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure RefreshBackgroundJobs( Command )
	
	FillBackgroundJobs( Parameters.RecordKey );
	
EndProcedure

&AtClient
Procedure RefreshSelectedBackgroundJob( Command )
	
	Var CurrentData;
	
	CurrentData = Items.BackgroundJobs.CurrentData;
	
	If ( CurrentData = Undefined ) Then
		
		Return;
		
	EndIf;
	
	RefreshSelectedBackgroundJobAtServer( CurrentData.GetID(), CurrentData.UUID );
	
EndProcedure

&AtClient
Procedure KillSelectedBackgroundJob( Command )
	
	Var CurrentData;
	
	CurrentData = Items.BackgroundJobs.CurrentData;
	
	If ( CurrentData = Undefined ) Then
		
		Return;
		
	EndIf;

	KillSelectedBackgroundJobAtServer( CurrentData.GetID(), CurrentData.UUID );
	
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure KillSelectedBackgroundJobAtServer( Val Id, Val UUID )
	
	Var BackgroundJobId;
	Var FindedBackgroundJob;
	
	BackgroundJobId = New UUID( UUID );
	
	If ( NOT PrivilegedMode() ) Then
		
		SetPrivilegedMode( True );
		
	EndIf;
	
	FindedBackgroundJob = ФоновыеЗадания.FindByUUID( BackgroundJobId );
	
	If ( FindedBackgroundJob = Undefined ) Then
		
		Return;
		
	EndIf;
	
	If ( FindedBackgroundJob.State = BackgroundJobState.Active ) Then

		FindedBackgroundJob.Cancel();
		FindedBackgroundJob.WaitForExecutionCompletion();

	EndIf;

	RefreshSelectedBackgroundJobAtServer( Id, UUID )
	
EndProcedure

&AtServer
Procedure RefreshSelectedBackgroundJobAtServer( Val Id, Val UUID )
	
	Var BackgroundJobId;
	Var FindedBackgroundJob;
	Var BackgroundJobInList;
	
	BackgroundJobId = New UUID( UUID );
	
	If ( NOT PrivilegedMode() ) Then
		
		SetPrivilegedMode( True );
		
	EndIf;
	
	FindedBackgroundJob = ФоновыеЗадания.FindByUUID( BackgroundJobId );
	
	If ( FindedBackgroundJob = Undefined ) Then
		
		Return;
		
	EndIf;
	
	BackgroundJobInList = BackgroundJobs.FindByID( Id );
	
	FillPropertyValues( BackgroundJobInList, FindedBackgroundJob );
		
	If ( FindedBackgroundJob.ErrorInfo <> Undefined ) Then
		
		BackgroundJobInList.ErrorInfo = ErrorProcessing.DetailErrorDescription( FindedBackgroundJob.ErrorInfo );
		
	EndIf;
	
EndProcedure

&AtServerNoContext
Function BackgroundJobsByKey( Val Key )
	
	Var Filter;
	Var BackgroundJobsFindByName;
	Var Result;
	
	If ( NOT PrivilegedMode() ) Then
		
		SetPrivilegedMode( True );
		
	EndIf;
		
	Filter = New Structure( "MethodName, Key", "ОбработкаДанных.ОбработатьДанные", Key );
	Result = ФоновыеЗадания.GetBackgroundJobs( Filter );
	
	Filter = New Structure( "MethodName, Description", "Получатели.ОтправитьФайл", Key );
	BackgroundJobsFindByName = ФоновыеЗадания.GetBackgroundJobs( Filter );
	
	For Each Value In BackgroundJobsFindByName Do
		
		Result.Add( Value );
		
	EndDo;
	
	Return Result;
	
EndFunction

&AtServer
Procedure FillBackgroundJobs( Val RecordKey )
	
	Var BackgroundJobsList;
	Var BackgroundJobsByKey;
	
	BackgroundJobsList = ThisObject.FormAttributeToValue( "BackgroundJobs" );
	BackgroundJobsList.Clear();

	BackgroundJobsByKey = BackgroundJobsByKey( RecordKey.Ключ );

	For Each BackgroundJob In BackgroundJobsByKey Do
		
		NewBackgroundJob = BackgroundJobsList.Add();
		
		FillPropertyValues( NewBackgroundJob, BackgroundJob );
		
		If ( BackgroundJob.ErrorInfo <> Undefined ) Then
			
			NewBackgroundJob.ErrorInfo = ErrorProcessing.DetailErrorDescription( BackgroundJob.ErrorInfo );
			
		EndIf;
		
	EndDo;
	
	BackgroundJobsList.Sort( "Begin DESC, State" );
	
	ThisObject.ValueToFormAttribute( BackgroundJobsList, "BackgroundJobs" );	

EndProcedure

#EndRegion
