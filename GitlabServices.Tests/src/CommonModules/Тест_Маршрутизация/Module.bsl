#Region Internal

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура РаспределитьОтправляемыеДанныеПоМаршрутам(Фреймворк) Экспорт
	
	ROUTING_SETTINGS_MISSING_MESSAGE = НСтр( "ru = 'отсутствуют настройки маршрутизации.';
										|en = 'there are no routing settings.'" );
										
	DELIVERY_ROUTE_MISSING_MESSAGE = НСтр( "ru = 'не задан маршрут доставки файла.';
										|en = 'file delivery route not specified.'" );
	
	// given
	// ДанныеДляОтправки
	ДанныеДляОтправки = Новый ТаблицаЗначений();
	ДанныеДляОтправки.Колонки.Добавить( "FileName", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "URLFilePath", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "BinaryData", Новый ОписаниеТипов("BinaryData"));
	ДанныеДляОтправки.Колонки.Добавить( "Action", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "ErrorInfo", Новый ОписаниеТипов("Строка"));
	
	// 1. Для CommitSHA не найдены настройки маршрутизации
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "968eca170a80a5c825b0808734cb5b109eaedcd3";
	НоваяСтрока.FileName = "test1.epf";
	НоваяСтрока.URLFilePath = "Каталог 1/test1.epf";
	НоваяСтрока.Action = "modifed";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_1}");
	НоваяСтрока.ErrorInfo = "";
	
	// 2. Это файл не для отправки - настройки маршрутизации (пустая операция, скипается)
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.FileName = "файл с настройками маршрутизации.txt";
	НоваяСтрока.URLFilePath = "файл с настройками маршрутизации.txt";
	НоваяСтрока.Action = "";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_2}");
	НоваяСтрока.ErrorInfo = "";
	
	// 3. Была ошибка на какой-то стадии получения файлов
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.FileName = "test1.epf";
	НоваяСтрока.URLFilePath = "Каталог 1/test1.epf";
	НоваяСтрока.Action = "modifed";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_3}");
	НоваяСтрока.ErrorInfo = "тут какая-то ошибка";
	
	// 4. Нормальный файл (должен быть отправлен только по одному маршруту)
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.FileName = "test1.epf";
	НоваяСтрока.URLFilePath = "Каталог 1/test1.epf";
	НоваяСтрока.Action = "modifed";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_4}");
	НоваяСтрока.ErrorInfo = "";
	
	// 5. Нормальный файл (должен быть отправлен по двум маршрутам)
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.FileName = "test2.epf";
	НоваяСтрока.URLFilePath = "Каталог 2/test2.epf";
	НоваяСтрока.Action = "modifed";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_5}");
	НоваяСтрока.ErrorInfo = "";
	
	// 6. Файл не указан в маршрутах, не должен быть отправлен
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.FileName = "test3.epf";
	НоваяСтрока.URLFilePath = "Каталог 3/test3.epf";
	НоваяСтрока.Action = "modifed";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{some_json_6}");
	НоваяСтрока.ErrorInfo = "";
	
	// ДанныеЗапроса
	ЭталонRouting = "/home/usr1cv8/test/expectation-routing.json";
	Текст = Новый ЧтениеТекста(ЭталонRouting, КодировкаТекста.UTF8);
	JSON = Текст.Прочитать();
	JSON = HTTPConnector.JsonВОбъект(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());
	JSON = JSON.Получить("httpResponse").Получить("body").Получить("string");
	Settings = HTTPConnector.JsonВОбъект(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения());

	Commits = Новый Массив;
	Commit1 = Новый Соответствие;
	Commit1.Вставить("id", "968eca170a80a5c825b0808734cb5b109eaedcd3");
	Commit2 = Новый Соответствие;
	Commit2.Вставить("id", "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f");
	Commit2.Вставить("settings", Settings);
	Commit3 = Новый Соответствие;
	Commit3.Вставить("id", "d38eca1b4dd510ddb6788087348eca170a80a567");
	Commit3.Вставить("settings", Settings);
	Commits.Добавить(Commit1);
	Commits.Добавить(Commit2);
	Commits.Добавить(Commit3);
	
	ДанныеЗапроса = Новый Соответствие;
	ДанныеЗапроса.Вставить("commits", Commits);
	
	// when	
	Результат = Маршрутизация.РаспределитьОтправляемыеДанныеПоМаршрутам(ДанныеДляОтправки, ДанныеЗапроса);

	// then
	Фреймворк.ПроверитьРавенство(Результат.Количество(), 5);
	
	Фреймворк.ПроверитьРавенство(Результат[0].FileName, "test1.epf");
	Фреймворк.ПроверитьРавенство(Результат[0].АдресаДоставки, Неопределено);
	Фреймворк.ПроверитьРавенство(GetStringFromBinaryData(Результат[0].BinaryData), "{some_json_1}");
	Фреймворк.ПроверитьВхождение(Результат[0].ErrorInfo, ROUTING_SETTINGS_MISSING_MESSAGE);
	Фреймворк.ПроверитьРавенство(Результат[1].FileName, "test1.epf");
	Фреймворк.ПроверитьРавенство(Результат[1].АдресаДоставки, Неопределено);
	Фреймворк.ПроверитьРавенство(GetStringFromBinaryData(Результат[1].BinaryData), "{some_json_3}");
	Фреймворк.ПроверитьВхождение(Результат[1].ErrorInfo, "тут какая-то ошибка");
	
	Фреймворк.ПроверитьРавенство(Результат[2].FileName, "test1.epf");
	Фреймворк.ПроверитьРавенство(Результат[2].АдресаДоставки.Количество(), 1);
	Фреймворк.ПроверитьРавенство(Результат[2].АдресаДоставки[0], "http://mock-server:1080/receiver3");
	Фреймворк.ПроверитьРавенство(GetStringFromBinaryData(Результат[2].BinaryData), "{some_json_4}");
	Фреймворк.ПроверитьВхождение(Результат[2].ErrorInfo, "");
	
	Фреймворк.ПроверитьРавенство(Результат[3].FileName, "test2.epf");
	Фреймворк.ПроверитьРавенство(Результат[3].АдресаДоставки.Количество(), 2);
	Фреймворк.ПроверитьРавенство(Результат[3].АдресаДоставки[0], "http://mock-server:1080/receiver3");
	Фреймворк.ПроверитьРавенство(Результат[3].АдресаДоставки[1], "http://mock-server:1080/receiver1");
	Фреймворк.ПроверитьРавенство(GetStringFromBinaryData(Результат[3].BinaryData), "{some_json_5}");
	Фреймворк.ПроверитьВхождение(Результат[3].ErrorInfo, "");
	
	Фреймворк.ПроверитьРавенство(Результат[4].FileName, "test3.epf");
	Фреймворк.ПроверитьРавенство(Результат[4].АдресаДоставки, Неопределено);
	Фреймворк.ПроверитьРавенство(GetStringFromBinaryData(Результат[4].BinaryData), "{some_json_6}");
	Фреймворк.ПроверитьВхождение(Результат[4].ErrorInfo, DELIVERY_ROUTE_MISSING_MESSAGE);
	
КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура AddRoutingFilesDescription(Фреймворк) Экспорт
	
	// given
	Константы.RoutingFileName.Установить(".ext-epf.json");	
	// ОписаниеФайлов
	ОписаниеФайлов = Новый ТаблицаЗначений();
	ОписаниеФайлов.Колонки.Добавить( "RAWFilePath", Новый ОписаниеТипов("Строка") );
	ОписаниеФайлов.Колонки.Добавить( "FileName", Новый ОписаниеТипов("Строка") );
	ОписаниеФайлов.Колонки.Добавить( "URLFilePath", Новый ОписаниеТипов("Строка") );
	ОписаниеФайлов.Колонки.Добавить( "BinaryData", Новый ОписаниеТипов("BinaryData"));
	ОписаниеФайлов.Колонки.Добавить( "Action", Новый ОписаниеТипов("Строка") );
	ОписаниеФайлов.Колонки.Добавить( "Date", Новый ОписаниеТипов("Date") );
	ОписаниеФайлов.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	ОписаниеФайлов.Колонки.Добавить( "ErrorInfo", Новый ОписаниеТипов("Строка"));
	
	// ДанныеЗапроса
	JSON = "{
			|  ""project"": {
			|    ""id"": 1,
			|    ""http_url"": ""http://example.com/root/external-epf.git""
			|  },
			|  ""commits"": [
			|    {
			|      ""id"": ""1b9949a21e6c897b3dcb4dd510ddb5f893adae2f"",
			|      ""timestamp"": ""2020-07-21T09:22:31+00:00""
			|    },
			|    {
			|      ""id"": ""968eca170a80a5c825b0808734cb5b109eaedcd3"",
			|      ""timestamp"": ""2020-07-21T09:22:32+00:00""
			|    }
			|  ]
			|}";
	ПараметрыПреобразования = Новый Структура();
	ПараметрыПреобразования.Вставить( "ПрочитатьВСоответствие", Истина );
	ПараметрыПреобразования.Вставить( "ИменаСвойствСоЗначениямиДата", "timestamp" );
	ДанныеЗапроса = HTTPConnector.JsonВОбъект(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения(), , ПараметрыПреобразования);

	// when
	Маршрутизация.AddRoutingFilesDescription(ОписаниеФайлов, ДанныеЗапроса.Get("commits"), "1");	
	
	// then
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов.Количество(), 2);
	
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].RAWFilePath, "/api/v4/projects/1/repository/files/.ext-epf.json/raw?ref=1b9949a21e6c897b3dcb4dd510ddb5f893adae2f");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].CommitSHA, "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].FileName, "");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].URLFilePath, ".ext-epf.json");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].Action, "");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].Date, Date(2020,07,21,09,22,31));
	Фреймворк.ПроверитьЛожь(ЗначениеЗаполнено(ОписаниеФайлов[0].BinaryData));
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].ErrorInfo, "");
	
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].RAWFilePath, "/api/v4/projects/1/repository/files/.ext-epf.json/raw?ref=968eca170a80a5c825b0808734cb5b109eaedcd3");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].CommitSHA, "968eca170a80a5c825b0808734cb5b109eaedcd3");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].FileName, "");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].URLFilePath, ".ext-epf.json");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].Action, "");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].Date, Date(2020,07,21,09,22,32));
	Фреймворк.ПроверитьЛожь(ЗначениеЗаполнено(ОписаниеФайлов[1].BinaryData));
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].ErrorInfo, "");
	
КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ДополнитьЗапросНастройкамиМаршрутизации(Фреймворк) Экспорт

	// given
	Константы.RoutingFileName.Установить(".ext-epf.json");	
	// ДанныеТелаЗапроса
	JSON = "{
			|  ""project"": {
			|    ""id"": 1,
			|    ""http_url"": ""http://example.com/root/external-epf.git""
			|  },
			|  ""commits"": [
			|    {
			|      ""id"": ""1b9949a21e6c897b3dcb4dd510ddb5f893adae2f""
			|    },
			|    {
			|      ""id"": ""968eca170a80a5c825b0808734cb5b109eaedcd3""
			|    }
			|  ]
			|}";
	ПараметрыПреобразования = Новый Структура();
	ПараметрыПреобразования.Вставить( "ПрочитатьВСоответствие", Истина );
	ПараметрыПреобразования.Вставить( "ИменаСвойствСоЗначениямиДата", "timestamp" );
	ДанныеЗапроса = HTTPConnector.JsonВОбъект(GetBinaryDataFromString(JSON).ОткрытьПотокДляЧтения(), , ПараметрыПреобразования);

	// ДанныеДляОтправки
	ДанныеДляОтправки = Новый ТаблицаЗначений();
	ДанныеДляОтправки.Колонки.Добавить( "URLFilePath", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "BinaryData", Новый ОписаниеТипов("BinaryData"));
	ДанныеДляОтправки.Колонки.Добавить( "Action", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "ErrorInfo", Новый ОписаниеТипов("Строка"));
	
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.URLFilePath = ".ext-epf.json";
	НоваяСтрока.Action = "added";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{""name1"":""result1""}");
	НоваяСтрока.ErrorInfo = "";
	
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.URLFilePath = ".ext-epf.json";
	НоваяСтрока.Action = "";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{""name2"":""result2""}");
	НоваяСтрока.ErrorInfo = "";
	
	НоваяСтрока = ДанныеДляОтправки.Добавить();	
	НоваяСтрока.CommitSHA = "968eca170a80a5c825b0808734cb5b109eaedcd3";
	НоваяСтрока.URLFilePath = ".ext-epf.json";
	НоваяСтрока.Action = "";
	НоваяСтрока.BinaryData = GetBinaryDataFromString("{""name3"":""result3""}");
	НоваяСтрока.ErrorInfo = "тут какая-то ошибка";

	// when
	Маршрутизация.ДополнитьЗапросНастройкамиМаршрутизации(ДанныеЗапроса, ДанныеДляОтправки);

	// then
	Фреймворк.ПроверитьРавенство(ДанныеЗапроса.Количество(), 2);
	Фреймворк.ПроверитьРавенство(ДанныеЗапроса.Получить("commits")[0].Получить("settings").Получить("name2"), "result2");
	Фреймворк.ПроверитьРавенство(ДанныеЗапроса.Получить("commits")[0].Получить("settings").Получить("json"), "{""name2"":""result2""}");
	Фреймворк.ПроверитьРавенство(ДанныеЗапроса.Получить("commits")[1].Получить("settings"), Неопределено);
	
КонецПроцедуры

#EndRegion