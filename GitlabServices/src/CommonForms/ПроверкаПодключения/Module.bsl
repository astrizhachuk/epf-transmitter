#Region FormHeaderItemsEventHandlers

&НаКлиенте
Процедура Проверить(Команда)
	
	Перем СервисGitLab;
	
	ЭтотОбъект.ТекстОтвета = "";
	
 	Если ( ПроверитьЗаполнение() ) Тогда
 		
		СервисGitLab = СервисGitLab();
		
		Попытка
			
			ПроверитьПодключениеКСервису( ЭтотОбъект.Адрес, СервисGitLab );
			ЭтотОбъект.ТекстОтвета = СервисGitLab.ТекстОтвета;

		Исключение
			
			СервисGitLab = Неопределено;

		КонецПопытки;
		
		ЭтотОбъект.РезультатПроверки = ФорматированныйРезультатПроверки( СервисGitLab );	
 		
 	КонецЕсли;
	
КонецПроцедуры

#EndRegion

#Region Private

&НаКлиенте
Функция СервисGitLab()
	
	Перем Результат;
	
	Результат = Новый Структура();
	Результат.Вставить( "Доступен", Ложь );
	Результат.Вставить( "Включен", Ложь );
	Результат.Вставить( "ТекстОтвета", "" );
	
	Возврат Результат;
	
КонецФункции

&НаСервереБезКонтекста
Процедура ПроверитьПодключениеКСервису( Знач Адрес, Результат )
	
	Перем ОписаниеСервиса;
	Перем СервисGitLab;
	Перем СервисВключен;

	ОписаниеСервиса = HTTPСервисы.ОписаниеСервисаURL( Адрес );
	
	Если ( ОписаниеСервиса = Неопределено ) Тогда
		
		Возврат;
		
	КонецЕсли;
	
	СервисGitLab = ОписаниеСервиса.Данные.Получить( "services" );
	
	Если ( СервисGitLab = Неопределено ) Тогда
		
		Возврат;
				
	КонецЕсли;
	
	Результат.Доступен = Истина;
	СервисВключен = СервисGitLab.Получить( "enabled" );
	Результат.Включен = ?( СервисВключен = Неопределено, Ложь, СервисВключен );
	Результат.ТекстОтвета = ОписаниеСервиса.json;

КонецПроцедуры

&НаКлиенте
Функция ФорматированныйРезультатПроверки( Знач РезультатПроверкиСервиса )
	
	Перем Сообщения;
	
	Сообщения = Новый Массив();
	
	Если ( РезультатПроверкиСервиса = Неопределено ) Тогда
		
		Сообщения.Добавить( Новый ФорматированнаяСтрока("Ошибка подключения.", , WebЦвета.Красный) );
		
	ИначеЕсли ( РезультатПроверкиСервиса.Доступен ) Тогда
		
		Сообщения.Добавить( Новый ФорматированнаяСтрока("Сервис доступен.", , WebЦвета.Зеленый) );
		
		Если ( РезультатПроверкиСервиса.Включен ) Тогда
			
			Сообщения.Добавить( Новый ФорматированнаяСтрока(" Статус работы: включен.", , WebЦвета.Зеленый) );
			
		Иначе
			
			Сообщения.Добавить( Новый ФорматированнаяСтрока(" Статус работы: выключен.", , WebЦвета.Красный) );
			
		КонецЕсли;
		
	Иначе
		
		Сообщения.Добавить( Новый ФорматированнаяСтрока("Сервис недоступен.", , WebЦвета.Красный) );
		
	КонецЕсли; 
	
	Возврат Новый ФорматированнаяСтрока( Сообщения );
	
КонецФункции

#EndRegion
