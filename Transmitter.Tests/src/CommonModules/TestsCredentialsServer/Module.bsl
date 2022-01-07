// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FindByURL(Framework) Export

	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	
	URL = Tests.NewURL();
	Token = Tests.NewToken();
	
	Tests.NewExternalRequestHandler();
	Tests.NewExternalRequestHandler("Test", URL, Token).SetDeletionMark(True);
	RequestHandler = Tests.NewExternalRequestHandler("Test", URL, Token);	
	
	// when
	Result = Credentials.FindByURL(URL);
	
	// then
	Framework.AssertFilled(Result);
	Framework.AssertEqual(Result.Ref, RequestHandler.Ref);	
	Framework.AssertEqual(Result.SecretToken, Token);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FindByURLNotFound(Framework) Export

	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");

	Tests.NewExternalRequestHandler();
	
	// when
	Result = Credentials.FindByURL("fake");
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FindByURLDublicated(Framework) Export

	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	
	DUPLICATED_MESSAGE = NStr( 	"ru = 'Обнаружены повторяющиеся проекты.';
								|en = 'Duplicate projects found.'" );
	
	URL = Tests.NewURL();
	Token = Tests.NewToken();
	
	Tests.NewExternalRequestHandler("Test", URL, Token);
	Tests.NewExternalRequestHandler("Test", URL, Token);
	
	// when
	Try
		Credentials.FindByURL(URL);
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
Procedure FindByURLWrongType(Framework) Export

	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	
	// when
	Result = Credentials.FindByURL(Undefined);
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

#EndRegion
