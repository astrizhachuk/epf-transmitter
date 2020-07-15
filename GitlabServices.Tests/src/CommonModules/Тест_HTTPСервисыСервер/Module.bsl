// BSLLS-выкл.
#Область СлужебныйПрограммныйИнтерфейс

// @unit-test
Процедура Тест_СтруктураОтвета(Фреймворк) Экспорт

	Результат = HTTPСервисы.СтруктураОтвета();
	Фреймворк.ПроверитьРавенство(Результат.Количество(), 2);
	Фреймворк.ПроверитьИстину(Результат.Свойство("type"));
	Фреймворк.ПроверитьИстину(Результат.Свойство("message"));
	
КонецПроцедуры

// TODO перепроверить, возможно уже не нужная процедура
// @unit-test
Процедура Тест_МетодТелоHTTPОтветаВКоллекциюКакJSON(Фреймворк) Экспорт

	ЭталонJSON = "{
				 |""Ключ1"": ""Значение1""
				 |}";
	ЭталонКоллекция = Новый Структура("Ключ1", "Значение1");

	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.УстановитьТелоИзСтроки( ЭталонJSON);

	Коллекция1 = Неопределено;
	HTTPСервисы.ТелоHTTPОтветаВКоллекциюКакJSON( Ответ, Истина, Ложь, Коллекция1);

	Коллекция2 = Неопределено;
	HTTPСервисы.ТелоHTTPОтветаВКоллекциюКакJSON( Ответ, Ложь, Ложь, Коллекция2);

	Коллекция3 = Неопределено;
	HTTPСервисы.ТелоHTTPОтветаВКоллекциюКакJSON( Ответ, Истина, Истина, Коллекция3);

	Фреймворк.ПроверитьТип( Коллекция1, "Соответствие");
	Фреймворк.ПроверитьТип( Коллекция2, "Структура");

	Фреймворк.ПроверитьРавенство( Коллекция1.Количество(), 1);
	Фреймворк.ПроверитьРавенство( Коллекция2.Количество(), 1);
	Фреймворк.ПроверитьРавенство( Коллекция3.Количество(), 2);

	Фреймворк.ПроверитьРавенство( ЭталонКоллекция.Ключ1, Коллекция1.Получить("Ключ1"));
	Фреймворк.ПроверитьРавенство( ЭталонКоллекция.Ключ1, Коллекция2.Ключ1);
	Фреймворк.ПроверитьРавенство( ЭталонJSON, Коллекция3.Получить("json"));

КонецПроцедуры

Функция WebhooksPOST(URL, СекретныйКлюч, ТестовыеДанные = Неопределено, Адрес = "") Экспорт

	JSON = Неопределено;
	Если НЕ ПустаяСтрока(Адрес) Тогда
		Данные = ПолучитьИзВременногоХранилища(Адрес);
		JSON = ПолучитьСтрокуИзДвоичныхДанных(Данные, КодировкаТекста.UTF8);
	КонецЕсли;
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "application/json");
	Заголовки.Вставить("X-Gitlab-Event", "Push Hook");
	Заголовки.Вставить("X-Gitlab-Token", СекретныйКлюч);

	Заголовки = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ТестовыеДанные, "Заголовки", Заголовки);
	JSON = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ТестовыеДанные, "JSON", JSON);
	
	Дополнительно = Новый Структура();
	Дополнительно.Вставить("Заголовки", Заголовки);
	Дополнительно.Вставить("Таймаут", 5);
	
	Результат = КоннекторHTTP.Post(URL, JSON, Дополнительно);
	
	Возврат Результат;
	
КонецФункции

#Область ВспомогательныеПроцедурыИФункции

Функция ОписаниеСервисаURL(Знач URL) Экспорт

	Возврат HTTPСервисы.ОписаниеСервисаURL(URL);

КонецФункции

Функция ОписаниеСервиса(Знач Сервис) Экспорт

	Возврат HTTPСервисы.ОписаниеСервиса(Сервис);

КонецФункции

Функция ОбрабатыватьЗапросыВнешнегоХранилища() Экспорт

	Возврат Константы.ОбрабатыватьЗапросыВнешнегоХранилища.Получить();

КонецФункции

Процедура УстановитьОбрабатыватьЗапросыВнешнегоХранилища(Знач Значение) Экспорт

	Константы.ОбрабатыватьЗапросыВнешнегоХранилища.Установить(Значение);

КонецПроцедуры

Функция КоннекторHTTPGet(Знач URL) Экспорт

	Возврат КоннекторHTTP.Get(URL);

КонецФункции

Функция КоннекторHTTPPost(Знач URL, Знач Данные, Знач ДополнительныеПараметры) Экспорт

	Возврат КоннекторHTTP.Post(URL, Данные, ДополнительныеПараметры);

КонецФункции

Функция ДобавитьОбработчикСобытий(Знач Наименование = "", Знач СекретныйКлюч = "") Экспорт
	
	НовыйЭлемент = Справочники.ОбработчикиСобытий.СоздатьЭлемент();
	НовыйЭлемент.Наименование = Наименование;
	НовыйЭлемент.СекретныйКлюч = СекретныйКлюч;
	НовыйЭлемент.Записать();
	
	Возврат НовыйЭлемент.Ссылка;
	
КонецФункции

Процедура УдалитьЭлементыСправочникаОбработчикиСобытий(Знач СекретныйКлюч) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =	"ВЫБРАТЬ
		|	ОбработчикиСобытий.Ссылка
		|ИЗ
		|	Справочник.ОбработчикиСобытий КАК ОбработчикиСобытий
		|ГДЕ
		|	ОбработчикиСобытий.СекретныйКлюч = &СекретныйКлюч";
	
	Запрос.УстановитьПараметр("СекретныйКлюч", СекретныйКлюч);
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();

	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ТекущийОбъект = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
		ТекущийОбъект.Удалить();		
	КонецЦикла;

КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции



#КонецОбласти