// BSLLS-off
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure VersionGet200Ok(Framework) Export
	
	// given
	URL = "http://transmitter/api/hs/version";
	
	// when
	Result = HTTPConnector.Get(URL);
	
	// then
	Framework.AssertEqual(Result.StatusCode, 200);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertStringContains(Body, """version"":");
	Framework.AssertStringContains(Body, Metadata.Version);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GitLabStatusGet200OkEnabled(Framework) Export
	
	// given
	Constants.HandleRequests.Set(True);
	ServerURL = "http://transmitter/api/" + CurrentLanguage().LanguageCode;
	URL = ServerURL + "/hs/gitlab/status";
		
	// when
	Result = HTTPConnector.Get(URL);
	
	// then
	Framework.AssertEqual(Result.StatusCode, 200);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertStringContains(Body, """message"":");
	Framework.AssertStringContains(Body, NStr("ru = 'включена';en = 'enabled'" ));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GitLabStatusGet200OkDisabled(Framework) Export
	
	// given
	Constants.HandleRequests.Set(False);
	ServerURL = "http://transmitter/api/" + CurrentLanguage().LanguageCode;
	URL = ServerURL + "/hs/gitlab/status";
	
	// when
	Result = HTTPConnector.Get(URL);
	
	// then
	Framework.AssertEqual(Result.StatusCode, 200);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertStringContains(Body, """message"":");
	Framework.AssertStringContains(Body, NStr("ru = 'отключена';en = 'disabled'" ));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
// unit-test:fast
Procedure EventsPostPush200Ok(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleRequests.Set(True);
	
	Token = Tests.NewToken();
	Tests.NewExternalRequestHandler(, "http://mockserver:1080/root/external-epf", Token);
	ServerURL = "http://transmitter/api/" + CurrentLanguage().LanguageCode;
	URL = ServerURL + "/hs/gitlab/events/push";
	JSON = Tests.GetJSON("/test/requests/push-1b9949a2.json");

	// when
	Result = HTTPConnector.Post(URL, JSON, Options("Push Hook", Token));

	// then
	Framework.AssertEqual(Result.StatusCode, 200);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertTrue(IsBlankString(Body));

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPush400BadRequestWithoutToken(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleRequests.Set(True);
	
	Token = Tests.NewToken();
	Tests.NewExternalRequestHandler(, "http://mockserver:1080/root/external-epf", Token);
	ServerURL = "http://transmitter/api/" + CurrentLanguage().LanguageCode;
	URL = ServerURL + "/hs/gitlab/events/push";
	JSON = Tests.GetJSON("/test/requests/push-1b9949a2.json");
	Options = Options("Push Hook", Token);
	Options.Headers.Delete("X-Gitlab-Token");

	// when
	Result = HTTPConnector.Post(URL, JSON, Options);
	
	// then
	Framework.AssertEqual(Result.StatusCode, 400);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertFalse(IsBlankString(Body));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPush400BadRequestWithoutEvent(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleRequests.Set(True);
	
	Token = Tests.NewToken();
	Tests.NewExternalRequestHandler(, "http://mockserver:1080/root/external-epf", Token);
	ServerURL = "http://transmitter/api/" + CurrentLanguage().LanguageCode;
	URL = ServerURL + "/hs/gitlab/events/push";
	JSON = Tests.GetJSON("/test/requests/push-1b9949a2.json");
	Options = Options("Push Hook", Token);
	Options.Headers.Delete("X-Gitlab-Event");

	// when
	Result = HTTPConnector.Post(URL, JSON, Options);
	
	// then
	Framework.AssertEqual(Result.StatusCode, 400);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertFalse(IsBlankString(Body));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
// unit-test:fast
Procedure EventsPostPush400BadRequestWrongEventMethod(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleRequests.Set(True);
	
	Token = Tests.NewToken();
	Tests.NewExternalRequestHandler(, "http://mockserver:1080/root/external-epf", Token);
	ServerURL = "http://transmitter/api/" + CurrentLanguage().LanguageCode;
	URL = ServerURL + "/hs/gitlab/events/push";
	JSON = Tests.GetJSON("/test/requests/push-1b9949a2.json");

	// when
	Result = HTTPConnector.Post(URL, JSON, Options("Tag Hook", Token));

	// then
	Framework.AssertEqual(Result.StatusCode, 400);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertFalse(IsBlankString(Body));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPush401Unauthorized(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleRequests.Set(True);
	
	Token = Tests.NewToken();
	Tests.NewExternalRequestHandler(, "http://mockserver:1080/root/external-epf", Token);
	ServerURL = "http://transmitter/api/" + CurrentLanguage().LanguageCode;
	URL = ServerURL + "/hs/gitlab/events/push";
	JSON = Tests.GetJSON("/test/requests/push-1b9949a2.json");

	// when
	Result = HTTPConnector.Post(URL, JSON, Options("Push Hook", "fake"));
	
	// then
	Framework.AssertEqual(Result.StatusCode, 401);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertTrue(IsBlankString(Body));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPush404NotFound(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleRequests.Set(True);
	
	Token = Tests.NewToken();;
	ServerURL = "http://transmitter/api/" + CurrentLanguage().LanguageCode;
	URL = ServerURL + "/hs/gitlab/events/push";
	JSON = Tests.GetJSON("/test/requests/push-1b9949a2.json");
	JSON = StrReplace(JSON, """web_url"": ""http://mockserver:1080/root/external-epf""", """web_url"": ""fake""");

	// when
	Result = HTTPConnector.Post(URL, JSON, Options("Push Hook", Token));
	
	// then
	Framework.AssertEqual(Result.StatusCode, 404);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertTrue(IsBlankString(Body));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPush423Locked(Framework) Export

	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleRequests.Set(False);
	
	Token = Tests.NewToken();
	Tests.NewExternalRequestHandler(, "http://mockserver:1080/root/external-epf", Token);
	ServerURL = "http://transmitter/api/" + CurrentLanguage().LanguageCode;
	URL = ServerURL + "/hs/gitlab/events/push";
	JSON = Tests.GetJSON("/test/requests/push-1b9949a2.json");
	
	// when
	Result = HTTPConnector.Post(URL, JSON, Options("Push Hook", Token));

	// then
	Framework.AssertEqual(Result.StatusCode, 423);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertTrue(IsBlankString(Body));

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPush500InternalServerErrorWrongBodyFormat(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleRequests.Set(True);
	
	Token = Tests.NewToken();
	Tests.NewExternalRequestHandler(, "http://mockserver:1080/root/external-epf", Token);
	ServerURL = "http://transmitter/api/" + CurrentLanguage().LanguageCode;
	URL = ServerURL + "/hs/gitlab/events/push";
	JSON = "wrong data, there must be JSON";
	Options = Options("Push Hook", Token);

	// when
	Result = HTTPConnector.Post(URL, JSON, Options);
	
	// then
	Framework.AssertEqual(Result.StatusCode, 500);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertFalse(IsBlankString(Body));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPush500InternalServerErrorCheckoutSHAMissed(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleRequests.Set(True);
	
	Token = Tests.NewToken();
	Tests.NewExternalRequestHandler(, "http://mockserver:1080/root/external-epf", Token);
	ServerURL = "http://transmitter/api/" + CurrentLanguage().LanguageCode;
	URL = ServerURL + "/hs/gitlab/events/push";
	JSON = Tests.GetJSON("/test/requests/push-1b9949a2.json");
	JSON = StrReplace(JSON, """checkout_sha"": ", """checkout_sha_missed"": ");
	Options = Options("Push Hook", Token);

	// when
	Result = HTTPConnector.Post(URL, JSON, Options);
	
	// then
	Framework.AssertEqual(Result.StatusCode, 500);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertFalse(IsBlankString(Body));
	
EndProcedure

#EndRegion

#Region Private

Function Options(Val Event, Val Token)
	
	Headers = New Map();
	Headers.Insert("Content-Type", "application/json");
	Headers.Insert("X-Gitlab-Event", Event);
	Headers.Insert("X-Gitlab-Token", Token);
	
	Result = New Structure();
	Result.Insert("Headers", Headers);
	Result.Insert("Timeout", 5);
	
	Return Result;
	 
EndFunction

#EndRegion