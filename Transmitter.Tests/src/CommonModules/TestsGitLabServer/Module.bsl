#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetRequestHandlerStateMessage(Framework) Export

	// given
	Constants.HandleRequests.Set(False);
	Constants.HandleRequests.Set(True);
	// when
	Result = GitLab.GetRequestHandlerStateMessage();
	// then
	Framework.AssertStringContains(Result.message, NStr("ru = 'включена';en = 'enabled'" ));
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure RemoteFileBadURL(Фреймворк) Export
	
	// given
	ПараметрыСоединения = Новый Структура();
	ПараметрыСоединения.Вставить( "URL", "http://фэйк" );
	ПараметрыСоединения.Вставить( "Token", "-U2ssrBsM4rmx85HXzZ1" );
	ПараметрыСоединения.Вставить( "Timeout", 5 );

	RAWFilePath = "/test";
	
	// when
	Результат = Gitlab.RemoteFile(ПараметрыСоединения, RAWFilePath);
	
	// then
	Фреймворк.ПроверитьНеРавенство(Результат.ErrorInfo, Неопределено);
	Фреймворк.ПроверитьВхождение(Результат.ErrorInfo, "Couldn't resolve host name");

EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure RemoteFile404NotFound(Фреймворк) Export

	// given
	URL = "http://mockserver:1080";

	ПараметрыСоединения = Новый Структура();
	ПараметрыСоединения.Вставить( "URL", URL );
	ПараметрыСоединения.Вставить( "Token", "-U2ssrBsM4rmx85HXzZ1" );
	ПараметрыСоединения.Вставить( "Timeout", 5 );
	
	ФэйкRAWFilePath = "/фэйк.epf";

	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL, , Истина)
    	.Когда(
			Мок.Запрос()
				.Метод("GET")
				.Путь("/%D1%84%D1%8D%D0%B9%D0%BA.epf")
				.Заголовки()
					.Заголовок("PRIVATE-TOKEN", "-U2ssrBsM4rmx85HXzZ1")
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(404)
	    );
	Мок = Неопределено;

	// when
	Результат = Gitlab.RemoteFile(ПараметрыСоединения, ФэйкRAWFilePath);
	
	// then
	Фреймворк.ПроверитьНеРавенство(Результат.ErrorInfo, Неопределено);
	Фреймворк.ПроверитьВхождение(Результат.ErrorInfo, HTTPStatusCodesClientServerCached.FindIdByCode(404));
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure RemoteFile401Unauthorized(Фреймворк) Export
	
	// given
	URL = "http://mockserver:1080";
	ФэйкGitLabUserPrivateToken = "1234567890";
	
	ПараметрыСоединения = Новый Структура();
	ПараметрыСоединения.Вставить( "URL", URL );
	ПараметрыСоединения.Вставить( "Token", ФэйкGitLabUserPrivateToken );
	ПараметрыСоединения.Вставить( "Timeout", 5 );
	
	RAWFilePath = "/path/test.epf";

	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL, , Истина)
    	.Когда(
			Мок.Запрос()
				.Метод("GET").Путь(RAWFilePath).Заголовок("PRIVATE-TOKEN", "!-U2ssrBsM4rmx85HXzZ1")
    	)
	    .Ответить(
	        Мок.Ответ().КодОтвета(401)
	    );
	Мок = Неопределено;

	// when
	Результат = Gitlab.RemoteFile(ПараметрыСоединения, RAWFilePath);
	
	// then
	Фреймворк.ПроверитьНеРавенство(Результат.ErrorInfo, Неопределено);
	Фреймворк.ПроверитьВхождение(Результат.ErrorInfo, HTTPStatusCodesClientServerCached.FindIdByCode(401));
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure RemoteFileEmpty(Фреймворк) Export
	
	// given	
	URL = "http://mockserver:1080";
	Токен = "-U2ssrBsM4rmx85HXzZ1";
	Commit = "commit";
	RAWFilePath = "/path/raw";
	
	ПараметрыСоединения = Новый Структура();
	ПараметрыСоединения.Вставить( "URL", URL );
	ПараметрыСоединения.Вставить( "Token", Токен );
	ПараметрыСоединения.Вставить( "Timeout", 5 );

	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL, , Истина)
    	.Когда(
			Мок.Запрос()
				.Метод("GET")
				.Путь(RAWFilePath)
				.ПараметрСтрокиЗапроса("ref", Commit)
				.Заголовки()
					.Заголовок("PRIVATE-TOKEN", Токен)
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(200)
				.Заголовки()
					.Заголовок("X-Gitlab-File-Name", "test.epf")
	    );
	Мок = Неопределено;

	// when
	Результат = Gitlab.RemoteFile(ПараметрыСоединения, RAWFilePath + "?ref=" + Commit);

	// then
	Фреймворк.ПроверитьНеРавенство(Результат.ErrorInfo, Неопределено);
	Фреймворк.ПроверитьВхождение(Результат.ErrorInfo, НСтр("ru = 'Пустой файл.'"));
	
EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure RemoteFile200Ok(Фреймворк) Export
	
	// given	
	URL = "http://mockserver:1080";
	Токен = "-U2ssrBsM4rmx85HXzZ1";
	
	ПараметрыСоединения = Новый Структура();
	ПараметрыСоединения.Вставить( "URL", URL );
	ПараметрыСоединения.Вставить( "Token", Токен );
	ПараметрыСоединения.Вставить( "Timeout", 5 );
	
	Commit = "ef3529e5486ff39c6439ab5d745eb56588202b86";
	RAWFilePath = КодироватьСтроку(	"Каталог с отчетами и обработками/Внешняя Обработка 1.epf",
									СпособКодированияСтроки.КодировкаURL );
	RAWFilePath = СтрШаблон("/api/v4/projects/1/repository/files/%1/raw?ref=%2", RAWFilePath, Commit);
	
	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL, , Истина)
    	.Когда(
			Мок.Запрос()
				.Метод("GET")
				.Путь("/api/v4/projects/1/repository/files/%D0%9A%D0%B0%D1%82%D0%B0%D0%BB%D0%BE%D0%B3%20%D1%81%20%D0%BE%D1%82%D1%87%D0%B5%D1%82%D0%B0%D0%BC%D0%B8%20%D0%B8%20%D0%BE%D0%B1%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0%D0%BC%D0%B8%2F%D0%92%D0%BD%D0%B5%D1%88%D0%BD%D1%8F%D1%8F%20%D0%9E%D0%B1%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0%201.epf/raw")
				.ПараметрСтрокиЗапроса("ref", "ef3529e5486ff39c6439ab5d745eb56588202b86")
				.Заголовки()
					.Заголовок("PRIVATE-TOKEN", Токен)
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(200)
				.Заголовки()
					.Заголовок("X-Gitlab-File-Name", "cyrillic do not work 1.epf")
				.Тело("some_response_body")
	    );
	Мок = Неопределено;

	// when
	Результат = Gitlab.RemoteFile(ПараметрыСоединения, RAWFilePath);
	
	// then	
	Фреймворк.ПроверитьТип(Результат, "Структура");
	Фреймворк.ПроверитьРавенство(Результат.RAWFilePath, RAWFilePath);
	Фреймворк.ПроверитьРавенство(Результат.FileName, "cyrillic do not work 1.epf");
	Фреймворк.ПроверитьТип(Результат.BinaryData, "BinaryData");
	Фреймворк.ПроверитьРавенство(Результат.ErrorInfo, "");

EndProcedure

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure RemoteFiles(Фреймворк) Export
	
	// given	
	URL = "http://mockserver:1080";
	Токен = "-U2ssrBsM4rmx85HXzZ1";
	
	CommitSHA = "commit";
	RAWFilePath1 = "/path/test1.epf";
	RAWFilePath2 = "/path/test2.epf";
	
	ПараметрыСоединения = Новый Структура();
	ПараметрыСоединения.Вставить( "URL", URL );
	ПараметрыСоединения.Вставить( "Token", Токен );
	ПараметрыСоединения.Вставить( "Timeout", 5 );

	ПутиКФайлам = Новый Массив;
	ПутиКФайлам.Добавить(RAWFilePath1 + "?ref=" + CommitSHA);
	ПутиКФайлам.Добавить(RAWFilePath2 + "?ref=" + CommitSHA);
	ПутиКФайлам.Добавить("/фэйк");
	
	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL, , Истина)
    	.Когда(
			Мок.Запрос()
				.Метод("GET").Путь(RAWFilePath1).ПараметрСтрокиЗапроса("ref", CommitSHA).Заголовок("PRIVATE-TOKEN", Токен)
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(200).Заголовок("X-Gitlab-File-Name", "test1.epf").Тело("some_response_body")
	    );
	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер(URL)
    	.Когда(
			Мок.Запрос()
				.Метод("GET").Путь(RAWFilePath2).ПараметрСтрокиЗапроса("ref", CommitSHA).Заголовок("PRIVATE-TOKEN", Токен)
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(200).Заголовок("X-Gitlab-File-Name", "test2.epf").Тело("some_response_body")
	    );
	Мок = Неопределено;

	// when
	Результат = Gitlab.RemoteFiles(ПараметрыСоединения, ПутиКФайлам);
	
	// then	
	Фреймворк.ПроверитьТип(Результат, "Массив");
	Фреймворк.ПроверитьРавенство(Результат[0].RAWFilePath, RAWFilePath1 + "?ref=" + CommitSHA);
	Фреймворк.ПроверитьРавенство(Результат[0].FileName, "test1.epf");
	Фреймворк.ПроверитьТип(Результат[0].BinaryData, "BinaryData");
	Фреймворк.ПроверитьРавенство(Результат[0].ErrorInfo, "");
	Фреймворк.ПроверитьРавенство(Результат[1].RAWFilePath, RAWFilePath2 + "?ref=" + CommitSHA);
	Фреймворк.ПроверитьРавенство(Результат[1].FileName, "test2.epf");
	Фреймворк.ПроверитьТип(Результат[1].BinaryData, "BinaryData");
	Фреймворк.ПроверитьРавенство(Результат[1].ErrorInfo, "");
	Фреймворк.ПроверитьВхождение(Результат[2].ErrorInfo, "NOT_FOUND");

EndProcedure


// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Procedure MergeRequests(Фреймворк) Export
	
	// given
	URL = "http://mockserver:1080";
	Токен = "-U2ssrBsM4rmx85HXzZ1";

	Константы.ExternalStorageToken.Установить(Токен);
	Константы.ExternalStorageTimeout.Установить(5);
	
	ПутьMR = "/api/v4/projects/1/merge_requests";
	JSON = "[
			 |	{
			 |		""project_id"": 1,
			 |		""merge_commit_sha"": null,
			 |		""web_url"": ""http://gitlab/root/external-epf/-/merge_requests/4""
			 |	},
			 |	{
			 |		""project_id"": 1,
			 |		""merge_commit_sha"": ""c1775c33f82fcf22b3c2c4a5b4e95e430ef35d89"",
			 |		""web_url"": ""http://gitlab/root/external-epf/-/merge_requests/3""
			 |	},
			 |	{
			 |		""project_id"": 1,
			 |		""merge_commit_sha"": ""87fc6b2782f1bcadce980cb52941e2bd90974c0f"",
			 |		""web_url"": ""http://gitlab/root/external-epf/-/merge_requests/2""
			 |	},
			 |	{
			 |		""project_id"": 1,
			 |		""merge_commit_sha"": ""686109dffcee3e8ef51013f2e7702a8590eb5d73"",
			 |		""web_url"": ""http://gitlab/root/external-epf/-/merge_requests/1""
			 |	}
			 |]";

	Мок = Обработки.MockServerClient.Создать();

	Мок.Сервер(URL, , Истина)
    	.Когда(
			Мок.Запрос()
				.Метод("GET").Путь(ПутьMR).Заголовок("PRIVATE-TOKEN", Токен)
    	)
	    .Ответить(
	        Мок.Ответ()
	        	.КодОтвета(200).Тело(JSON)
	    );
	Мок = Неопределено;
	
	// when
	Результат = Gitlab.MergeRequests( "http://mockserver:1080", 1 );
	
	// then
	Фреймворк.ПроверитьРавенство(Результат.Количество(), 4);
	Фреймворк.ПроверитьРавенство(Результат[0].Количество(), 3);
	Фреймворк.ПроверитьРавенство(Результат[0].Get("project_id"), 1);
	Фреймворк.ПроверитьРавенство(Результат[0].Get("web_url"), "http://gitlab/root/external-epf/-/merge_requests/4");
	
EndProcedure

#EndRegion
