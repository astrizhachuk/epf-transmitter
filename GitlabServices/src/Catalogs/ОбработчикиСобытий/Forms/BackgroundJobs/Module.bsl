#Region FormEventHandlers

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	If ( Parameters.RecordKey.IsEmpty() ) Then
		
		Return;
		
	EndIf;

	ЗаполнитьСписокФоновыхЗаданий( Parameters.RecordKey );
	
КонецПроцедуры

#EndRegion

#Region FormCommandsEventHandlers

&НаКлиенте
Процедура RefreshBackgroundJobs(Команда)
	
	ЗаполнитьСписокФоновыхЗаданий( Parameters.RecordKey );
	
КонецПроцедуры

&НаКлиенте
Процедура RefreshSelectedBackgroundJob(Команда)
	
	Перем ТекущиеДанные;
	//Перем ТекущееФоновоеЗадание;
	
	ТекущиеДанные = Items.BackgroundJobs.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТекущееФоновоеЗадание = ТекущиеДанные.UUID;
	АктуализироватьСостояниеЗаданияНаСервере(ТекущиеДанные.ПолучитьИдентификатор(), ТекущиеДанные.UUID);
	//ЗаполнитьЗначенияСвойств(ТекущиеДанные, ТекущееФоновоеЗадание);
	
КонецПроцедуры

&НаКлиенте
Процедура KillSelectedBackgroundJob(Команда)
	
	Перем ТекущиеДанные;
	Перем ТекущееФоновоеЗадание;

	ТекущиеДанные = Items.BackgroundJobs.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТекущееФоновоеЗадание = ТекущиеДанные.UUID;
	ЗавершитьЗаданиеНаСервере(ТекущиеДанные.ПолучитьИдентификатор(), ТекущиеДанные.UUID);
	//ЗаполнитьЗначенияСвойств(ТекущиеДанные, ТекущееФоновоеЗадание);
	
КонецПроцедуры

#EndRegion

#Region Private



&НаСервере
Процедура ЗавершитьЗаданиеНаСервере(ИдентификаторСтроки, UUID)
	
	Перем ТекущееФоновоеЗадание;
	Перем ИдентификаторФоновогоЗадания;
	
	ИдентификаторФоновогоЗадания = Новый УникальныйИдентификатор(UUID);
	Если НЕ ПривилегированныйРежим() Тогда
		УстановитьПривилегированныйРежим(Истина);
	КонецЕсли;
	ТекущееФоновоеЗадание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторФоновогоЗадания);

	
	Если ТекущееФоновоеЗадание <> Неопределено Тогда
		Если ТекущееФоновоеЗадание.State = СостояниеФоновогоЗадания.Активно Тогда

			ТекущееФоновоеЗадание.Отменить();
			ТекущееФоновоеЗадание.ОжидатьЗавершенияВыполнения();

		КонецЕсли;
		//АктуализироватьСостояниеЗаданияНаСервере(Результат);
		АктуализироватьСостояниеЗаданияНаСервере(ИдентификаторСтроки, UUID)
	КонецЕсли;
	
	
КонецПроцедуры

&НаСервере
Процедура АктуализироватьСостояниеЗаданияНаСервере(ИдентификаторСтроки, UUID)
	
	Перем ТекущееФоновоеЗадание;
	Перем ИдентификаторФоновогоЗадания;
	

	
	ИдентификаторФоновогоЗадания = Новый УникальныйИдентификатор(UUID);
	
	Если НЕ ПривилегированныйРежим() Тогда
		УстановитьПривилегированныйРежим(Истина);
	КонецЕсли;
	ТекущееФоновоеЗадание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторФоновогоЗадания);

	
	Если ТекущееФоновоеЗадание <> Неопределено Тогда
		СтрокаКоллекции = BackgroundJobs.НайтиПоИдентификатору(ИдентификаторСтроки);
		ЗаполнитьЗначенияСвойств(СтрокаКоллекции, ТекущееФоновоеЗадание);
		
Если ТекущееФоновоеЗадание.ErrorInfo <> Неопределено Тогда
			СтрокаКоллекции.ErrorInfo = ПодробноеПредставлениеОшибки(ТекущееФоновоеЗадание.ИнформацияОбОшибке);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&AtServer
Function ФоновыеЗаданияПоКлючу( Знач Key )
	
	Перем ПараметрыОтбора;
	
	Если НЕ ПривилегированныйРежим() Тогда
		УстановитьПривилегированныйРежим(Истина);
	КонецЕсли;
		
	ПараметрыОтбора = Новый Структура( "MethodName, Key", "ОбработкаДанных.ОбработатьДанные", Key );
	МассивФоновыхЗаданий = ФоновыеЗадания.ПолучитьФоновыеЗадания( ПараметрыОтбора );
	
	ПараметрыОтбора = Новый Структура("MethodName, Наименование", "Получатели.ОтправитьФайл", Key);
	ФоновыеЗаданияОтправляемыеФайлы = ФоновыеЗадания.ПолучитьФоновыеЗадания( ПараметрыОтбора );
	
	Результат = МассивФоновыхЗаданий;

	Для Каждого Значение Из ФоновыеЗаданияОтправляемыеФайлы Цикл
		
		Результат.Добавить(Значение);
		
	КонецЦикла;
	
	Возврат Результат;
	
EndFunction

&AtServer
Procedure ЗаполнитьСписокФоновыхЗаданий( Знач RecordKey )
	
	СписокФоновыхЗаданий = ЭтотОбъект.РеквизитФормыВЗначение( "BackgroundJobs" );
	СписокФоновыхЗаданий.Очистить();

	МассивФоновыхЗаданий = ФоновыеЗаданияПоКлючу( RecordKey.Ключ );

	Для каждого ФоновоеЗадание Из МассивФоновыхЗаданий Цикл
		НоваяСтрока = СписокФоновыхЗаданий.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, ФоновоеЗадание);
		Если ФоновоеЗадание.ErrorInfo <> Неопределено Тогда
			НоваяСтрока.ErrorInfo = ПодробноеПредставлениеОшибки(ФоновоеЗадание.ИнформацияОбОшибке);
		КонецЕсли;
	КонецЦикла;
	
	СписокФоновыхЗаданий.Сортировать("Begin УБЫВ, State");
	
	ЗначениеВРеквизитФормы(СписокФоновыхЗаданий, "BackgroundJobs");	

EndProcedure

#EndRegion
