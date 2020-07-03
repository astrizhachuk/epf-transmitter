#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Перем Настройки;
	
	Настройки = НастройкиСервисов.НастройкиСервисовGitLab();
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, Настройки);

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы
#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Записать(Команда)
	
	ЗаписатьДанныеФормы();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	
	Перем Успех;

	Успех = ЗаписатьДанныеФормы();
	Если Успех Тогда
		Закрыть();
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПроверитьПодключение(Команда)
	ОткрытьФорму("ОбщаяФорма.ПроверкаПодключенияКСервисам", , , , , , , РежимОткрытияОкнаФормы.Независимый);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция ЗаписатьДанныеФормы()
	
	Перем Успех;

	Успех = Ложь;
	
	Если ПроверитьЗаполнение() Тогда
		СохранитьНаСервере();
		ОбновитьИнтерфейс();
		Успех = Истина;		
	КонецЕсли;
	
	Возврат Успех;
	
КонецФункции

&НаСервере
Процедура СохранитьНаСервере()
	
	УстановитьПривилегированныйРежим(Истина);
	Константы.ЗагружатьФайлыИзВнешнегоХранилища.Установить(ЗагружатьФайлыИзВнешнегоХранилища);
	Константы.GitLabUserPrivateToken.Установить(GitLabUserPrivateToken);
	Константы.ИмяФайлаНастроекМаршрутизацииGitLab.Установить(ИмяФайлаНастроекМаршрутизации);
	Константы.AccessTokenReceiver.Установить(AccessTokenReceiver);
	Константы.ТаймаутGitLab.Установить(ТаймаутGitLab);
	Константы.ТаймаутДоставкиПолучатель.Установить(ТаймаутДоставкиПолучатель);
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры

#КонецОбласти
