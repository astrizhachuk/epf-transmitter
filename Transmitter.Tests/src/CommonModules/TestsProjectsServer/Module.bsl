// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FindCredentials(Framework) Export

	// given
	ExternalRequestHandlersCleanUp();
	URL1 = "http://url1";
	Token1 = "token1";
	RequestHandler1 = NewExternalRequestHandler("Test1", URL1, Token1);
	
	URL2 = "http://url2";
	Token2 = "token2";
	RequestHandler2 = NewExternalRequestHandler("Test2", URL2, Token2);
	RequestHandler2.SetDeletionMark(True);
	
	RequestHandler3 = NewExternalRequestHandler("Test3", URL2, Token2);	
	
	// when
	Result = Projects.FindCredentials(URL2);
	
	// then
	Framework.AssertFilled(Result);
	Framework.AssertEqual(Result.Ref, RequestHandler3.Ref);	
	Framework.AssertEqual(Result.SecretToken, Token2);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FindCredentialsNotFound(Framework) Export

	// given
	ExternalRequestHandlersCleanUp();
	URL = "http://url";
	Token = "token";
	NewExternalRequestHandler("Test", URL, Token);
	
	// when
	Result = Projects.FindCredentials("fake");
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FindCredentialsDublicated(Framework) Export

	// given
	ExternalRequestHandlersCleanUp();
	
	DUPLICATED_MESSAGE = NStr( "ru = 'Обнаружены повторяющиеся проекты.';en = 'Duplicate projects found.'" );
	
	URL = "http://url";
	Token = "token";
	RequestHandler1 = NewExternalRequestHandler("Test1", URL, Token);
	RequestHandler2 = NewExternalRequestHandler("Test2", URL, Token);
	
	// when
	Try
		Result = Projects.FindCredentials(URL);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, DUPLICATED_MESSAGE);
	EndTry;

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FindCredentialsWrongType(Framework) Export

	// given
	ExternalRequestHandlersCleanUp();
	
	// when
	Result = Projects.FindCredentials(Undefined);
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

#EndRegion

#Region Private

Procedure ExternalRequestHandlersCleanUp()
	
	UtilsServer.CatalogCleanUp("ExternalRequestHandlers");

EndProcedure

Function NewExternalRequestHandler(Val Name, Val ProjectURL, Val Token)

	Return UtilsServer.NewExternalRequestHandler(Name, ProjectURL, Token);

EndFunction

#EndRegion