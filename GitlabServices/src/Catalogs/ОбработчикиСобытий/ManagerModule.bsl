#Область ПрограммныйИнтерфейс

// Поиск элементов справочника по секретному ключу (token), не помеченные на удаление.
//
// Параметры:
// 	Token - Строка - секретный ключ (token);
//
// Возвращаемое значение:
// 	Массив из СправочникСсылка.ОбработчикиСобытий - найденные элементы справочника (пустой массив, если не найдено); 
//
Функция НайтиПоСекретномуКлючу( Знач Token ) Экспорт
	
	Перем Запрос;
	Перем Результат;
	
	Результат = Новый Массив();
	
	Если ( ТипЗнч(Token) <> Тип("Строка") ИЛИ ПустаяСтрока(Token) ) Тогда
		
		Возврат Результат;
		
	КонецЕсли;
	
	Запрос = Новый Запрос();
	Запрос.УстановитьПараметр( "СекретныйКлюч", Token );
	Запрос.Текст = 	"ВЫБРАТЬ
	               	|	ОбработчикиСобытий.Ссылка КАК Ссылка
	               	|ИЗ
	               	|	Справочник.ОбработчикиСобытий КАК ОбработчикиСобытий
	               	|ГДЕ
	               	|	НЕ ОбработчикиСобытий.ПометкаУдаления
	               	|	И ОбработчикиСобытий.СекретныйКлюч = &СекретныйКлюч";
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку( "Ссылка" );
	
КонецФункции

Процедура ЗагрузитьИсториюСобытий( Object, Val Destination, Val Filter, RecordsLoaded ) Экспорт

	Если ТипЗнч(Object) <> Тип("СправочникОбъект.ОбработчикиСобытий") Тогда
		
		Возврат;
		
	КонецЕсли;	

	Object[Destination].Очистить();

	ДанныеЖурналаРегистрации = Новый ТаблицаЗначений;
	
	ВыгрузитьЖурналРегистрации( ДанныеЖурналаРегистрации, Filter );
	
	Для каждого ЗаписьЖурналаРегистрации Из ДанныеЖурналаРегистрации Цикл
		
		Событие = Логирование.ПреобразоватьСтрокуСобытияВСтруктуру(ЗаписьЖурналаРегистрации.Событие);

		Если Событие.Объект <> "ОбработчикиСобытий" Тогда
			Продолжить;
		КонецЕсли;

		НоваяЗаписьИстории = Object[Destination].Добавить();
		ЗаполнитьЗначенияСвойств(НоваяЗаписьИстории, ЗаписьЖурналаРегистрации);
		ЗаполнитьЗначенияСвойств(НоваяЗаписьИстории, Событие);
 
		НоваяЗаписьИстории.Уровень = Строка(ЗаписьЖурналаРегистрации.Уровень);
		
		RecordsLoaded = RecordsLoaded + 1;

	КонецЦикла;
	
	Object.Записать();

КонецПроцедуры

#EndRegion

#Область ОбработчикиПроведения

#EndRegion

#Область ОбработчикиСобытий

#EndRegion

#Region Private

#EndRegion