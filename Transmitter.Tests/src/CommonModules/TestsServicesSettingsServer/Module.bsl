#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure Settings(Framework) Export
	
	// given
	Result = Undefined;
	
	// when
	Result = ServicesSettingsClientCerver.Settings();
	
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
	Constants.HandleRequests.Set(True);
	Constants.RoutingFileName.Set("FileName" + Right(TIME, 5));
	Constants.ExternalStorageToken.Set("StorageToken" + Right(TIME, 8));
	Constants.ExternalStorageTimeout.Set(Number(Right(TIME, 4)));
	Constants.EndpointUserName.Set("UserName" + Right(TIME, 10));
	Constants.EndpointUserPassword.Set("UserPassword" + Right(TIME, 10));
	Constants.DeliveryFileTimeout.Set(Number(Right(TIME, 4))-1);
	
	// when
	Result = ServicesSettings.CurrentSettings();
	
	// then
	Framework.AssertEqual(Result.Количество(), 7);
	Framework.AssertTrue(Result.HandleRequests);
	Framework.AssertEqual(Result.RoutingFileName, "FileName" + Right(TIME, 5));
	Framework.AssertEqual(Result.ExternalStorageToken, "StorageToken" + Right(TIME, 8));		
	Framework.AssertEqual(Result.ExternalStorageTimeout, Number(Right(TIME, 4)));		
	Framework.AssertEqual(Result.EndpointUserName, "UserName" + Right(TIME, 10));
	Framework.AssertEqual(Result.EndpointUserPassword, "UserPassword" + Right(TIME, 10));
	Framework.AssertEqual(Result.DeliveryFileTimeout, Number(Right(TIME, 4))-1);		

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SetCurrentSettings(Framework) Export

	// given
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	Constants.HandleRequests.Set(Undefined);
	Constants.RoutingFileName.Set(Undefined);
	Constants.ExternalStorageToken.Set(Undefined);
	Constants.ExternalStorageTimeout.Set(Undefined);
	Constants.EndpointUserName.Set(Undefined);
	Constants.EndpointUserPassword.Set(Undefined);
	Constants.DeliveryFileTimeout.Set(Undefined);
	Settings = New Structure();
	Settings.Insert( "HandleRequests", True );
	Settings.Insert( "RoutingFileName", "FileName" + Right(TIME, 5));
	Settings.Insert( "ExternalStorageToken", "StorageToken" + Right(TIME, 8));
	Settings.Insert( "ExternalStorageTimeout", Number(Right(TIME, 4)));
	Settings.Insert( "EndpointUserName", "UserName" + Right(TIME, 10));
	Settings.Insert( "EndpointUserPassword", "UserPassword" + Right(TIME, 10));
	Settings.Insert( "DeliveryFileTimeout", Number(Right(TIME, 4))-1);
	
	// when
	ServicesSettings.SetCurrentSettings(Settings);
	
	// then
	Framework.AssertTrue(Constants.HandleRequests.Get());
	Framework.AssertEqual(Constants.RoutingFileName.Get(), "FileName" + Right(TIME, 5));
	Framework.AssertEqual(Constants.ExternalStorageToken.Get(), "StorageToken" + Right(TIME, 8));		
	Framework.AssertEqual(Constants.ExternalStorageTimeout.Get(), Number(Right(TIME, 4)));		
	Framework.AssertEqual(Constants.EndpointUserName.Get(), "UserName" + Right(TIME, 10));
	Framework.AssertEqual(Constants.EndpointUserPassword.Get(), "UserPassword" + Right(TIME, 10));
	Framework.AssertEqual(Constants.DeliveryFileTimeout.Get(), Number(Right(TIME, 4))-1);		

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure HandleRequestsTrue(Framework) Export

	// given
	Constants.HandleRequests.Set(True);
	
	// when
	Result = ServicesSettings.HandleRequests();
	
	// then
	Framework.AssertTrue(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure HandleRequestsFalse(Framework) Export

	// given
	Constants.HandleRequests.Set(False);
	
	// when
	Result = ServicesSettings.HandleRequests();
	
	// then
	Framework.AssertFalse(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EndpointUserName(Framework) Export

	// given
	UserName = "UserName" + Tests.RandomString();			
	Constants.EndpointUserName.Set(UserName);
	
	// when
	Result = ServicesSettings.EndpointUserName();
	
	// then
	Framework.AssertEqual(Result, UserName);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EndpointUserPassword(Framework) Export

	// given
	UserPassword = "UserPassword" + Tests.RandomString();			
	Constants.EndpointUserPassword.Set(UserPassword);
	
	// when
	Result = ServicesSettings.EndpointUserPassword();
	
	// then
	Framework.AssertEqual(Result, UserPassword);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure DeliveryFileTimeout(Framework) Export

	// given
	Timeout = Number(Right(Tests.RandomString(), 4));
	Constants.DeliveryFileTimeout.Set(Timeout);
	
	// when
	Result = ServicesSettings.DeliveryFileTimeout();
	
	// then
	Framework.AssertEqual(Result, Timeout);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ExternalStorageToken(Framework) Export

	// given
	Token = "Token" + Tests.RandomString();			
	Constants.ExternalStorageToken.Set(Token);
	
	// when
	Result = ServicesSettings.ExternalStorageToken();
	
	// then
	Framework.AssertEqual(Result, Token);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ExternalStorageTimeout(Framework) Export

	// given
	Timeout = Number(Right(Tests.RandomString(), 4));
	Constants.ExternalStorageTimeout.Set(Timeout);
	
	// when
	Result = ServicesSettings.ExternalStorageTimeout();
	
	// then
	Framework.AssertEqual(Result, Timeout);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure RoutingFileName(Framework) Export

	// given
	RoutingFileName = "RoutingFileName" + Tests.RandomString();			
	Constants.RoutingFileName.Set(RoutingFileName);
	
	// when
	Result = ServicesSettings.RoutingFileName();
	
	// then
	Framework.AssertEqual(Result, RoutingFileName);

EndProcedure

#EndRegion
