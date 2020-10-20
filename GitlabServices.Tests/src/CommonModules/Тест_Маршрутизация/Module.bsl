#Область СлужебныйПрограммныйИнтерфейс

// @unit-test:dev
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура РаспределитьОтправляемыеДанныеПоМаршрутам(Фреймворк) Экспорт
	
	// given
	// ДанныеДляОтправки
	ДанныеДляОтправки = Новый ТаблицаЗначений();
	ДанныеДляОтправки.Колонки.Добавить( "ИмяФайла", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "ПолноеИмяФайла", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "ДвоичныеДанные", Новый ОписаниеТипов("ДвоичныеДанные"));
	ДанныеДляОтправки.Колонки.Добавить( "Операция", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "ОписаниеОшибки", Новый ОписаниеТипов("Строка"));
	
	// 1. Для CommitSHA не найдены настройки маршрутизации
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "968eca170a80a5c825b0808734cb5b109eaedcd3";
	НоваяСтрока.ИмяФайла = "test1.epf";
	НоваяСтрока.ПолноеИмяФайла = "Каталог 1/test1.epf";
	НоваяСтрока.Операция = "modifed";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{some_json_1}");
	НоваяСтрока.ОписаниеОшибки = "";
	
	// 2. Это файл не для отправки - настройки маршрутизации (пустая операция, скипается)
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.ИмяФайла = "файл с настройками маршрутизации.txt";
	НоваяСтрока.ПолноеИмяФайла = "файл с настройками маршрутизации.txt";
	НоваяСтрока.Операция = "";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{some_json_2}");
	НоваяСтрока.ОписаниеОшибки = "";
	
	// 3. Была ошибка на какой-то стадии получения файлов
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.ИмяФайла = "test1.epf";
	НоваяСтрока.ПолноеИмяФайла = "Каталог 1/test1.epf";
	НоваяСтрока.Операция = "modifed";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{some_json_3}");
	НоваяСтрока.ОписаниеОшибки = "тут какая-то ошибка";
	
	// 4. Нормальный файл (должен быть отправлен только по одному маршруту)
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.ИмяФайла = "test1.epf";
	НоваяСтрока.ПолноеИмяФайла = "Каталог 1/test1.epf";
	НоваяСтрока.Операция = "modifed";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{some_json_4}");
	НоваяСтрока.ОписаниеОшибки = "";
	
	// 5. Нормальный файл (должен быть отправлен по двум маршрутам)
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.ИмяФайла = "test2.epf";
	НоваяСтрока.ПолноеИмяФайла = "Каталог 2/test2.epf";
	НоваяСтрока.Операция = "modifed";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{some_json_5}");
	НоваяСтрока.ОписаниеОшибки = "";
	
	// 6. Файл не указан в маршрутах, не должен быть отправлен
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.ИмяФайла = "test3.epf";
	НоваяСтрока.ПолноеИмяФайла = "Каталог 3/test3.epf";
	НоваяСтрока.Операция = "modifed";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{some_json_6}");
	НоваяСтрока.ОписаниеОшибки = "";
	
	// ДанныеЗапроса
	ЭталонRouting = "/home/usr1cv8/test/expectation-routing.json";
	Текст = Новый ЧтениеТекста(ЭталонRouting, КодировкаТекста.UTF8);
	JSON = Текст.Прочитать();
	JSON = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения());
	JSON = JSON.Получить("httpResponse").Получить("body").Получить("string");
	Settings = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения());

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
	
	Фреймворк.ПроверитьРавенство(Результат[0].ИмяФайла, "test1.epf");
	Фреймворк.ПроверитьРавенство(Результат[0].АдресаДоставки, Неопределено);
	Фреймворк.ПроверитьРавенство(ПолучитьСтрокуИзДвоичныхДанных(Результат[0].ДвоичныеДанные), "{some_json_1}");
	Фреймворк.ПроверитьВхождение(Результат[0].ОписаниеОшибки, "отсутствуют настройки маршрутизации");
	
	Фреймворк.ПроверитьРавенство(Результат[1].ИмяФайла, "test1.epf");
	Фреймворк.ПроверитьРавенство(Результат[1].АдресаДоставки, Неопределено);
	Фреймворк.ПроверитьРавенство(ПолучитьСтрокуИзДвоичныхДанных(Результат[1].ДвоичныеДанные), "{some_json_3}");
	Фреймворк.ПроверитьВхождение(Результат[1].ОписаниеОшибки, "тут какая-то ошибка");
	
	Фреймворк.ПроверитьРавенство(Результат[2].ИмяФайла, "test1.epf");
	Фреймворк.ПроверитьРавенство(Результат[2].АдресаДоставки.Количество(), 1);
	Фреймворк.ПроверитьРавенство(Результат[2].АдресаДоставки[0], "http://mock-server:1080/receiver3");
	Фреймворк.ПроверитьРавенство(ПолучитьСтрокуИзДвоичныхДанных(Результат[2].ДвоичныеДанные), "{some_json_4}");
	Фреймворк.ПроверитьВхождение(Результат[2].ОписаниеОшибки, "");
	
	Фреймворк.ПроверитьРавенство(Результат[3].ИмяФайла, "test2.epf");
	Фреймворк.ПроверитьРавенство(Результат[3].АдресаДоставки.Количество(), 2);
	Фреймворк.ПроверитьРавенство(Результат[3].АдресаДоставки[0], "http://mock-server:1080/receiver3");
	Фреймворк.ПроверитьРавенство(Результат[3].АдресаДоставки[1], "http://mock-server:1080/receiver1");
	Фреймворк.ПроверитьРавенство(ПолучитьСтрокуИзДвоичныхДанных(Результат[3].ДвоичныеДанные), "{some_json_5}");
	Фреймворк.ПроверитьВхождение(Результат[3].ОписаниеОшибки, "");
	
	Фреймворк.ПроверитьРавенство(Результат[4].ИмяФайла, "test3.epf");
	Фреймворк.ПроверитьРавенство(Результат[4].АдресаДоставки, Неопределено);
	Фреймворк.ПроверитьРавенство(ПолучитьСтрокуИзДвоичныхДанных(Результат[4].ДвоичныеДанные), "{some_json_6}");
	Фреймворк.ПроверитьВхождение(Результат[4].ОписаниеОшибки, "не задан маршрут доставки файла");
	
КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура СформироватьОписаниеФайловМаршрутизации(Фреймворк) Экспорт
	
	// given
	Константы.ИмяФайлаНастроекМаршрутизации.Установить(".ext-epf.json");	
	// ОписаниеФайлов
	ОписаниеФайлов = Новый ТаблицаЗначений();
	ОписаниеФайлов.Колонки.Добавить( "ПутьКФайлуRAW", Новый ОписаниеТипов("Строка") );
	ОписаниеФайлов.Колонки.Добавить( "ИмяФайла", Новый ОписаниеТипов("Строка") );
	ОписаниеФайлов.Колонки.Добавить( "ПолноеИмяФайла", Новый ОписаниеТипов("Строка") );
	ОписаниеФайлов.Колонки.Добавить( "ДвоичныеДанные", Новый ОписаниеТипов("ДвоичныеДанные"));
	ОписаниеФайлов.Колонки.Добавить( "Операция", Новый ОписаниеТипов("Строка") );
	ОписаниеФайлов.Колонки.Добавить( "Дата", Новый ОписаниеТипов("Дата") );
	ОписаниеФайлов.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	ОписаниеФайлов.Колонки.Добавить( "ОписаниеОшибки", Новый ОписаниеТипов("Строка"));
	
	// ДанныеЗапроса
	JSON = НСтр("ru = '{
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
				|}'");
	ПараметрыПреобразования = Новый Структура();
	ПараметрыПреобразования.Вставить( "ПрочитатьВСоответствие", Истина );
	ПараметрыПреобразования.Вставить( "ИменаСвойствСоЗначениямиДата", "timestamp" );
	ДанныеЗапроса = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения(), , ПараметрыПреобразования);

	// ПараметрыПроекта
	ПараметрыПроекта = Новый Структура;
	ПараметрыПроекта.Вставить("Идентификатор", "1");
	ПараметрыПроекта.Вставить("АдресСервера", "http://example.com");

	// when
	Маршрутизация.СформироватьОписаниеФайловМаршрутизации(ОписаниеФайлов, ДанныеЗапроса, ПараметрыПроекта);	
	
	// then
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов.Количество(), 2);
	
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].ПутьКФайлуRAW, "/api/v4/projects/1/repository/files/.ext-epf.json/raw?ref=1b9949a21e6c897b3dcb4dd510ddb5f893adae2f");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].CommitSHA, "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].ИмяФайла, "");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].ПолноеИмяФайла, ".ext-epf.json");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].Операция, "");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].Дата, Дата(2020,07,21,09,22,31));
	Фреймворк.ПроверитьЛожь(ЗначениеЗаполнено(ОписаниеФайлов[0].ДвоичныеДанные));
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[0].ОписаниеОшибки, "");
	
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].ПутьКФайлуRAW, "/api/v4/projects/1/repository/files/.ext-epf.json/raw?ref=968eca170a80a5c825b0808734cb5b109eaedcd3");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].CommitSHA, "968eca170a80a5c825b0808734cb5b109eaedcd3");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].ИмяФайла, "");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].ПолноеИмяФайла, ".ext-epf.json");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].Операция, "");
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].Дата, Дата(2020,07,21,09,22,32));
	Фреймворк.ПроверитьЛожь(ЗначениеЗаполнено(ОписаниеФайлов[1].ДвоичныеДанные));
	Фреймворк.ПроверитьРавенство(ОписаниеФайлов[1].ОписаниеОшибки, "");
	
КонецПроцедуры

// @unit-test
// Параметры:
// 	Фреймворк - ФреймворкТестирования - Фреймворк тестирования
//
Процедура ДополнитьЗапросНастройкамиМаршрутизации(Фреймворк) Экспорт

	// given
	Константы.ИмяФайлаНастроекМаршрутизации.Установить(".ext-epf.json");	
	// ДанныеТелаЗапроса
	JSON = НСтр("ru = '{
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
				|}'");
	ПараметрыПреобразования = Новый Структура();
	ПараметрыПреобразования.Вставить( "ПрочитатьВСоответствие", Истина );
	ПараметрыПреобразования.Вставить( "ИменаСвойствСоЗначениямиДата", "timestamp" );
	ДанныеЗапроса = HTTPConnector.JsonВОбъект(ПолучитьДвоичныеДанныеИзСтроки(JSON).ОткрытьПотокДляЧтения(), , ПараметрыПреобразования);

	// ДанныеДляОтправки
	ДанныеДляОтправки = Новый ТаблицаЗначений();
	ДанныеДляОтправки.Колонки.Добавить( "ПолноеИмяФайла", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "ДвоичныеДанные", Новый ОписаниеТипов("ДвоичныеДанные"));
	ДанныеДляОтправки.Колонки.Добавить( "Операция", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "CommitSHA", Новый ОписаниеТипов("Строка") );
	ДанныеДляОтправки.Колонки.Добавить( "ОписаниеОшибки", Новый ОписаниеТипов("Строка"));
	
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.ПолноеИмяФайла = ".ext-epf.json";
	НоваяСтрока.Операция = "added";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{""name1"":""result1""}");
	НоваяСтрока.ОписаниеОшибки = "";
	
	НоваяСтрока = ДанныеДляОтправки.Добавить();
	НоваяСтрока.CommitSHA = "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f";
	НоваяСтрока.ПолноеИмяФайла = ".ext-epf.json";
	НоваяСтрока.Операция = "";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{""name2"":""result2""}");
	НоваяСтрока.ОписаниеОшибки = "";
	
	НоваяСтрока = ДанныеДляОтправки.Добавить();	
	НоваяСтрока.CommitSHA = "968eca170a80a5c825b0808734cb5b109eaedcd3";
	НоваяСтрока.ПолноеИмяФайла = ".ext-epf.json";
	НоваяСтрока.Операция = "";
	НоваяСтрока.ДвоичныеДанные = ПолучитьДвоичныеДанныеИзСтроки("{""name3"":""result3""}");
	НоваяСтрока.ОписаниеОшибки = "тут какая-то ошибка";

	// when
	Маршрутизация.ДополнитьЗапросНастройкамиМаршрутизации(ДанныеЗапроса, ДанныеДляОтправки);

	// then
	Фреймворк.ПроверитьРавенство(ДанныеЗапроса.Количество(), 2);
	Фреймворк.ПроверитьРавенство(ДанныеЗапроса.Получить("commits")[0].Получить("settings").Получить("name2"), "result2");
	Фреймворк.ПроверитьРавенство(ДанныеЗапроса.Получить("commits")[0].Получить("settings").Получить("json"), "{""name2"":""result2""}");
	Фреймворк.ПроверитьРавенство(ДанныеЗапроса.Получить("commits")[1].Получить("settings"), Неопределено);
	
КонецПроцедуры

#КонецОбласти