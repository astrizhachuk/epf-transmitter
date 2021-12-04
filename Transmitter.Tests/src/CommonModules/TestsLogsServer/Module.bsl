// BSLLS-off
#Region Public

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure Events(Framework) Export

	// given
	
	// when
	Result = Logs.Events();
	
	// then
	Framework.AssertType(Result, "Structure");

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure Messages(Framework) Export

	// given
	
	// when
	Result = Logs.Messages();
	
	// then
	Framework.AssertType(Result, "Structure");

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoOnlyEvent(Framework) Export

	// given
	Event = NewEvent(NStr("ru = 'Информация1';en = 'Information1'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event);
	Comment = "InfoOnlyEvent";
	
	// when
	Pause(1);
	Logs.Info(ToString(Event), Comment);
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure WarnOnlyEvent(Framework) Export
	
	// given
	Event = NewEvent(NStr("ru = 'Предупреждение1';en = 'Warning1'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Warning");
	Comment = "WarnOnlyEvent";
	
	// when
	Pause(1);
	Logs.Warn(ToString(Event), Comment);
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);
		
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	
EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ErrorOnlyEvent(Framework) Export
	
	// given
	Event = NewEvent(NStr("ru = 'Ошибка1';en = 'Error1'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Error");
	Comment = "ErrorOnlyEvent";
	
	// when
	Pause(1);
	Logs.Error(ToString(Event), Comment);
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);
		
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	
EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoEventWithObject(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();
	
	Event = NewEvent(NStr("ru = 'Информация2';en = 'Information2'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event);
	Comment = "InfoEventWithObject";

	// when
	Pause(1);
	Logs.Info(ToString(Event), Comment, NewExternalRequestHandler("Test", "Token").Ref );
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	Framework.AssertFalse(IsBlankString(Result[0].MetadataPresentation));

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure WarnEventWithObject(Framework) Export
	
	// given
	ExternalRequestHandlersCleanUp();

	Event = NewEvent(NStr("ru = 'Предупреждение2';en = 'Warning2'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Warning");
	Comment = "WarnEventWithObject";
	
	// when
	Pause(1);
	Logs.Warn(ToString(Event), Comment, NewExternalRequestHandler("Test", "Token").Ref );
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);
	
	// then	
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	Framework.AssertFalse(IsBlankString(Result[0].MetadataPresentation));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ErrorEventWithObject(Framework) Export

	// given
	ExternalRequestHandlersCleanUp();
	
	Event = NewEvent(NStr("ru = 'Ошибка2';en = 'Error2'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Error");
	Comment = "ErrorEventWithObject";

	// when
	Pause(1);
	Logs.Error(ToString(Event), Comment, NewExternalRequestHandler("Test", "Token").Ref );
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	Framework.AssertFalse(IsBlankString(Result[0].MetadataPresentation));
	
EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoEventWithObjectAndHTTPResponse200WithoutBody(Framework) Export
	
	// given
	StatusCode = 200;
	Event = NewEvent(NStr("ru = 'Информация3';en = 'Information3'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Information", StatusCode);
	Comment = "InfoEventWithObjectAndHTTPResponse200WithoutBody";
	Response = New HTTPServiceResponse(StatusCode);
	
	// when
	Pause(1);
	Logs.Info(ToString(Event), Comment, , Response );
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertStringContains(Result[0].Comment, Comment);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertTrue(IsBlankString(Response.GetBodyAsString()));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure WarnEventWithObjectAndHTTPResponse200WithoutBody(Framework) Export
	
	// given
	StatusCode = 200;
	Event = NewEvent(NStr("ru = 'Предупреждение3';en = 'Warning3'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Warning", StatusCode);
	Comment = "WarnEventWithObjectAndHTTPResponse200WithoutBody";
	Response = New HTTPServiceResponse(StatusCode);
	
	// when
	Pause(1);
	Logs.Warn(ToString(Event), Comment, , Response );
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertTrue(IsBlankString(Response.GetBodyAsString()));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ErrorEventWithObjectAndHTTPResponse200WithoutBody(Framework) Export
	
	// given
	StatusCode = 200;
	Event = NewEvent(NStr("ru = 'Ошибка3';en = 'Error3'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Error", StatusCode);
	Comment = "ErrorEventWithObjectAndHTTPResponse200WithoutBody";
	Response = New HTTPServiceResponse(StatusCode);

	// when
	Pause(1);
	Logs.Error(ToString(Event), Comment, , Response );
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);

	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertTrue(IsBlankString(Response.GetBodyAsString()));

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoEventWithObjectAndHTTPResponse400WithBody(Framework) Export

	// given
	StatusCode = 400;
	Event = NewEvent(NStr("ru = 'Информация4';en = 'Information4'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Information", StatusCode);
	Comment = "InfoEventWithObjectAndHTTPResponse400WithBody";
	Response = New HTTPServiceResponse(StatusCode);
		
	// when
	Pause(1);
	Logs.Info(ToString(Event), Comment, , Response );
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertEqual(Response.Headers.Get("Content-Type"), "application/json");
	Framework.AssertStringContains(Response.GetBodyAsString(), """message"":");
	Framework.AssertStringContains(Response.GetBodyAsString(), Comment);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoEventWithObjectAndHTTPResponse401WithoutBody(Framework) Export
	
	// given
	StatusCode = 401;
	Event = NewEvent(NStr("ru = 'Информация5';en = 'Information5'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Information", StatusCode);
	Comment = "InfoEventWithObjectAndHTTPResponse401WithoutBody";
	Response = New HTTPServiceResponse(StatusCode);
	
	// when
	Pause(1);
	Logs.Info(ToString(Event), Comment, , Response );
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertTrue(IsBlankString(Response.GetBodyAsString()));				

EndProcedure	

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoEventWithObjectAndHTTPResponse404WithoutBody(Framework) Export
	
	// given
	StatusCode = 404;
	Event = NewEvent(NStr("ru = 'Информация6';en = 'Information6'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Information", StatusCode);
	Comment = "InfoEventWithObjectAndHTTPResponse404WithoutBody";
	Response = New HTTPServiceResponse(StatusCode);
	
	// when
	Pause(1);
	Logs.Info(ToString(Event), Comment, , Response );
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertTrue(IsBlankString(Response.GetBodyAsString()));				

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoEventWithObjectAndHTTPResponse423WithoutBody(Framework) Export
	
	// given
	StatusCode = 423;
	Event = NewEvent(NStr("ru = 'Информация7';en = 'Information7'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Information", StatusCode);
	Comment = "InfoEventWithObjectAndHTTPResponse423WithoutBody";
	Response = New HTTPServiceResponse(StatusCode);
	
	// when
	Pause(1);
	Logs.Info(ToString(Event), Comment, , Response );
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertTrue(IsBlankString(Response.GetBodyAsString()));				

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ErrorEventWithObjectAndHTTPResponse500WithBody(Framework) Export
	
	// given
	StatusCode = 500;
	Event = NewEvent(NStr("ru = 'Ошибка8';en = 'Error8'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Error", StatusCode);
	Comment = "ErrorEventWithObjectAndHTTPResponse500WithBody";
	Response = New HTTPServiceResponse(StatusCode);
	
	// when
	Pause(1);
	Logs.Error(ToString(Event), Comment, , Response );
	Pause(2);
	Result = GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertEqual(Response.Headers.Get("Content-Type"), "text/plain");
	Framework.AssertStringContains(Response.GetBodyAsString(), Comment);			

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure AddPrefix(Framework) Export
	
	// given
	Prefix = "Prefix Префикс";
	Message = "Message Сообщение";
	
	// when
	Result = Logs.AddPrefix(Message, Prefix);
	
	// then
	Framework.AssertEqual(Result, "[ Prefix Префикс ]: Message Сообщение");
	
EndProcedure	

#EndRegion

#Region Private

Procedure Pause(Val Period)
	
	UtilsServer.Pause(Period);
	
EndProcedure

#Region EventLog

Function NewLog()
	
	Result = New Array();
	Result.Add(Metadata.Catalogs.ExternalRequestHandlers.Synonym);

	Return Result;
	
EndFunction

Function NewEvent(Val Value, Val Level)
	
	Result = New Array();
	
	For Index = 1 To Level Do
		
		Result.Add(Value + String(Index) );
		
	EndDo;
	
	Return Result;
	
EndFunction

Function ToString(Val Events)
	
	Return StrConcat(Events, ".");
	
EndFunction

Function EventLogFilterByEvent(Events, Level = "Information", Val StatusCode = 0)
	
	Result = NewLog();
	
	CommonUseClientServer.SupplementArray(Result, Events);

	If ValueIsFilled(StatusCode) Then
		
		Result.Add(StatusCode);
		
	EndIf;

	Return UtilsServer.EventLogFilterByEvent(StrConcat(Result, "."), Level, "1CV8C");
	
EndFunction

Function GetEventLog(Val Filter)
	
	Return UtilsServer.GetEventLog(Filter);
	
EndFunction

#EndRegion

#Region Data

Procedure ExternalRequestHandlersCleanUp()
	
	UtilsServer.CatalogCleanUp("ExternalRequestHandlers");

EndProcedure

Function NewExternalRequestHandler(Val Name, Val Token)

	Return TestsWebhooksServer.AddExternalRequestHandler(Name, "empty", Token);

EndFunction

#EndRegion

#EndRegion
