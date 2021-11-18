// BSLLS-выкл.
#Region Internal

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure CreateMessage(Framework) Export

	// given
	Text = "new text";
	// when
	Result = HTTPServices.CreateMessage(Text);
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result.message, Text);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SetBodyAsJSON(Framework) Export
	
	// given
	Result = New HTTPServiceResponse(200);
	Structure = New Structure();
	Structure.Insert("Key", 1);
	
	// when
	HTTPServices.SetBodyAsJSON(Result, Structure);
	
	// then
	Framework.AssertEqual(Result.GetBodyAsString(), "{""Key"":1}"); 
	
EndProcedure

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
	Constants.IsHandleRequests.Set(True);
	URL = "http://transmitter/api/ru/hs/gitlab/status";
	
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
	Constants.IsHandleRequests.Set(False);
	URL = "http://transmitter/api/ru/hs/gitlab/status";
	
	// when
	Result = HTTPConnector.Get(URL);

	// then
	Framework.AssertEqual(Result.StatusCode, 200);
	Body = HTTPConnector.AsText(Result, TextEncoding.UTF8);
	Framework.AssertStringContains(Body, """message"":");
	Framework.AssertStringContains(Body, NStr("ru = 'отключена';en = 'disabled'" ));
	
EndProcedure

// @unit-test:fast
Procedure WebhooksPOST(Фреймворк) Export
	
	PROCESSED_REQUEST_MESSAGE = НСтр( "ru = 'Запрос с сервера GitLab обработан.';
									|en = 'The request from the GitLab server has been processed.'" );	

	// given
	УдалитьВсеОбработчикиСобытий();
	TestsWebhooksServer.AddWebhook("ЮнитТест1", "блаблаблаюниттест");
	Константы.IsHandleRequests.Установить(Истина);
	
	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab";
	URL = URL + "/webhooks/epf/push";
	ЭталонWebHookGitLab = "/home/usr1cv8/test/request-epf-push.json";
	Текст = Новый ЧтениеТекста(ЭталонWebHookGitLab, КодировкаТекста.UTF8);
	JSON = Текст.Прочитать();

	// when
	Результат = HTTPConnector.Post(URL, JSON, ДополнительныеПараметрыУспешногоЗапроса());

	// then
	Фреймворк.ПроверитьРавенство(Результат.КодСостояния, 200);
	ТелоОтвета = TestsCommonUseServer.AsText(Результат, КодировкаТекста.UTF8);
	Фреймворк.ПроверитьВхождение(ТелоОтвета, PROCESSED_REQUEST_MESSAGE);

EndProcedure

// @unit-test
Procedure WebhooksPOST403Forbidden(Фреймворк) Export
	
	KEY_NOT_FOUND_MESSAGE = НСтр( "ru = 'Секретный ключ не найден.';
									|en = 'The Secret Key is not found.'" );
	
	// given
	УдалитьВсеОбработчикиСобытий();
	TestsWebhooksServer.AddWebhook("ЮнитТест1", "блаблаблаюниттест");
	Константы.IsHandleRequests.Установить(Ложь);

	
	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab";
	URL = URL + "/webhooks/epf/push";
	JSON = "{}";
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "application/json");
	Заголовки.Вставить("X-Gitlab-Event", "Push Hook");
	Заголовки.Вставить("X-Gitlab-Token", "ФэйковыйСекретныйКлюч");
	Дополнительно = Новый Структура;
	Дополнительно.Вставить("Заголовки", Заголовки);
	Дополнительно.Вставить("Таймаут", 5);

	// when
	Результат = HTTPConnector.Post(URL, JSON, Дополнительно);
	
	// then
	Фреймворк.ПроверитьРавенство(Результат.КодСостояния, 403);
	ТелоОтвета = HTTPConnector.AsText(Результат, КодировкаТекста.UTF8);
	Фреймворк.ПроверитьВхождение(ТелоОтвета, KEY_NOT_FOUND_MESSAGE);
	
EndProcedure

// @unit-test
Procedure WebhooksPOST423Locked(Фреймворк) Export
	
	LOADING_DISABLED_MESSAGE = НСтр( "ru = 'Загрузка из внешнего хранилища отключена.';
									|en = 'Loading of the files is disabled.'" );

	// given
	УдалитьВсеОбработчикиСобытий();
	TestsWebhooksServer.AddWebhook("ЮнитТест1", "блаблаблаюниттест");
	Константы.IsHandleRequests.Установить(Ложь);
	
	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab";
	URL = URL + "/webhooks/epf/push";
	JSON = "{}";
	
	// when
	Результат = HTTPConnector.Post(URL, JSON, ДополнительныеПараметрыУспешногоЗапроса());

	// then
	Фреймворк.ПроверитьРавенство(Результат.КодСостояния, 423);
	ТелоОтвета = HTTPConnector.AsText(Результат, КодировкаТекста.UTF8);
	Фреймворк.ПроверитьВхождение(ТелоОтвета, LOADING_DISABLED_MESSAGE);

EndProcedure

// @unit-test
Procedure WebhooksPOST400BadRequestXGitlabEvent(Фреймворк) Export

	// given
	УдалитьВсеОбработчикиСобытий();
	TestsWebhooksServer.AddWebhook("ЮнитТест1", "блаблаблаюниттест");
	Константы.IsHandleRequests.Установить(Истина);
	
	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab";
	URL = URL + "/webhooks/epf/push";
	JSON = "{}";
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "application/json");
	Заголовки.Вставить("X-Gitlab-Event", "Push Hook2");
	Заголовки.Вставить("X-Gitlab-Token", "блаблаблаюниттест");
	Дополнительно = Новый Структура;
	Дополнительно.Вставить("Заголовки", Заголовки);
	Дополнительно.Вставить("Таймаут", 5);

	// when
	Результат = HTTPConnector.Post(URL, JSON, Дополнительно);

	// then
	Фреймворк.ПроверитьРавенство(Результат.КодСостояния, 400, "400 Push Hook2");
	ТелоОтвета = HTTPConnector.AsText(Результат, КодировкаТекста.UTF8);
	Фреймворк.ПроверитьИстину(ПустаяСтрока(ТелоОтвета), "400 Push Hook2");

EndProcedure

// @unit-test
Procedure WebhooksPOST400BadRequestBadURLEpf(Фреймворк) Export

	// given
	УдалитьВсеОбработчикиСобытий();
	TestsWebhooksServer.AddWebhook("ЮнитТест1", "блаблаблаюниттест");
	Константы.IsHandleRequests.Установить(Истина);
	
	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab";
	URL = URL + "/webhooks/epf3/push";
	JSON = "{}";

	// when
	Результат = HTTPConnector.Post(URL, JSON, ДополнительныеПараметрыУспешногоЗапроса());

	// then
	Фреймворк.ПроверитьРавенство(Результат.КодСостояния, 400, "400 BadURLEpf");
	ТелоОтвета = HTTPConnector.AsText(Результат, КодировкаТекста.UTF8);
	Фреймворк.ПроверитьИстину(ПустаяСтрока(ТелоОтвета), "400 BadURLEpf");

EndProcedure

// @unit-test
Procedure WebhooksPOST400BadRequestBadURLPush(Фреймворк) Export

	// given
	УдалитьВсеОбработчикиСобытий();
	TestsWebhooksServer.AddWebhook("ЮнитТест1", "блаблаблаюниттест");
	Константы.IsHandleRequests.Установить(Истина);
	
	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab";
	URL = URL + "/webhooks/epf/push3";
	JSON = "{}";
	
	// when
	Результат = HTTPConnector.Post(URL, JSON, ДополнительныеПараметрыУспешногоЗапроса());

	// then
	Фреймворк.ПроверитьРавенство(Результат.КодСостояния, 400, "400 BadURLPush");
	ТелоОтвета = HTTPConnector.AsText(Результат, КодировкаТекста.UTF8);
	Фреймворк.ПроверитьИстину(ПустаяСтрока(ТелоОтвета), "400 BadURLPush");

EndProcedure

// @unit-test
Procedure WebhooksPOST400BadRequestCheckoutSHA(Фреймворк) Export

	// given
	УдалитьВсеОбработчикиСобытий();
	TestsWebhooksServer.AddWebhook("ЮнитТест1", "блаблаблаюниттест");
	Константы.IsHandleRequests.Установить(Истина);
	
	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab";
	URL = URL + "/webhooks/epf/push";
	JSON = "{
	   |  ""object_kind"": ""push"",
	   |  ""project_id"": 178,
	   |  ""project"": {
	   |    ""id"": 178,
	   |    ""name"": ""TestEpf"",
	   |    ""web_url"": ""http://git.a/a.strizhachuk/testepf"",
	   |    ""description"": """"
	   |  },
	   |  ""commits"": [
	   |    {
	   |      ""id"": ""87fc6b2782f1bcadce980cb52941e2bd90974c0f"",
	   |      ""message"": ""Merge branch ''ttt'' into ''master''\n\nTtt\n\nSee merge request a.strizhachuk/testepf!2""
	   |    },
	   |    {
	   |      ""id"": ""bb8c1e02e420afffe601ada9f1171991d0404e68"",
	   |      ""message"": ""test\n""
	   |    },
	   |    {
	   |      ""id"": ""2fb9499926026288d1e9b9c6586338fff4ec996b"",
	   |      ""message"": ""test\n""
	   |    }
	   |  ],
	   |  ""total_commits_count"": 3
	   |  }
	   |}";

	// when
	Результат = HTTPConnector.Post(URL, JSON, ДополнительныеПараметрыУспешногоЗапроса());

	// then
	Фреймворк.ПроверитьРавенство(Результат.КодСостояния, 400, "400 checkout_sha");
	ТелоОтвета = TestsCommonUseServer.AsText(Результат, КодировкаТекста.UTF8);
	Фреймворк.ПроверитьИстину(ПустаяСтрока(ТелоОтвета), "400 checkout_sha");

EndProcedure

// @unit-test
Procedure WebhooksPOST400BadRequestProject(Фреймворк) Export

	// given
	УдалитьВсеОбработчикиСобытий();
	TestsWebhooksServer.AddWebhook("ЮнитТест1", "блаблаблаюниттест");
	Константы.IsHandleRequests.Установить(Истина);
	
	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab";
	URL = URL + "/webhooks/epf/push";
	JSON = "{
		   |  ""object_kind"": ""push"",
		   |  ""checkout_sha"": ""87fc6b2782f1bcadce980cb52941e2bd90974c0f"",
		   |  ""project_id"": 178,
		   |  ""commits"": [
		   |    {
		   |      ""id"": ""87fc6b2782f1bcadce980cb52941e2bd90974c0f"",
		   |      ""message"": ""Merge branch ''ttt'' into ''master''\n\nTtt\n\nSee merge request a.strizhachuk/testepf!2""
		   |    },
		   |    {
		   |      ""id"": ""bb8c1e02e420afffe601ada9f1171991d0404e68"",
		   |      ""message"": ""test\n""
		   |    },
		   |    {
		   |      ""id"": ""2fb9499926026288d1e9b9c6586338fff4ec996b"",
		   |      ""message"": ""test\n""
		   |    }
		   |  ],
		   |  ""total_commits_count"": 3
		   |  }
		   |}";

	// when
	Результат = HTTPConnector.Post(URL, JSON, ДополнительныеПараметрыУспешногоЗапроса());

	// then
	Фреймворк.ПроверитьРавенство(Результат.КодСостояния, 400, "400 project");
	ТелоОтвета = TestsCommonUseServer.AsText(Результат, КодировкаТекста.UTF8);
	Фреймворк.ПроверитьИстину(ПустаяСтрока(ТелоОтвета), "400 project");

EndProcedure

// @unit-test
Procedure WebhooksPOST400BadRequestProjectWebURL(Фреймворк) Export

	// given
	УдалитьВсеОбработчикиСобытий();
	TestsWebhooksServer.AddWebhook("ЮнитТест1", "блаблаблаюниттест");
	Константы.IsHandleRequests.Установить(Истина);
	
	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab";
	URL = URL + "/webhooks/epf/push";
	JSON = "{
		   |  ""object_kind"": ""push"",
		   |  ""checkout_sha"": ""87fc6b2782f1bcadce980cb52941e2bd90974c0f"",
		   |  ""project_id"": 178,
		   |  ""project"": {
		   |    ""id"": 178,
		   |    ""name"": ""TestEpf"",
		   |    ""description"": """"
		   |  },
		   |  ""commits"": [
		   |    {
		   |      ""id"": ""87fc6b2782f1bcadce980cb52941e2bd90974c0f"",
		   |      ""message"": ""Merge branch ''ttt'' into ''master''\n\nTtt\n\nSee merge request a.strizhachuk/testepf!2""
		   |    },
		   |    {
		   |      ""id"": ""bb8c1e02e420afffe601ada9f1171991d0404e68"",
		   |      ""message"": ""test\n""
		   |    },
		   |    {
		   |      ""id"": ""2fb9499926026288d1e9b9c6586338fff4ec996b"",
		   |      ""message"": ""test\n""
		   |    }
		   |  ],
		   |  ""total_commits_count"": 3
		   |  }
		   |}";
	
	// when
	Результат = HTTPConnector.Post(URL, JSON, ДополнительныеПараметрыУспешногоЗапроса());

	// then
	Фреймворк.ПроверитьРавенство(Результат.КодСостояния, 400, "400 project/web_url");
	ТелоОтвета = TestsCommonUseServer.AsText(Результат, КодировкаТекста.UTF8);
	Фреймворк.ПроверитьИстину(ПустаяСтрока(ТелоОтвета), "400 project/web_url");

EndProcedure

// @unit-test
Procedure WebhooksPOST400BadRequestCommits(Фреймворк) Export

	// given
	УдалитьВсеОбработчикиСобытий();
	TestsWebhooksServer.AddWebhook("ЮнитТест1", "блаблаблаюниттест");
	Константы.IsHandleRequests.Установить(Истина);
	
	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab";
	URL = URL + "/webhooks/epf/push";
	JSON = "{
		   |  ""object_kind"": ""push"",
		   |  ""checkout_sha"": ""87fc6b2782f1bcadce980cb52941e2bd90974c0f"",
		   |  ""project_id"": 178,
		   |  ""project"": {
		   |    ""id"": 178,
		   |    ""name"": ""TestEpf"",
		   |    ""web_url"": ""http://git.a/a.strizhachuk/testepf"",
		   |    ""description"": """"
		   |  },
		   |  ""total_commits_count"": 3
		   |  }
		   |}";
	
	// when
	Результат = HTTPConnector.Post(URL, JSON, ДополнительныеПараметрыУспешногоЗапроса());

	// then
	Фреймворк.ПроверитьРавенство(Результат.КодСостояния, 400, "400 commits");
	ТелоОтвета = TestsCommonUseServer.AsText(Результат, КодировкаТекста.UTF8);
	Фреймворк.ПроверитьИстину(ПустаяСтрока(ТелоОтвета), "400 commits");

EndProcedure

// @unit-test
Procedure WebhooksPOST400BadRequestCommitsId(Фреймворк) Export

	// given
	УдалитьВсеОбработчикиСобытий();
	TestsWebhooksServer.AddWebhook("ЮнитТест1", "блаблаблаюниттест");
	Константы.IsHandleRequests.Установить(Истина);
	
	URL = "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/gitlab";
	URL = URL + "/webhooks/epf/push";
	JSON = "{
		   |  ""object_kind"": ""push"",
		   |  ""checkout_sha"": ""87fc6b2782f1bcadce980cb52941e2bd90974c0f"",
		   |  ""project_id"": 178,
		   |  ""project"": {
		   |    ""id"": 178,
		   |    ""name"": ""TestEpf"",
		   |    ""web_url"": ""http://git.a/a.strizhachuk/testepf"",
		   |    ""description"": """"
		   |  },
		   |  ""commits"": [
		   |    {
		   |      ""message"": ""Merge branch ''ttt'' into ''master''\n\nTtt\n\nSee merge request a.strizhachuk/testepf!2""
		   |    },
		   |    {
		   |      ""id"": ""bb8c1e02e420afffe601ada9f1171991d0404e68"",
		   |      ""message"": ""test\n""
		   |    },
		   |    {
		   |      ""id"": ""2fb9499926026288d1e9b9c6586338fff4ec996b"",
		   |      ""message"": ""test\n""
		   |    }
		   |  ],
		   |  ""total_commits_count"": 3
		   |  }
		   |}";

	// when
	Результат = HTTPConnector.Post(URL, JSON, ДополнительныеПараметрыУспешногоЗапроса());

	// then
	Фреймворк.ПроверитьРавенство(Результат.КодСостояния, 400, "400 commits/id");
	ТелоОтвета = TestsCommonUseServer.AsText(Результат, КодировкаТекста.UTF8);
	Фреймворк.ПроверитьИстину(ПустаяСтрока(ТелоОтвета), "400 commits/id");

EndProcedure

#EndRegion

#Region Private

Function ДополнительныеПараметрыУспешногоЗапроса()
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "application/json");
	Заголовки.Вставить("X-Gitlab-Event", "Push Hook");
	Заголовки.Вставить("X-Gitlab-Token", "блаблаблаюниттест");
	Дополнительно = Новый Структура;
	Дополнительно.Вставить("Заголовки", Заголовки);
	Дополнительно.Вставить("Таймаут", 5);
	
	Возврат Дополнительно;
	 
EndFunction

Procedure УдалитьВсеОбработчикиСобытий()
	
	UtilsServer.CatalogCleanUp("Webhooks");

EndProcedure

#EndRegion