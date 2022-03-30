// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure Connector(Framework) Export
	
	// given
	
	// when
	Result = EndpointsClientServer.Connector();
	
	// then
	Framework.AssertEqual(Result.Count(), 9);
	Framework.AssertEqual(Result.URL, "");
	Framework.AssertEqual(Result.BaseURL, "");
	Framework.AssertEqual(Result.StatusOperation, "/status");
	Framework.AssertEqual(Result.UploadFileOperation, "/uploadFile");
	Framework.AssertFalse(Result.UseGlobalSettings);
	Framework.AssertEqual(Result.User, "");
	Framework.AssertEqual(Result.Password, "");
	Framework.AssertEqual(Result.Timeout, 5);	

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetStatusServiceException(Framework) Export
	
	// given
	Connection = New Structure();
	Connection.Insert( "URL", "" );
	Connection.Insert( "BaseURL", "" );
	Connection.Insert( "RootURL", "" );
	Connection.Insert( "StatusOperation", "/status" );
	Connection.Insert( "UploadFileOperation", "/uploadFile" );
	Connection.Insert( "UseGlobalSettings", False );
	Connection.Insert( "User", "" );
	Connection.Insert( "Password", "" );
	Connection.Insert( "Timeout", 5 );
	
	// when
	Result = EndpointsServerCall.GetStatusService(Connection);
	
	// then
	Framework.AssertEqual(Result.StatusCode, -1);
	Framework.AssertStringContains(Result.ResponseBody, "or missing URL");

EndProcedure

#EndRegion
