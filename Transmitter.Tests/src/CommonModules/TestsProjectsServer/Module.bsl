// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FindCredentials(Framework) Export

	// given
	WebhookCleanUp();
	URL1 = "http://url1";
	Token1 = "token1";
	Webhook1 = NewWebhook("Test1", URL1, Token1);
	
	URL2 = "http://url2";
	Token2 = "token2";
	Webhook2 = NewWebhook("Test2", URL2, Token2);
	Webhook2.SetDeletionMark(True);
	
	Webhook3 = NewWebhook("Test3", URL2, Token2);	
	
	// when
	Result = Projects.FindCredentials(URL2);
	
	// then
	Framework.AssertFilled(Result);
	Framework.AssertEqual(Result.Ref, Webhook3.Ref);	
	Framework.AssertEqual(Result.SecretToken, Token2);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FindCredentialsNotFound(Framework) Export

	// given
	WebhookCleanUp();
	URL = "http://url";
	Token = "token";
	NewWebhook("Test", URL, Token);
	
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
	WebhookCleanUp();
	
	DUPLICATED_MESSAGE = NStr( "ru = 'Обнаружены повторяющиеся проекты.';en = 'Duplicate projects found.'" );
	
	URL = "http://url";
	Token = "token";
	Webhook1 = NewWebhook("Test1", URL, Token);
	Webhook2 = NewWebhook("Test2", URL, Token);
	
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
	WebhookCleanUp();
	
	// when
	Result = Projects.FindCredentials(Undefined);
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

#EndRegion

#Region Internal

Function AddWebhook(Val Name = "", Val ProjectURL = "", Val SecretToken = "") Export
	
		Item = Catalogs.Webhooks.CreateItem();
		Item.DataExchange.Load = True;
		Item.Description = Name;
		Item.ProjectURL = ProjectURL;
		Item.SecretToken = SecretToken;
		Item.Write();
		
		Return Item;
	
EndFunction

#EndRegion

#Region Private

Procedure WebhookCleanUp()
	
	UtilsServer.CatalogCleanUp("Webhooks");

EndProcedure

Function NewWebhook(Val Name, Val ProjectURL, Val Token)

	Return TestsWebhooksServer.AddWebhook(Name, ProjectURL, Token);

EndFunction

#EndRegion