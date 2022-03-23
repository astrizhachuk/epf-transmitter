#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetConnectionParams(Framework) Export
	
	// given
	
	// when
	Result = EndpointsClientServer.GetConnectionParams();
	
	// then
	Framework.AssertEqual(Result.Count(), 8);
	Framework.AssertEqual(Result.URL, "");
	Framework.AssertEqual(Result.BaseURL, "");
	Framework.AssertEqual(Result.Operation, "/status");
	Framework.AssertFalse(Result.UseGlobalSettings);
	Framework.AssertEqual(Result.User, "");
	Framework.AssertEqual(Result.Password, "");
	Framework.AssertEqual(Result.Timeout, Undefined);	

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetServiceStatusException(Framework) Export
	
	// given
	Connection = New Structure();
	Connection.Insert( "URL", "" );
	Connection.Insert( "BaseURL", "" );
	Connection.Insert( "RootURL", "" );
	Connection.Insert( "Operation", "/status" );
	Connection.Insert( "UseGlobalSettings", False );
	Connection.Insert( "User", "" );
	Connection.Insert( "Password", "" );
	Connection.Insert( "Timeout", Undefined );
	
	// when
	Result = EndpointsServerCall.GetServiceStatus(Connection);
	
	// then
	Framework.AssertEqual(Result.StatusCode, -1);
	Framework.AssertStringContains(Result.ResponseBody, "or missing URL");

EndProcedure

#EndRegion
