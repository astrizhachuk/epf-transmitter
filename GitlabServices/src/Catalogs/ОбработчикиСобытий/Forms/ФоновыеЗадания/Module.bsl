#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	Перем КлючЗаписиФормы;
	Перем ЗаписьСуществует;
	
	КлючЗаписиФормы = Параметры.КлючЗаписи;
	
	ЗаписьСуществует = НЕ (КлючЗаписиФормы = Неопределено
//		ИЛИ ТипЗнч(КлючЗаписиФормы) <> Тип("РегистрСведенийКлючЗаписи.ДанныеОбработчиковСобытий")
		ИЛИ КлючЗаписиФормы.Пустой());
	
	Если НЕ ЗаписьСуществует Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	СформироватьТаблицуФоновыхЗаданий(КлючЗаписиФормы.Ключ);

	ЭтаФорма.КлючЗаписи = КлючЗаписиФормы.Ключ;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыИмяТаблицыФормы

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОбновитьТаблицуФоновыхЗаданий(Команда)
	Если ЭтаФорма.КлючЗаписи = Неопределено Тогда
		Возврат;
	КонецЕсли;
	СформироватьТаблицуФоновыхЗаданий(ЭтаФорма.КлючЗаписи);
КонецПроцедуры

&НаКлиенте
Процедура АктуализироватьСостояниеЗадания(Команда)
	
	Перем ТекущиеДанные;
	Перем ТекущееФоновоеЗадание;
	
	ТекущиеДанные = ЭтотОбъект.Элементы.Список.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено ИЛИ НЕ ЗначениеЗаполнено(ТекущиеДанные.УникальныйИдентификатор) Тогда
		Возврат;
	КонецЕсли;
	
	ТекущееФоновоеЗадание = ТекущееСостояниеФоновогоЗадания(ТекущиеДанные);
	АктуализироватьСостояниеЗаданияНаСервере(ТекущееФоновоеЗадание);
	ЗаполнитьЗначенияСвойств(ТекущиеДанные, ТекущееФоновоеЗадание);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗавершитьЗадание(Команда)
	
	Перем ТекущиеДанные;
	Перем ТекущееФоновоеЗадание;

	ТекущиеДанные = ЭтотОбъект.Элементы.Список.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено ИЛИ НЕ ЗначениеЗаполнено(ТекущиеДанные.УникальныйИдентификатор) Тогда
		Возврат;
	КонецЕсли;
	
	ТекущееФоновоеЗадание = ТекущееСостояниеФоновогоЗадания(ТекущиеДанные);
	ЗавершитьЗаданиеНаСервере(ТекущееФоновоеЗадание);
	ЗаполнитьЗначенияСвойств(ТекущиеДанные, ТекущееФоновоеЗадание);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция ТекущееСостояниеФоновогоЗадания(Знач ТекущиеДанные)
	
	Перем ТекущееФоновоеЗадание;
	
	ТекущееФоновоеЗадание = Новый Структура;
	
	ТекущееФоновоеЗадание.Вставить("УникальныйИдентификатор", ТекущиеДанные.УникальныйИдентификатор);
	ТекущееФоновоеЗадание.Вставить("Состояние", ТекущиеДанные.Состояние);
	ТекущееФоновоеЗадание.Вставить("Конец", ТекущиеДанные.Конец);
	ТекущееФоновоеЗадание.Вставить("ИнформацияОбОшибке", ТекущиеДанные.ИнформацияОбОшибке);
	
	Возврат ТекущееФоновоеЗадание;

КонецФункции


&НаСервере
Процедура ЗавершитьЗаданиеНаСервере(Результат)
	
	Перем ТекущееФоновоеЗадание;
	Перем ИдентификаторФоновогоЗадания;
	
	ИдентификаторФоновогоЗадания = Новый УникальныйИдентификатор(Результат.УникальныйИдентификатор);
	ТекущееФоновоеЗадание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторФоновогоЗадания);
	
	Если ТекущееФоновоеЗадание <> Неопределено Тогда
		Если ТекущееФоновоеЗадание.Состояние = СостояниеФоновогоЗадания.Активно Тогда
			ТекущееФоновоеЗадание.Отменить();
			ТекущееФоновоеЗадание.ОжидатьЗавершения();
		КонецЕсли;
		АктуализироватьСостояниеЗаданияНаСервере(Результат);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура АктуализироватьСостояниеЗаданияНаСервере(Результат)
	
	Перем ТекущееФоновоеЗадание;
	Перем ИдентификаторФоновогоЗадания;
	
	ИдентификаторФоновогоЗадания = Новый УникальныйИдентификатор(Результат.УникальныйИдентификатор);
	ТекущееФоновоеЗадание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторФоновогоЗадания);
	
	Если ТекущееФоновоеЗадание <> Неопределено Тогда
		Результат.Состояние = Строка(ТекущееФоновоеЗадание.Состояние);
		Результат.Конец = ТекущееФоновоеЗадание.Конец;
		Если ТекущееФоновоеЗадание.ИнформацияОбОшибке <> Неопределено Тогда
			Результат.ИнформацияОбОшибке = ПодробноеПредставлениеОшибки(ТекущееФоновоеЗадание.ИнформацияОбОшибке);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СформироватьТаблицуФоновыхЗаданий(Знач Ключ)
	
	Перем ВсеФоновыеЗадания;

	ВсеФоновыеЗадания = ОписаниеТаблицыФоновыхИзРеквизитаФормы("Список");
	ЗаполнитьТаблицуФоновыхЗаданийСервисовGitLab(Ключ, ВсеФоновыеЗадания);
	ВсеФоновыеЗадания.Сортировать("Начало УБЫВ, Состояние");
	
	ЗначениеВРеквизитФормы(ВсеФоновыеЗадания, "Список");
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицуФоновыхЗаданийСервисовGitLab(Знач Ключ, ТаблицаЗначений)
	
	Перем МассивФоновыхЗаданий;
	
	МассивФоновыхЗаданий = ЗадачиПоНаименованию("СервисыGitLab: " + Ключ);
	Для каждого ФоновоеЗадание Из МассивФоновыхЗаданий Цикл
		НоваяСтрока = ТаблицаЗначений.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, ФоновоеЗадание);
		Если ФоновоеЗадание.ИнформацияОбОшибке <> Неопределено Тогда
			НоваяСтрока.ИнформацияОбОшибке = ПодробноеПредставлениеОшибки(ФоновоеЗадание.ИнформацияОбОшибке);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Поиск всех фоновых заданий по наименованию.
// 
// Параметры:
// 	Наименование - Строка - наименование фонового задания;
// Возвращаемое значение:
// 	- Массив из ФоновоеЗадание - найденные фоновые задания;
&НаСервере
Функция ЗадачиПоНаименованию(Знач Наименование)
	
	Перем ПараметрыОтбора;
	Перем ВсеФоновыеЗадания;
	
	ПараметрыОтбора = Новый Структура("Наименование", Наименование);
	ВсеФоновыеЗадания = ФоновыеЗадания.ПолучитьФоновыеЗадания(ПараметрыОтбора);
	
	Возврат ВсеФоновыеЗадания;
	
КонецФункции

&НаСервере
Функция ОписаниеТаблицыФоновыхИзРеквизитаФормы(РеквизитФормы)
	
	Перем Результат;
	Перем ОписаниеРеквизитаФормы;
	Перем КолонкиРеквизитаФормы;
	
	Результат = Новый ТаблицаЗначений;
	ОписаниеРеквизитаФормы = РеквизитФормыВЗначение(РеквизитФормы);
	КолонкиРеквизитаФормы = ОписаниеРеквизитаФормы.Колонки;
	Для каждого Колонка Из КолонкиРеквизитаФормы Цикл
		Результат.Колонки.Добавить(Колонка.Имя, Колонка.ТипЗначения);
	КонецЦикла;	

	Возврат Результат;

КонецФункции


#КонецОбласти


