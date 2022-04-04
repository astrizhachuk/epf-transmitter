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
	Framework.AssertStringContains(Body, """version""");
	Framework.AssertStringContains(Body, Metadata.Version);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GitLabStatusGet200OkEnabled(Framework) Export
	
	// given
	Constants.HandleGitLabRequests.Set(True);

	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab/status";
		
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
	Constants.HandleGitLabRequests.Set(False);
	
	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab/status";
	
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
Procedure CustomStatusGet200OkEnabled(Framework) Export
	
	// given
	Constants.HandleCustomRequests.Set(True);

	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/custom/status";
		
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
Procedure CustomStatusGet200OkDisabled(Framework) Export
	
	// given
	Constants.HandleCustomRequests.Set(False);
	
	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/custom/status";
	
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
Procedure EventsPostPushGitLab200Ok(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleGitLabRequests.Set(True);
	
	Stub = StubGitLabExternalRequest();

	// when
	Result = HTTPConnector.Post(Stub.URL, Stub.JSON, Options(Stub.Push, Stub.Token));

	// then
	Framework.AssertEqual(Result.StatusCode, 200);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertTrue(IsBlankString(Body));

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPushGitLab400BadRequestWithoutToken(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleGitLabRequests.Set(True);
	
	Stub = StubGitLabExternalRequest();
	Options = Options(Stub.Push, Stub.Token);
	Options.Headers.Delete("X-Gitlab-Token");

	// when
	Result = HTTPConnector.Post(Stub.URL, Stub.JSON, Options);
	
	// then
	Framework.AssertEqual(Result.StatusCode, 400);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertFalse(IsBlankString(Body));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPushGitLab400BadRequestWithoutEvent(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleGitLabRequests.Set(True);
	
	Stub = StubGitLabExternalRequest();
	Options = Options(Stub.Push, Stub.Token);
	Options.Headers.Delete("X-Gitlab-Event");

	// when
	Result = HTTPConnector.Post(Stub.URL, Stub.JSON, Options);
	
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
Procedure EventsPostPushGitLab400BadRequestWrongEventMethod(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleGitLabRequests.Set(True);
	
	Stub = StubGitLabExternalRequest();

	// when
	Result = HTTPConnector.Post(Stub.URL, Stub.JSON, Options(Stub.Tag, Stub.Token));

	// then
	Framework.AssertEqual(Result.StatusCode, 400);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertFalse(IsBlankString(Body));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPushGitLab401Unauthorized(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleGitLabRequests.Set(True);
	
	Stub = StubGitLabExternalRequest();

	// when
	Result = HTTPConnector.Post(Stub.URL, Stub.JSON, Options(Stub.Push, Stub.FakeToken));
	
	// then
	Framework.AssertEqual(Result.StatusCode, 401);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertTrue(IsBlankString(Body));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPushGitLab404NotFound(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleGitLabRequests.Set(True);
	
	Stub = StubGitLabExternalRequest();	
	Stub.JSON = StrReplace(Stub.JSON, """web_url"": ""http://mockserver:1080/root/external-epf""", """web_url"": ""fake""");

	// when
	Result = HTTPConnector.Post(Stub.URL, Stub.JSON, Options(Stub.Push, Stub.Token));
	
	// then
	Framework.AssertEqual(Result.StatusCode, 404);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertTrue(IsBlankString(Body));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPushGitLab423Locked(Framework) Export

	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleGitLabRequests.Set(False);
	
	Stub = StubGitLabExternalRequest();	

	// when
	Result = HTTPConnector.Post(Stub.URL, Stub.JSON, Options(Stub.Push, Stub.Token));

	// then
	Framework.AssertEqual(Result.StatusCode, 423);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertTrue(IsBlankString(Body));

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPushGitLab500InternalServerErrorWrongBodyFormat(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleGitLabRequests.Set(True);
	
	Stub = StubGitLabExternalRequest();
	Stub.JSON = "wrong data, there must be JSON";

	// when
	Result = HTTPConnector.Post(Stub.URL, Stub.JSON, Options(Stub.Push, Stub.Token));
	
	// then
	Framework.AssertEqual(Result.StatusCode, 500);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertFalse(IsBlankString(Body));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EventsPostPushGitLab500InternalServerErrorCheckoutSHAMissed(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	Constants.HandleGitLabRequests.Set(True);
	
	Stub = StubGitLabExternalRequest();
	Stub.JSON = StrReplace(Stub.JSON, """checkout_sha"": ", """checkout_sha_missed"": ");

	// when
	Result = HTTPConnector.Post(Stub.URL, Stub.JSON, Options(Stub.Push, Stub.Token));
	
	// then
	Framework.AssertEqual(Result.StatusCode, 500);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertFalse(IsBlankString(Body));
	
EndProcedure

#EndRegion

#Region Private

Function StubGitLabExternalRequest()
	
	Result = New Structure();
	Result.Insert("Token", Tests.NewToken());
	Result.Insert("FakeToken", Tests.NewToken());
	Result.Insert("Push", "Push Hook");
	Result.Insert("Tag", "Tag Hook");
	Result.Insert("URL", "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab/events/push");
	Result.Insert("ExternalRequestHandler", Tests.NewExternalRequestHandler(, "http://mockserver:1080/root/external-epf", Result.Token));
	Result.Insert("JSON", Tests.GetJSON("/test/requests/push-1b9949a2.json"));
		
	Return Result;
	
EndFunction

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