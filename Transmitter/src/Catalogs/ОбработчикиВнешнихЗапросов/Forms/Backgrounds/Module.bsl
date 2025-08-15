// @strict-types

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer( Cancel, StandardProcessing )

	If ( Parameters.КлючЗаписи.IsEmpty() ) Then
		
		Return;
		
	EndIf;

	FillBackgroundsList( Parameters.КлючЗаписи );

EndProcedure

#КонецОбласти

#Region FormCommandsEventHandlers

&AtClient
Procedure RefreshAll( Command )
	
	FillBackgroundsList( Parameters.КлючЗаписи );
	
EndProcedure

&AtClient
Procedure RefreshCurrent( Command )
	
	Var CurrentData;
	
	CurrentData = Items.Backgrounds.CurrentData;
	
	If ( CurrentData = Undefined ) Then
		
		Return;
		
	EndIf;
	
	Job = GetCurrentState( CurrentData.UUID );

	If ( Job = Undefined ) Then
		
		Return;
		
	EndIf;
	
	FillPropertyValues( CurrentData, Job );
	
EndProcedure

&AtClient
Procedure KillCurrent( Command )
	
	Var CurrentData;
	Var Job;
	
	CurrentData = Items.Backgrounds.CurrentData;
	
	If ( CurrentData = Undefined ) Then
		
		Return;
		
	EndIf;

	Job = CancelJob( CurrentData.UUID );
	
	If ( Job = Undefined ) Then
		
		Return;
		
	EndIf;
	
	FillPropertyValues( CurrentData, Job );
	
EndProcedure

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&AtServer
Procedure FillBackgroundsList( Val КлючЗаписи )
	
	Var List;
	Var Jobs;
	
	List = FormAttributeToValue( "BackgroundsList" );

	List.Clear();

	Jobs = ОбработкаДанных.ПолучитьФоновыеЗаданияПоИдентификатору( КлючЗаписи.Идентификатор );

	For Each Job In Jobs Do
		
		NewBackground = List.Add();
		FillJobValues( NewBackground, Job );
		
	EndDo;
	
	List.Sort( "Begin DESC, MethodName DESC" );
	
	ValueToFormAttribute( List, "BackgroundsList" );	

EndProcedure

&AtServerNoContext
Function GetCurrentState( Val UUID )
	
	Return GetJobDetails( FindJob(UUID) );

EndFunction

&AtServerNoContext
Function CancelJob( Val UUID )
	
	Var Job;
	
	Job = FindJob( UUID );
	
	Cancel( Job );
	
	Return GetJobDetails( Job );

EndFunction

&AtServerNoContext
Function Job()
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "UUID" );
	Result.Insert( "State" );
	Result.Insert( "Key" );
	Result.Insert( "MethodName" );
	Result.Insert( "Begin" );
	Result.Insert( "End" );
	Result.Insert( "ErrorDetail" );
	
	Return Result;
	
EndFunction

&AtServerNoContext
Procedure FillJobValues( Result, Val Job)
	
	FillPropertyValues( Result, Job );
	
	Result.State = String( Job.State );
	
	If ( Job.ErrorInfo <> Undefined ) Then
		
		Result.ErrorDetail = ErrorProcessing.DetailErrorDescription( Job.ErrorInfo );
		
	EndIf;
	
EndProcedure

&AtServerNoContext
Function GetJobDetails( Val Job )
	
	Var Result;
	
	If ( Job = Undefined ) Then
		
		Return Undefined;
		
	EndIf;
	
	Result = Job();
	
	FillJobValues( Result, Job );
	
	Return Result;
	
EndFunction

&AtServerNoContext
Function FindJob( Val UUID )
	
	SetPrivilegedMode( True );
	
	Return BackgroundJobs.FindByUUID( UUID );
	
EndFunction

&AtServerNoContext
Procedure Cancel( Job )
	
	If ( Job = Undefined ) Then
		
		Return;
		
	EndIf;
	
	If ( Job.State = BackgroundJobState.Active ) Then

		SetPrivilegedMode( True );
		Job.Cancel();
		Job = Job.WaitForExecutionCompletion();

	EndIf;
	
EndProcedure

#КонецОбласти
