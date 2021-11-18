#Region Internal

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
	Constants.IsHandleRequests.Set(True);
	Constants.RoutingFileName.Set("FileName" + Right(TIME, 5));
	Constants.ExternalStorageToken.Set("StorageToken" + Right(TIME, 8));
	Constants.ExternalStorageTimeout.Set(Number(Right(TIME, 4)));
	Constants.ReceiverUserName.Set("UserName" + Right(TIME, 10));
	Constants.ReceiverUserPassword.Set("UserPassword" + Right(TIME, 10));
	Constants.DeliveryFileTimeout.Set(Number(Right(TIME, 4))-1);
	// when
	Result = ServicesSettings.CurrentSettings();
	// then
	Framework.AssertEqual(Result.Количество(), 7);
	Framework.AssertTrue(Result.IsHandleRequests);
	Framework.AssertEqual(Result.RoutingFileName, "FileName" + Right(TIME, 5));
	Framework.AssertEqual(Result.ExternalStorageToken, "StorageToken" + Right(TIME, 8));		
	Framework.AssertEqual(Result.ExternalStorageTimeout, Number(Right(TIME, 4)));		
	Framework.AssertEqual(Result.ReceiverUserName, "UserName" + Right(TIME, 10));
	Framework.AssertEqual(Result.ReceiverUserPassword, "UserPassword" + Right(TIME, 10));
	Framework.AssertEqual(Result.DeliveryFileTimeout, Number(Right(TIME, 4))-1);		

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SetCurrentSettings(Framework) Export

	// given
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	Constants.IsHandleRequests.Set(Undefined);
	Constants.RoutingFileName.Set(Undefined);
	Constants.ExternalStorageToken.Set(Undefined);
	Constants.ExternalStorageTimeout.Set(Undefined);
	Constants.ReceiverUserName.Set(Undefined);
	Constants.ReceiverUserPassword.Set(Undefined);
	Constants.DeliveryFileTimeout.Set(Undefined);
	Settings = New Structure();
	Settings.Insert( "IsHandleRequests", True );
	Settings.Insert( "RoutingFileName", "FileName" + Right(TIME, 5));
	Settings.Insert( "ExternalStorageToken", "StorageToken" + Right(TIME, 8));
	Settings.Insert( "ExternalStorageTimeout", Number(Right(TIME, 4)));
	Settings.Insert( "ReceiverUserName", "UserName" + Right(TIME, 10));
	Settings.Insert( "ReceiverUserPassword", "UserPassword" + Right(TIME, 10));
	Settings.Insert( "DeliveryFileTimeout", Number(Right(TIME, 4))-1);
	// when
	ServicesSettings.SetCurrentSettings(Settings);
	// then
	Framework.AssertTrue(Constants.IsHandleRequests.Get());
	Framework.AssertEqual(Constants.RoutingFileName.Get(), "FileName" + Right(TIME, 5));
	Framework.AssertEqual(Constants.ExternalStorageToken.Get(), "StorageToken" + Right(TIME, 8));		
	Framework.AssertEqual(Constants.ExternalStorageTimeout.Get(), Number(Right(TIME, 4)));		
	Framework.AssertEqual(Constants.ReceiverUserName.Get(), "UserName" + Right(TIME, 10));
	Framework.AssertEqual(Constants.ReceiverUserPassword.Get(), "UserPassword" + Right(TIME, 10));
	Framework.AssertEqual(Constants.DeliveryFileTimeout.Get(), Number(Right(TIME, 4))-1);		

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure IsHandleRequestsTrue(Framework) Export

	// given
	Constants.IsHandleRequests.Set(True);
	// when
	Result = ServicesSettings.IsHandleRequests();
	// then
	Framework.AssertTrue(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure IsHandleRequestsFalse(Framework) Export

	// given
	Constants.IsHandleRequests.Set(False);
	// when
	Result = ServicesSettings.IsHandleRequests();
	// then
	Framework.AssertFalse(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ReceiverUserName(Framework) Export

	// given
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	UserName = "UserName" + Right(TIME, 10);			
	Constants.ReceiverUserName.Set(UserName);
	// when
	Result = ServicesSettings.ReceiverUserName();
	// then
	Framework.AssertEqual(Result, UserName);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ReceiverUserPassword(Framework) Export

	// given
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	UserPassword = "UserPassword" + Right(TIME, 10);			
	Constants.ReceiverUserPassword.Set(UserPassword);
	// when
	Result = ServicesSettings.ReceiverUserPassword();
	// then
	Framework.AssertEqual(Result, UserPassword);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure DeliveryFileTimeout(Framework) Export

	// given
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");			
	Constants.DeliveryFileTimeout.Set(Number(Right(TIME, 4)));
	// when
	Result = ServicesSettings.DeliveryFileTimeout();
	// then
	Framework.AssertEqual(Result, Number(Right(TIME, 4)));

EndProcedure

#EndRegion
