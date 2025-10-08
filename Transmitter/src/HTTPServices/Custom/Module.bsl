// @strict-types

#Область ОбработчикиСобытий

#Region Methods

Функция StatusGet( Запрос )
	
	Возврат НастройкиСервисов.ПолучитьСтатусКакОтветСервиса( Метаданные.HTTPСервисы.Custom );
	
КонецФункции

Function SendPost( Request )
	
	Ответ = Новый HTTPСервисОтвет( СервисыHTTP.КодыСостояния().НайтиКодПоИдентификатору("OK") );

	Логи.Информация( Логи.События().ВебСервис, Логи.Сообщения().ЗапросПолучен,
		Логи.КонтекстОтветаСервиса(Ответ, Метаданные.HTTPСервисы.Custom) );
	
	CheckGlobalSettings( Ответ );
	
	CheckHeaders( Request, Ответ );
	
	If ( NOT СервисыHTTP.КодыСостояния().isOk(Ответ.StatusCode) ) Then
		
		Return Ответ;
		
	EndIf;
	
	MultipartMessage = СервисыHTTP.GetMultipartMessageByType( Request );
	
	If ( MultipartMessage = Undefined ) Then
		
		Message = NStr( "ru = 'запрос не в формате multipart/form-data';
						|en = 'request not in multipart/form-data format'" );

		//Return СервисыHTTP.НоваяОшибкаНеправильныйЗапрос( Message );
		Return СервисыHTTP.СоздатьОтвет( СервисыHTTP.КодыСостояния().НайтиКодПоИдентификатору("BAD_REQUEST"), Message );
		
	EndIf;
	
	Return New HTTPServiceResponse( 200 );
	
EndFunction

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Procedure CheckGlobalSettings( Response )
	
	If ( NOT СервисыHTTP.КодыСостояния().isOk(Response.StatusCode) ) Then
		
		Return;
		
	EndIf;

	If ( NOT НастройкиСервисов.ОбработкаЗапросаВключена(Метаданные.HTTPСервисы.Custom) ) Then
		
		Response = СервисыHTTP.СоздатьОтвет(СервисыHTTP.КодыСостояния().НайтиКодПоИдентификатору("LOCKED"), "???" );
		Логи.Ошибка( Логи.События().ВебСервис, Логи.Сообщения().ОбработкаЗапросовОтключена, Логи.КонтекстОтветаСервиса(Response, Метаданные.HTTPСервисы.Custom) );

	EndIf;

EndProcedure

Procedure CheckHeaders( Val Request, Response )
	
	Var Token;
	
	If ( NOT СервисыHTTP.КодыСостояния().isOk(Response.StatusCode) ) Then
		
		Return;
		
	EndIf;
	
	Token = СервисыHTTP.НайтиЗаголовок( Request, "X-Custom-Token" );
	
	If ( NOT ValueIsFilled(Token) ) Then
		
//		Response = New HTTPServiceResponse( СервисыHTTP.КодыСостояния().FindCodeById("BAD_REQUEST") );
		Response = СервисыHTTP.СоздатьОтвет(СервисыHTTP.КодыСостояния().НайтиКодПоИдентификатору("BAD_REQUEST"), Логи.Сообщения().NO_TOKEN );
		Логи.Ошибка( Логи.События().ВебСервис, Логи.Сообщения().NO_TOKEN, Логи.КонтекстОтветаСервиса(Response, Метаданные.HTTPСервисы.Custom) );
		
		Return;
		
	EndIf;	
	
EndProcedure

#КонецОбласти