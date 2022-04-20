// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure Settings(Framework) Export
	
	// given
	Result = Undefined;
	
	// when
	Result = ServicesSettingsClientServer.Settings();
	
	// then
	Framework.AssertEqual(Result.Count(), 7);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure CurrentSettings(Framework) Export

	// given
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	Constants.HandleGitLabRequests.Set(True);
	Constants.RoutingFileName.Set("FileName" + Right(TIME, 5));
	Constants.GitLabToken.Set("StorageToken" + Right(TIME, 8));
	Constants.GitLabTimeout.Set(Number(Right(TIME, 4)));
	Constants.EndpointUserName.Set("UserName" + Right(TIME, 10));
	Constants.EndpointUserPassword.Set("UserPassword" + Right(TIME, 10));
	Constants.EndpointTimeout.Set(Number(Right(TIME, 4))-1);
	
	// when
	Result = ServicesSettings.GetCurrentSettings();
	
	// then
	Framework.AssertEqual(Result.Count(), 7);
	Framework.AssertTrue(Result.HandleGitLabRequests);
	Framework.AssertEqual(Result.RoutingFileName, "FileName" + Right(TIME, 5));
	Framework.AssertEqual(Result.GitLabToken, "StorageToken" + Right(TIME, 8));		
	Framework.AssertEqual(Result.GitLabTimeout, Number(Right(TIME, 4)));		
	Framework.AssertEqual(Result.EndpointUserName, "UserName" + Right(TIME, 10));
	Framework.AssertEqual(Result.EndpointUserPassword, "UserPassword" + Right(TIME, 10));
	Framework.AssertEqual(Result.EndpointTimeout, Number(Right(TIME, 4))-1);		

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SetCurrentSettings(Framework) Export

	// given
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	Constants.HandleGitLabRequests.Set(Undefined);
	Constants.RoutingFileName.Set(Undefined);
	Constants.GitLabToken.Set(Undefined);
	Constants.GitLabTimeout.Set(Undefined);
	Constants.EndpointUserName.Set(Undefined);
	Constants.EndpointUserPassword.Set(Undefined);
	Constants.EndpointTimeout.Set(Undefined);
	Settings = New Structure();
	Settings.Insert( "HandleGitLabRequests", True );
	Settings.Insert( "RoutingFileName", "FileName" + Right(TIME, 5));
	Settings.Insert( "GitLabToken", "StorageToken" + Right(TIME, 8));
	Settings.Insert( "GitLabTimeout", Number(Right(TIME, 4)));
	Settings.Insert( "EndpointUserName", "UserName" + Right(TIME, 10));
	Settings.Insert( "EndpointUserPassword", "UserPassword" + Right(TIME, 10));
	Settings.Insert( "EndpointTimeout", Number(Right(TIME, 4))-1);
	
	// when
	ServicesSettings.SetCurrentSettings(Settings);
	
	// then
	Framework.AssertTrue(Constants.HandleGitLabRequests.Get());
	Framework.AssertEqual(Constants.RoutingFileName.Get(), "FileName" + Right(TIME, 5));
	Framework.AssertEqual(Constants.GitLabToken.Get(), "StorageToken" + Right(TIME, 8));		
	Framework.AssertEqual(Constants.GitLabTimeout.Get(), Number(Right(TIME, 4)));		
	Framework.AssertEqual(Constants.EndpointUserName.Get(), "UserName" + Right(TIME, 10));
	Framework.AssertEqual(Constants.EndpointUserPassword.Get(), "UserPassword" + Right(TIME, 10));
	Framework.AssertEqual(Constants.EndpointTimeout.Get(), Number(Right(TIME, 4))-1);		

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure IsHandleRequestsException(Framework) Export

	// given
	Error = NStr( "ru = 'неверный тип запроса';en = 'invalid request type'" );
	
	// when
	Try
		ServicesSettings.IsHandleRequests("");
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Error);
	EndTry;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure IsHandleRequestsCustom(Framework) Export

	// given
	Constants.HandleCustomRequests.Set(True);
	Constants.HandleGitLabRequests.Set(False);
	
	// when
	Result = ServicesSettings.IsHandleRequests(Enums.RequestSource.Custom);
	
	// then
	Framework.AssertTrue(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure IsHandleRequestsGitLab(Framework) Export

	// given
	Constants.HandleGitLabRequests.Set(True);
	Constants.HandleCustomRequests.Set(False);
	
	// when
	Result = ServicesSettings.IsHandleRequests(Enums.RequestSource.GitLab);
	
	// then
	Framework.AssertTrue(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure IsHandleCustomRequestsTrue(Framework) Export

	// given
	Constants.HandleCustomRequests.Set(True);
	
	// when
	Result = ServicesSettings.IsHandleCustomRequests();
	
	// then
	Framework.AssertTrue(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure IsHandleCustomRequestsFalse(Framework) Export

	// given
	Constants.HandleCustomRequests.Set(False);
	
	// when
	Result = ServicesSettings.IsHandleCustomRequests();
	
	// then
	Framework.AssertFalse(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure IsHandleGitLabRequestsTrue(Framework) Export

	// given
	Constants.HandleGitLabRequests.Set(True);
	
	// when
	Result = ServicesSettings.IsHandleGitLabRequests();
	
	// then
	Framework.AssertTrue(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure IsHandleGitLabRequestsFalse(Framework) Export

	// given
	Constants.HandleGitLabRequests.Set(False);
	
	// when
	Result = ServicesSettings.IsHandleGitLabRequests();
	
	// then
	Framework.AssertFalse(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetEndpointUserName(Framework) Export

	// given
	UserName = "UserName" + Tests.RandomString();			
	Constants.EndpointUserName.Set(UserName);
	
	// when
	Result = ServicesSettings.GetEndpointUserName();
	
	// then
	Framework.AssertEqual(Result, UserName);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetEndpointUserPassword(Framework) Export

	// given
	UserPassword = "UserPassword" + Tests.RandomString();			
	Constants.EndpointUserPassword.Set(UserPassword);
	
	// when
	Result = ServicesSettings.GetEndpointUserPassword();
	
	// then
	Framework.AssertEqual(Result, UserPassword);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetEndpointTimeout(Framework) Export

	// given
	Timeout = Number(Right(Tests.RandomString(), 4));
	Constants.EndpointTimeout.Set(Timeout);
	
	// when
	Result = ServicesSettings.GetEndpointTimeout();
	
	// then
	Framework.AssertEqual(Result, Timeout);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetGitLabToken(Framework) Export

	// given
	Token = "Token" + Tests.RandomString();			
	Constants.GitLabToken.Set(Token);
	
	// when
	Result = ServicesSettings.GetGitLabToken();
	
	// then
	Framework.AssertEqual(Result, Token);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetGitLabTimeout(Framework) Export

	// given
	Timeout = Number(Right(Tests.RandomString(), 4));
	Constants.GitLabTimeout.Set(Timeout);
	
	// when
	Result = ServicesSettings.GetGitLabTimeout();
	
	// then
	Framework.AssertEqual(Result, Timeout);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetRoutingFileName(Framework) Export

	// given
	RoutingFileName = "RoutingFileName" + Tests.RandomString();			
	Constants.RoutingFileName.Set(RoutingFileName);
	
	// when
	Result = ServicesSettings.GetRoutingFileName();
	
	// then
	Framework.AssertEqual(Result, RoutingFileName);

EndProcedure

#EndRegion
