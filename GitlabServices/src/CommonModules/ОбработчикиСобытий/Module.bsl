#Область ПрограммныйИнтерфейс

// Поиск обработчика событий по секретному ключу (token).
// 
// Параметры:
// 	Token - Строка - секретный ключ (token);
// 	
// Возвращаемое значение:
// 	СправочникСсылка.ОбработчикиСобытий - найденный элемент справочника "ОбработчикиСобытий" или пустая ссылка;
//
Функция НайтиПоСекретномуКлючу( Знач Token ) Экспорт
	
	Перем ОбработчикиСобытийПоКлючу;
	
	ОбработчикиСобытийПоКлючу = Справочники.ОбработчикиСобытий.НайтиПоСекретномуКлючу( Token );
	
	// Справочник содержит уникальные записи в разрезе секретного ключа.
	Возврат ?( ЗначениеЗаполнено(ОбработчикиСобытийПоКлючу),
				ОбработчикиСобытийПоКлючу[0],
				Справочники.ОбработчикиСобытий.ПустаяСсылка() );
	
КонецФункции

// Загружает в табличную часть объекта данные из журнала регистрации по фильтру.
// 
// Параметры:
// 	Object - СправочникОбъект.ОбработчикиСобытий - объект обработчика событий; 
// 	Destination - Строка - имя табличной части;
// 	Filter - Структура - фильтр отбора для журнала регистрации (См. ГлобальныйКонтекст.ВыгрузитьЖурналРегистрации);
// 	RecordsLoaded - Число - (возвращаемый параметр) количество загруженных записей;
//
Процедура ЗагрузитьИсториюСобытий( Object, Val Destination, Val Filter, RecordsLoaded ) Экспорт
	
	If ( NOT Filter.Property( "Data" ) ) Then
		
		Filter.Insert( "Data", Object.Ref );
		
	EndIf;
	
	Справочники.ОбработчикиСобытий.ЗагрузитьИсториюСобытий( Object, Destination, Filter, RecordsLoaded );
	
КонецПроцедуры

// Сохраняет десериализованные данные обрабатываемого запроса.
// 
// Параметры:
// 	ОбработчикСобытия - СправочникСсылка.ОбработчикиСобытий - ссылка на элемент справочника с обработчиками событий;
//  CommitSHA - Строка - сommit SHA, используемый как уникальный идентификатор запроса;
// 	ДанныеЗапроса - Соответствие - десериализованное из JSON тело запроса;
//
Процедура СохранитьДанныеЗапроса( Знач ОбработчикСобытия, Знач CommitSHA, Знач ДанныеЗапроса ) Экспорт
	
	СохранитьДанные( "ДанныеЗапросов", ОбработчикСобытия, CommitSHA, ДанныеЗапроса );
		
КонецПроцедуры

// Сохраняет внешние файлы с их описанием, полученные с сервера GitLab.
// 
// Параметры:
// 	ОбработчикСобытия - СправочникСсылка.ОбработчикиСобытий - ссылка на элемент справочника с обработчиками событий;
//  CommitSHA - Строка - сommit SHA, используемый как уникальный идентификатор запроса;
// 	ОписаниеФайлов - ТаблицаЗначений - описание:
// * ПутьКФайлуRAW - Строка -  относительный путь к RAW файлу;
// * ИмяФайла - Строка - имя файла;
// * ПолноеИмяФайла - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
// * ДвоичныеДанные - ДвоичныеДанные - содержимое файла;
// * Операция - Строка - вид операции над файлом: "added", "modified", "removed";
// * Дата - Дата - дата операции над файлом;
// * CommitSHA - Строка - сommit SHA;
// * ОписаниеОшибки - Строка - описание ошибки при работе с файлами;
//
Процедура СохранитьВнешниеФайлы( Знач ОбработчикСобытия, Знач CommitSHA, Знач ОписаниеФайлов ) Экспорт
	
	СохранитьДанные( "ВнешниеФайлы", ОбработчикСобытия, CommitSHA, ОписаниеФайлов );
		
КонецПроцедуры

// Возвращает ранее сохраненные данные запросов.
// 
// Параметры:
// 	ОбработчикСобытия - СправочникСсылка.ОбработчикиСобытий - ссылка на элемент справочника с обработчиками событий;
//  CheckoutSHA - Строка - сommit SHA, используемый как уникальный идентификатор запроса;
// Возвращаемое значение:
// 	Соответствие - десериализованное из JSON тело запроса;
//
Функция ЗагрузитьДанныеЗапроса( Знач ОбработчикСобытия, Знач CheckoutSHA ) Экспорт
	
	КлючЗаписи = Новый Структура();
	КлючЗаписи.Вставить( "ОбработчикСобытия", ОбработчикСобытия );
	КлючЗаписи.Вставить( "Ключ", CheckoutSHA );
	
	Возврат ЗагрузитьДанные( "ДанныеЗапросов", КлючЗаписи );
	
КонецФункции

// Возвращает ранее сохраненные внешние файлы с их описанием.
// 
// Параметры:
// 	ОбработчикСобытия - СправочникСсылка.ОбработчикиСобытий - ссылка на элемент справочника с обработчиками событий;
//  CheckoutSHA - Строка - сommit SHA, используемый как уникальный идентификатор запроса;
// Возвращаемое значение:
// 	ТаблицаЗначений - описание:
// * ПутьКФайлуRAW - Строка -  относительный путь к RAW файлу;
// * ИмяФайла - Строка - имя файла;
// * ПолноеИмяФайла - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
// * ДвоичныеДанные - ДвоичныеДанные - содержимое файла;
// * Операция - Строка - вид операции над файлом: "added", "modified", "removed";
// * Дата - Дата - дата операции над файлом;
// * CommitSHA - Строка - сommit SHA;
// * ОписаниеОшибки - Строка - описание ошибки при работе с файлами;
//
Функция ЗагрузитьВнешниеФайлы( Знач ОбработчикСобытия, Знач CheckoutSHA ) Экспорт
	
	КлючЗаписи = Новый Структура();
	КлючЗаписи.Вставить( "ОбработчикСобытия", ОбработчикСобытия );
	КлючЗаписи.Вставить( "Ключ", CheckoutSHA );
	
	Возврат ЗагрузитьДанные( "ВнешниеФайлы", КлючЗаписи );
	
КонецФункции

#EndRegion

#Region Private

Процедура СохранитьДанные( Знач РегистрСведений, Знач ОбработчикСобытия, Знач Ключ, Знач Данные )
	
	Перем ХранилищеЗначения;
	Перем НаборЗаписей;
	Перем ВыбраннаяЗапись;

	ХранилищеЗначения = Новый ХранилищеЗначения( Данные );

	НаборЗаписей = РегистрыСведений[ РегистрСведений ].СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.ОбработчикСобытия.Установить( ОбработчикСобытия );
	НаборЗаписей.Отбор.Ключ.Установить( Ключ );
	НаборЗаписей.Прочитать();

	ВыбраннаяЗапись = ?( НаборЗаписей.Количество() = 0, НаборЗаписей.Добавить(), НаборЗаписей[0] );		
	
	ВыбраннаяЗапись.ОбработчикСобытия = ОбработчикСобытия;
	ВыбраннаяЗапись.Ключ = Ключ;
	ВыбраннаяЗапись.Данные = ХранилищеЗначения;
	
	НаборЗаписей.Записать();

КонецПроцедуры

Функция ЗагрузитьДанные( Знач РегистрСведений, Знач КлючЗаписи )
	
	Перем Результат;
	Перем МенеджерЗаписи;
	
	Если ( РегистрСведений = "ВнешниеФайлы" ) Тогда
		
		Результат = Gitlab.ОписаниеФайлов();
	
	Иначе
		
		Результат = Новый Соответствие();
		
	КонецЕсли;

	МенеджерЗаписи = РегистрыСведений[ РегистрСведений ].СоздатьМенеджерЗаписи();
	ЗаполнитьЗначенияСвойств( МенеджерЗаписи, КлючЗаписи );
	
	МенеджерЗаписи.Прочитать();

	Если МенеджерЗаписи.Выбран() Тогда
		
		Результат = МенеджерЗаписи[ "Данные" ].Получить();
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

#EndRegion
