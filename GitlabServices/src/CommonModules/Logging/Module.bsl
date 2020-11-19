#Region Public

// Логирует информационное Event. Если в дополнительных данных передать HTTPResponse или HTTPСервисОтвет, то в Event
// логируемого сообдения будет добавлен код события, а в случае HTTPСервисОтвет данный объект будет дозаполнен данными
// логируемого сообщения (для кода 200).  
// 
// Параметры:
// 	Event - Строка - логируемое Event в формате "ГруппаСобытий.Event.Дополнительно";
// 	Message - Строка - текст сообщения;
// 	ДополнительныеДанные - Структура - описание:
//   * Объект - ЛюбаяСсылка - ссылка на объект, метаданные которого необходимо добавить в журнал регистрации;
//   * HTTPResponse - HTTPResponse, HTTPСервисОтвет - HTTP-ответ сервера или веб-сервиса;
//
Procedure Info( Val Event, Val Message, Object = Undefined, HTTPResponse = Undefined ) Export
	
	Var LoggingOptions;
	
	LoggingOptions = LoggingOptions( Object, HTTPResponse );
	AddResponseBody( LoggingOptions, EventLogLevel.Information, Message);
	Write( Event, EventLogLevel.Information, Message, LoggingOptions);

EndProcedure

// Логирует Warn. Если в дополнительных данных передать HTTPResponse или HTTPСервисОтвет, то в событие
// логируемого сообдения будет добавлен код события, а в случае HTTPСервисОтвет данный объект будет дозаполнен данными
// логируемого сообщения (для кода 200).
// 
// Параметры:
// 	Событие - Строка - логируемое событие в формате "ГруппаСобытий.Событие.Дополнительно";
// 	Сообщение - Строка - текст сообщения;
// 	ДополнительныеДанные - Структура - описание:
//   * Объект - ЛюбаяСсылка - ссылка на объект, метаданные которого необходимо добавить в журнал регистрации;
//   * HTTPResponse - HTTPResponse, HTTPСервисОтвет - HTTP-ответ сервера или веб-сервиса;
//
Procedure Warn( Val Event, Val Message, Object = Undefined, HTTPResponse = Undefined ) Export

	Var LoggingOptions;

	LoggingOptions = LoggingOptions( Object, HTTPResponse );
	AddResponseBody( LoggingOptions, EventLogLevel.Warning, Message );
	Write( Event, EventLogLevel.Warning, Message, LoggingOptions );

EndProcedure

// Логирует ошибку. Если в дополнительных данных передать HTTPResponse или HTTPСервисОтвет, то в событие
// логируемого сообдения будет добавлен код события, а в случае HTTPСервисОтвет данный объект будет дозаполнен данными
// логируемого сообщения (для кода 200).
// 
// Параметры:
// 	Событие - Строка - логируемое событие в формате "ГруппаСобытий.Событие.Дополнительно";
// 	Сообщение - Строка - текст сообщения;
// 	ДополнительныеДанные - Структура - описание:
//   * Объект - ЛюбаяСсылка - ссылка на объект, метаданные которого необходимо добавить в журнал регистрации;
//   * HTTPResponse - HTTPResponse, HTTPСервисОтвет - HTTP-ответ сервера или веб-сервиса;
//
Procedure Error( Val Event, Val Message, Object = Undefined, HTTPResponse = Undefined ) Export

	Var LoggingOptions;
	
	LoggingOptions = LoggingOptions( Object, HTTPResponse );
	AddResponseBody( LoggingOptions, EventLogLevel.Error, Message );
	Write( Event, EventLogLevel.Error, Message, LoggingOptions );

EndProcedure

// Возвращает дополненный текст сообщения префиксом в формате: "[ Prefix ]: Message"
// 
// Параметры:
// 	Message - строка - текст сообщения;
// 	Prefix - Строка - Prefix;
// 	
// Returns:
// 	Строка - текст сообщения с префиксом;
//
Function AddPrefix( Message, Val Prefix ) Export

	Return "[ " + Prefix + " ]: " + Message;

EndFunction

#EndRegion

#Region Private

Function LogLevelMap()
	
	Var Result;
	
	Result = New Map();
	Result.Insert( NStr("ru = 'Информация';en = 'Information'"), "info" );
	Result.Insert( NStr("ru = 'Предупреждение';en = 'Warning'"), "warning" );
	Result.Insert( NStr("ru = 'Ошибка';en = 'Error'"), "error" );
	
	Return Result;
		
EndFunction

Procedure AppendStatusCode( Event, Val LoggingOptions )
	
	Var Response;
	
	Response = CommonUseClientServer.StructureProperty( LoggingOptions, "HTTPResponse" );

	If ( Response <> Undefined ) Then
			
		Event = Event + "." + String( Response.КодСостояния );
		
	EndIf;

EndProcedure

Procedure AddResponseBody( LoggingOptions, Val Level, Val Message )
	
	Var HTTPResponse;
	Var AddBody;
	Var Body;
	
	HTTPResponse = CommonUseClientServer.StructureProperty( LoggingOptions, "HTTPResponse" );
	
	If ( HTTPResponse = Undefined ) Then
		
		Return;
		
	EndIf;
	
	AddBody = ( HTTPStatusCodesClientServerCached.isOk(HTTPResponse.КодСостояния)
			OR HTTPStatusCodesClientServerCached.isForbidden(HTTPResponse.КодСостояния)
			OR HTTPStatusCodesClientServerCached.isLocked(HTTPResponse.КодСостояния) );

	If ( AddBody ) Then

		HTTPResponse.Headers.Insert( "Content-Type", "application/json" );
		
		Body = HTTPServices.ResponseTemplate();
		Body.message = Message;
		Body.type = LogLevelMap().Get( String(Level) );

		HTTPResponse.SetBodyFromString( HTTPConnector.ОбъектВJson(Body) );

	EndIf;
	
EndProcedure

Procedure Write( Val Event, Val Level, Val Message, Val LoggingOptions )
	
	Var Object;
	
	EVENT_CONTEXT = NStr( "ru = 'ОбработчикиСобытий';en = 'Webhooks'" ); 
	
	AppendStatusCode( Event, LoggingOptions );

	Event = EVENT_CONTEXT + "." + Event;
	
	Object = CommonUseClientServer.StructureProperty( LoggingOptions, "Object" );

	If ( Object = Undefined ) Then

		WriteLogEvent( Event, Level, , , Message);

	Else

		WriteLogEvent( Event, Level, Metadata.FindByType(TypeOf(Object)), Object, Message );

	EndIf;

EndProcedure

// LoggingOptions returns additional parameters for the log event entry.
// 
// Returns:
// Structure - additional parameters:
//   * Object - AnyRef - a ref to an object whose metadata needs to be added to the log;
//   * Response - HTTPResponse, HTTPServiceResponse - HTTP response or HTTP service response;
//
Function LoggingOptions( Val Object = Undefined, Val Response = Undefined )
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "Object", Object );
	Result.Insert( "HTTPResponse", Response );
	
	Return Result;
	
EndFunction

#EndRegion