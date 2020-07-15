#Область СлужебныйПрограммныйИнтерфейс

// @unit-test
Процедура Тест_ПередатьДвоичныеДанныеВИБПриемник(Фреймворк) Экспорт
	


КонецПроцедуры


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

//Процедура ПередачаДвоичныхДанныхВФоне(ИмяФайла, Адрес, ПараметрыДоставки) Экспорт
//	
//	Данные = ПолучитьИзВременногоХранилища(Адрес);
//
//	МассивФоновыхЗаданий = Новый Массив;
//	
//
//		
//	Для Индекс = 1 По 3 Цикл
//		
//		ПараметрыЗадания = Новый Массив;
//		ПараметрыЗадания.Добавить(ИмяФайла);
//		ПараметрыЗадания.Добавить(Данные);
//		ПараметрыЗадания.Добавить(ПараметрыДоставки);
//		
//		Если Индекс = 2 Тогда
//			
//			ПараметрыЗадания = Новый Массив;
//			ПараметрыЗадания.Добавить(ИмяФайла);
//			ПараметрыЗадания.Добавить(Данные);
//			ПараметрыЗадания.Добавить(Новый Структура);
//			
//		КонецЕсли;
//		
//		ЗаданиеОтправкаФайла = ФоновыеЗадания.Выполнить("ПередачаДанных.Отправить",
//											ПараметрыЗадания,
//											"Индекс" + Индекс,
//											"Тест.ПередачаДанных.Отправить." + Индекс);
//											
//		МассивФоновыхЗаданий.Добавить(ЗаданиеОтправкаФайла);
//		
//	КонецЦикла;
//		
//	ФоновыеЗадания10 = ФоновыеЗадания.ОжидатьЗавершенияВыполнения(МассивФоновыхЗаданий,10);
//	
//КонецПроцедуры

Процедура ОднократнаяПередачаДанных(ИмяФайла, Адрес, ПараметрыДоставки) Экспорт
	
	Данные = ПолучитьИзВременногоХранилища(Адрес);
	
	ПередачаДанных.Отправить(ИмяФайла, Данные, ПараметрыДоставки);
	
	СообщенияПриПередачеДанных = ПолучитьСообщенияПользователю();
	
	Если НЕ ЗначениеЗаполнено(СообщенияПриПередачеДанных) Тогда
		
		ВызватьИсключение "Передача файла должна сопровождаться формированием объекта СообщитьПользователю()"; 
		
	КонецЕсли;
	
	Если СтрНайти(СообщенияПриПередачеДанных[0].Текст, "Файлы успешно заменены.") = 0 Тогда
		
		ВызватьИсключение "Ошибка передачи данных, файлы не были заменены.";
		
	КонецЕсли;

КонецПроцедуры	

Функция КодироватьСтрокуURL(Знач Строка) Экспорт
	
	Возврат КодироватьСтроку(Строка, СпособКодированияСтроки.URLВКодировкеURL);

КонецФункции

#КонецОбласти
