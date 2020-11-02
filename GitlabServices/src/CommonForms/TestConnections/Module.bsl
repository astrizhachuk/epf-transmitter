#Region FormHeaderItemsEventHandlers

&AtClient
Procedure Test( Command )
	
	Var ServiceTestResult;
	
	ThisObject.ResponseBody = "";
	
	If ( NOT CheckFilling() ) Then
	
		Return;

	EndIf;

	Try

		ServiceTestResult = TestConnection( ThisObject.ServiceURL );

	Except
		
		ServiceTestResult = ServiceTestResult();
		ServiceTestResult.Error = True;

	EndTry;
	
	ThisObject.TestResult = FormattedTestResult( ServiceTestResult );
	ThisObject.ResponseBody = ServiceTestResult.ResponseBody;
	
EndProcedure

#EndRegion

#Region Private

&AtClientAtServerNoContext
Function ServiceTestResult()
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "Existed", False );
	Result.Insert( "Enabled", False );
	Result.Insert( "Error", False );
	Result.Insert( "ResponseBody", "" );
	
	Return Result;
	
EndFunction

&AtServerNoContext
Function TestConnection( Val URL )
	
	Var ServiceDescription;
	Var Services;
	Var IsEnabled;
	
	ServiceDescription = HTTPСервисы.ОписаниеСервисаURL( URL );
	
	Result = ServiceTestResult();
	
	If ( ServiceDescription = Undefined ) Then
		
		Result.Error = True;

		Return Result;
		
	EndIf;
	
	Services = ServiceDescription.Data.Get( "services" );
	
	If ( Services = Undefined ) Then
		
		Return Result;
		
	EndIf;
	
	Result.Existed = True;
	IsEnabled = Services.Get( "enabled" );
	Result.Enabled = ?( IsEnabled = Undefined, False, IsEnabled );
	Result.ResponseBody = ServiceDescription.json;
	
	Return Result;

EndFunction

&AtClient
Function FormattedTestResult( Val ServiceTestResult )
	
	Var Messages;
	
	CONNECTION_ERROR_MESSAGE = НСтр( "ru = 'Ошибка подключения.';en = 'Connection error.'" );
	SERVICE_IS_AVAILABLE_MESSAGE = НСтр( "ru = 'Сервис доступен.';en = 'Service is available.'" );
	SERVICE_IS_NOT_AVAILABLE_MESSAGE = НСтр( "ru = 'Сервис недоступен.';en = 'Service is not available.'" );
	SERVICE_ENABLED_MESSAGE = НСтр( "ru = ' Статус работы: включен.';en = ' Service is enabled.'" );
	SERVICE_NOT_ENABLED_MESSAGE = НСтр( "ru = ' Статус работы: выключен.';en = ' Service is disabled.'" );
	
	Messages = New Array();
	
	If ( ServiceTestResult.Error ) Then
		
		Messages.Add( New FormattedString(CONNECTION_ERROR_MESSAGE, , WebColors.Red) );
		
	Else
		
		If ( ServiceTestResult.Existed ) Then
			
			Messages.Add( New FormattedString(SERVICE_IS_AVAILABLE_MESSAGE, , WebColors.Green) );
			
			If ( ServiceTestResult.Enabled ) Then
				
				Messages.Add( New FormattedString(SERVICE_ENABLED_MESSAGE, , WebColors.Green) );
				
			Else
				
				Messages.Add( New FormattedString(SERVICE_NOT_ENABLED_MESSAGE, , WebColors.Red) );
				
			EndIf;
			
		Else
			
			Messages.Add( New FormattedString(SERVICE_IS_NOT_AVAILABLE_MESSAGE, , WebColors.Red) );
			
		EndIf;
		
	EndIf; 
	
	Return New FormattedString( Messages );
	
EndFunction

#EndRegion
