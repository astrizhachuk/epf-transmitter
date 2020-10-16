#Область ОбработчикиСобытийФормы

&AtClient
Процедура ПриОткрытии( Отказ )
	
	УстановитьОтборыСписков( Объект.Ссылка );
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыИмяТаблицыФормы

&AtClient
Procedure ReceivedRequestsSelection( Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Return;

EndProcedure

#КонецОбласти

#Область ОбработчикиКомандФормы

&AtClient
Procedure OpenQueryJSON( Command )
	
	OpenEditorJSON( Items.ReceivedRequests.CurrentRow, Command );

EndProcedure

&AtClient
Procedure OpenRoutingJSON( Command )
	
	OpenEditorJSON( Items.ReceivedRequests.CurrentRow, Command );

EndProcedure

Procedure DoAfterApplicationStart( ReturnCode, AdditionalParameters ) Export
	// No processing is required.
EndProcedure

&AtClient
Procedure OpenMergeRequestRemote( Command )
	
	Var CurrentRow;
	Var MergeRequestURL;
	Var Notify;
	
	CurrentRow = Items.ReceivedRequests.CurrentRow;
	
	If ( CurrentRow = Undefined ) Then
		
		Return;
		
	EndIf;

	MergeRequestURL = MergeRequestURL( CurrentRow );
	
	If ( NOT IsBlankstring(MergeRequestURL) ) Then
		
		#If WebClient Then
			
			GotoURL( MergeRequestURL );
			
		#Else
			
			Notify = New NotifyDescription( "DoAfterApplicationStart", ThisObject );
			BeginRunningApplication( Notify,  MergeRequestURL );
			
   		#EndIf
   				
	EndIf;
	
EndProcedure






&AtClient
Процедура РучнаяОтправкаДанных(Команда)
	
	Перем ТекущиеДанные;
	Перем ТекстВопроса;
	
	ТекущиеДанные = ЭтотОбъект.Элементы.ReceivedRequests.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТекстВопроса = СтрШаблон(НСтр("ru = 'Продолжить выполнение операции для %1?'"), ТекущиеДанные.Ключ);
	ПоказатьВопрос(Новый ОписаниеОповещения("РучнаяОтправкаДанныхЗавершение", ЭтотОбъект),
		ТекстВопроса, РежимДиалогаВопрос.ДаНет, 0);
		
КонецПроцедуры

&AtClient
Процедура ПоказатьФоновыеЗадания(Команда)
	
	Перем ТекущаяСтрока;
	Перем ПараметрыОткрытия;
	
	ТекущаяСтрока = ЭтотОбъект.Элементы.ReceivedRequests.ТекущаяСтрока;
	Если ТекущаяСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыОткрытия = Новый Структура;
	ПараметрыОткрытия.Вставить("КлючЗаписи", ТекущаяСтрока);

	ОткрытьФорму("Справочник.ОбработчикиСобытий.Форма.ФоновыеЗадания",
				 ПараметрыОткрытия,
				 ЭтаФорма,
				 ,
				 ,
				 ,
				 ,
				 РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
				 
КонецПроцедуры




&AtClient
Процедура ЗагрузитьИсториюСобытий(Команда)
	
	ОткрытьФорму("Справочник.ОбработчикиСобытий.Форма.УсловияОтбора",
				 ,
				 ЭтаФорма,
				 Новый УникальныйИдентификатор(),
				 ,
				 ,
				 Новый ОписаниеОповещения("ЗагрузитьИсториюСобытийЗавершение", ЭтаФорма),
				 РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&AtClient
Procedure SetFilter( Val Collection, Val Key, Val Value )
	
	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки( Collection,
															Key,
															DataCompositionComparisonType.Equal,
															Value );

EndProcedure

&AtClient
Procedure УстановитьОтборыСписков( Знач Ссылка )
	
	SetFilter( ПолученныеЗапросы.Отбор, "ОбработчикСобытия", Объект.Ссылка );
	SetFilter( ВнешниеФайлы.Отбор, "ОбработчикСобытия", Объект.Ссылка );
	SetFilter( ИсторияСобытий.Отбор, "Ссылка", Объект.Ссылка );
	
EndProcedure

&AtClient
Procedure OpenEditorJSON( Val CurrentRow, Val Command )
	
	Var OpenOptions;
	
	If ( CurrentRow = Undefined ) Then
		
		Return;
		
	EndIf;
	
	OpenOptions = New Structure();
	OpenOptions.Insert( "RecordKey", CurrentRow );
	OpenOptions.Insert( "CommandName", Command.Name );

	OpenForm( "Справочник.ОбработчикиСобытий.Форма.EditorJSON",
				OpenOptions,
				ThisObject,
				,
				,
				,
				,
				FormWindowOpeningMode.LockOwnerWindow );
	
EndProcedure

&AtServerNoContext
Function MergeRequestURL( Val RecordKey )
	
	Var QueryData;
	Var MergeRequests;
	Var MergeCommitSHA;
	Var Result;
	
	QueryData = ОбработчикиСобытий.ЗагрузитьДанныеЗапроса( RecordKey.ОбработчикСобытия, RecordKey.Ключ );
	MergeRequests = GitLab.GetMergeRequestsByQueryData( QueryData );

	Result = "";
	
	For Each MergeRequest In MergeRequests Do
		
		MergeCommitSHA = MergeRequest.Get( "merge_commit_sha" );
		
		If ( MergeCommitSHA = Undefined OR MergeCommitSHA <> RecordKey.Ключ ) Then
			
			Continue;
			
		EndIf;
		
		Result = MergeRequest.Get( "web_url" );
		
		If ( Result <> Undefined ) Then
			
			Return Result;

		EndIf;

	EndDo;
	
	Return Result;

EndFunction









&AtClient
Процедура ЗагрузитьИсториюСобытийЗавершение(РезультатЗакрытия, Параметры) Экспорт
	
	Перем ДобавленоЗаписей;
	Перем Таймаут;
	
	Таймаут = 5;
	
	ДобавленоЗаписей = 0;	
	ЗагрузитьИсториюСобытийЗавершениеНаСервере(РезультатЗакрытия, Параметры, ДобавленоЗаписей);
	ПоказатьПредупреждение( , НСтр("ru = 'Добавлено записей: '") + Строка(ДобавленоЗаписей),
			Таймаут, НСтр("ru = 'Загрузка истории из журнала регистрации'"));
							   	
КонецПроцедуры

&AtServer
Процедура ЗагрузитьИсториюСобытийЗавершениеНаСервере(РезультатЗакрытия, Параметры, ДобавленоЗаписей)
	
	Если РезультатЗакрытия = Неопределено Тогда
		Возврат;
	КонецЕсли;

	ПараметрыОтбора = Новый Структура;
	ПараметрыОтбора.Вставить("ДатаНачала", РезультатЗакрытия.ДатаНачала);
	ПараметрыОтбора.Вставить("ДатаОкончания", РезультатЗакрытия.ДатаОкончания);
	ПараметрыОтбора.Вставить("Метаданные", Метаданные.Справочники.ОбработчикиСобытий);
	ПараметрыОтбора.Вставить("Данные", Объект.Ссылка);
	
	ДобавленоЗаписей = 0;
	Логирование.ДекораторЗагрузитьИсториюСобытий(Метаданные.Справочники.ОбработчикиСобытий,
														"ИсторияСобытий",
														ПараметрыОтбора,
														ДобавленоЗаписей);
	
	ЭтаФорма.Элементы.ИсторияСобытий.Обновить();
		
КонецПроцедуры

&AtClient
Процедура РучнаяОтправкаДанныхЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
	Перем ТекущаяСтрока;
	
	Если РезультатВопроса = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	ТекущаяСтрока = ЭтотОбъект.Элементы.ReceivedRequests.ТекущаяСтрока;
	РучнаяОтправкаДанныхНаСервере(Объект.Ссылка, ТекущаяСтрока);

КонецПроцедуры

&AtServerNoContext
Процедура РучнаяОтправкаДанныхНаСервере(Знач Ссылка, Знач КлючЗапроса)
	Справочники.ОбработчикиСобытий.ЗапуститьОбработкуДанныхВручную(Ссылка, КлючЗапроса);
КонецПроцедуры


#КонецОбласти