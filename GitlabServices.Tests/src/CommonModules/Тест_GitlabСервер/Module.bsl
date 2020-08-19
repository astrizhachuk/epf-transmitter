#Область СлужебныйПрограммныйИнтерфейс

// @unit-test:dev
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ПолучитьФайл(Фреймворк) Экспорт

	Мок = Обработки.MockServerClient.Создать();
	Мок.Сервер("http://host.docker.internal:1080").Сбросить();
	
//	Мок.Когда(Мок.Запрос()
//					.Метод()
//					.Заголовок(),
//					.Заголовок(),
//					).Ожидаем();

МассивПараметров = Новый Массив;
МассивПараметров.Добавить("-U2ssrBsM4rmx85HXzZ1");
	Заголовки = Новый Соответствие();
	Заголовки.Вставить("PRIVATE-TOKEN", МассивПараметров);
	ТелоЗапроса = Новый Соответствие;
	ТелоЗапроса.Вставить("path", "/%D1%84%D1%8D%D0%B9%D0%BA.epf" );
	ТелоЗапроса.Вставить("headers",Заголовки);
	ТелоОтвета = Новый Соответствие;
	ТелоОтвета.Вставить("statusCode", 404 );
	Итого=новый Соответствие();
	Итого.Вставить("httpResponse", ТелоОтвета);	
	Итого.Вставить("httpRequest", ТелоЗапроса);

Итого = Мок.Запрос().Метод("GET").Путь("/%D1%84%D1%8D%D0%B9%D0%BA.epf").Заголовок("PRIVATE-TOKEN", "-U2ssrBsM4rmx85HXzZ1")
	.Ответ().КодОтвета(404);

//	json=КоннекторHTTP.ОбъектВJson(Итого);

	Результат = КоннекторHTTP.PutJson("http://host.docker.internal:1080/mockserver/expectation",Итого.Конструктор);
	
//	Запрос = "
//		|		""method"": ""GET"",
//		|		""path"": ""/%D1%84%D1%8D%D0%B9%D0%BA.epf"",
//		|		""headers"": {
//		|       	""PRIVATE-TOKEN"": [
//		|           	""-U2ssrBsM4rmx85HXzZ1""
//		|			]
//		|		}";
//		
//	Ответ = "
//		|		""statusCode"": 404
//		|";

//	Мок.Когда(Запрос).Ожидаем(Ответ);
	
	Запрос = "
		|		""method"": ""GET"",
		|       ""path"": ""/api/v4/projects/1/repository/files/%D0%9A%D0%B0%D1%82%D0%B0%D0%BB%D0%BE%D0%B3%20%D1%81%20%D0%BE%D1%82%D1%87%D0%B5%D1%82%D0%B0%D0%BC%D0%B8%20%D0%B8%20%D0%BE%D0%B1%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0%D0%BC%D0%B8%2F%D0%92%D0%BD%D0%B5%D1%88%D0%BD%D1%8F%D1%8F%20%D0%9E%D0%B1%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0%201.epf/raw"",
		|       ""queryStringParameters"": {
		|       	""ref"": [
		|           	""ef3529e5486ff39c6439ab5d745eb56588202b86""
		|       	],
		|       },
		|       ""headers"": {
		|       	""PRIVATE-TOKEN"": [
		|       		""!-U2ssrBsM4rmx85HXzZ1""
		|       	]
		|		}";
		
	Ответ = "
		|		""statusCode"": 401
		|";

	Мок.Когда(Запрос).Ожидаем(Ответ);

	Запрос = "
		|       ""method"": ""GET"",
		|       ""path"": ""/api/v4/projects/1/repository/files/%D0%9A%D0%B0%D1%82%D0%B0%D0%BB%D0%BE%D0%B3%20%D1%81%20%D0%BE%D1%82%D1%87%D0%B5%D1%82%D0%B0%D0%BC%D0%B8%20%D0%B8%20%D0%BE%D0%B1%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0%D0%BC%D0%B8%2F%D0%92%D0%BD%D0%B5%D1%88%D0%BD%D1%8F%D1%8F%20%D0%9E%D0%B1%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0%201.epf/raw"",
		|       ""queryStringParameters"": {
		|           ""ref"": [
		|               ""ef3529e5486ff39c6439ab5d745eb56588202b86""
		|           ]
		|       },
		|       ""headers"": {
		|           ""PRIVATE-TOKEN"": [
		|               ""-U2ssrBsM4rmx85HXzZ1""
		|           ]
		|       }";
		
	Ответ = "
		|       ""statusCode"": 200,
		|       ""headers"": {
		|           ""X-Gitlab-File-Name"": [
		|               ""ÐÐ½ÐµÑÐ½ÑÑ ÐÐ±ÑÐ°Ð±Ð¾ÑÐºÐ° 1.epf""
		|           ]
		|       },
		|       ""body"": ""some_response_body""
		|";

	Мок.Когда(Запрос).Ожидаем(Ответ);
	Мок = Неопределено;
		
	URL="http://host.docker.internal:1080";
	commit = "ef3529e5486ff39c6439ab5d745eb56588202b86";
	ПутьКФайлу = КодироватьСтроку(	"Каталог с отчетами и обработками/Внешняя Обработка 1.epf",
									СпособКодированияСтроки.КодировкаURL );
	ПутьКФайлу = СтрШаблон("/api/v4/projects/1/repository/files/%1/raw?ref=%2", ПутьКФайлу, commit);
	GitLabUserPrivateToken = "-U2ssrBsM4rmx85HXzZ1";

	// given
	// ошибка, неверный URL
	ФэйкURL = "http://фэйк";
	// when
	Результат = Gitlab.ПолучитьФайл(ФэйкURL, ПутьКФайлу, GitLabUserPrivateToken, 5);
	// then
	Фреймворк.ПроверитьНеРавенство(Результат.Ошибка, Неопределено);

	// given	
	// 404
	ФэйкПутьКФайлу = "/фэйк.epf";
	// when
	Результат = Gitlab.ПолучитьФайл(URL, ФэйкПутьКФайлу, GitLabUserPrivateToken, 5);
	// then
	Фреймворк.ПроверитьНеРавенство(Результат.Ошибка, Неопределено);

	// given
	// 401
	ФэйкGitLabUserPrivateToken = "1234567890";
	// when
	Результат = Gitlab.ПолучитьФайл(URL, ПутьКФайлу, ФэйкGitLabUserPrivateToken, 5);
	// then
	Фреймворк.ПроверитьНеРавенство(Результат.Ошибка, Неопределено);

	// given
	// 200
	// when
	Результат = Gitlab.ПолучитьФайл(URL, ПутьКФайлу, GitLabUserPrivateToken, 5);
	// then	
	Фреймворк.ПроверитьТип(Результат, "Структура");
	Фреймворк.ПроверитьРавенство(Результат.ИмяФайлаИзЗапроса, "Внешняя Обработка 1.epf");
	FromWin1251 = СтроковыеФункцииКлиентСервер.ПерекодироватьСтроку("Внешняя Обработка 1.epf", "windows-1251");
	Фреймворк.ПроверитьРавенство(Результат.ИмяФайла, FromWin1251);
	Фреймворк.ПроверитьТип(Результат.Данные, "ДвоичныеДанные");
	Фреймворк.ПроверитьРавенство(Результат.Ошибка, Неопределено);

КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ПутьКФайлуRAW(Фреймворк) Экспорт
	
	Эталон = "/api/v4/projects/1/repository/files/%D0%B0%2F%D0%B1%2F%D0%B2/raw?ref=0123456789";
	Результат = Gitlab.ПутьКФайлуRAW(1, "а/б/в", "0123456789");
	Фреймворк.ПроверитьРавенство(Результат, Эталон);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции


#КонецОбласти
