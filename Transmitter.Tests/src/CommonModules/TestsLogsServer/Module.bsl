// BSLLS-off
#Region Public

// @unit-test
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

// @unit-test
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
	Event = NewEvent(NStr("ru = 'Информация';en = 'Information'"), 3);
	Comment = "InfoOnlyEvent";
	
	// when
	Result = Logs.Info(ToString(Event), Comment);

	// then
	Framework.AssertEqual(Result, Comment);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure WarnOnlyEvent(Framework) Export
	
	// given
	Event = NewEvent(NStr("ru = 'Предупреждение';en = 'Warning'"), 3);
	Comment = "WarnOnlyEvent";
	
	// when
	Result = Logs.Warn(ToString(Event), Comment);
		
	// then
	Framework.AssertEqual(Result, Comment);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ErrorOnlyEvent(Framework) Export
	
	// given
	Event = NewEvent(NStr("ru = 'Ошибка';en = 'Error'"), 3);
	Comment = "ErrorOnlyEvent";
	
	// when
	Result = Logs.Error(ToString(Event), Comment);
		
	// then
	Framework.AssertEqual(Result, Comment);
	
EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoWithPrefix(Framework) Export
	
	// given
	Event = NewEvent(NStr("ru = 'Информация';en = 'Information'"), 3);
	Prefix = Tests.RandomString();
	Comment = "InfoWithPrefix";
	
	// when
	Result = Logs.Info(ToString(Event), Comment, Prefix);
	
	// then
	Framework.AssertStringContains(Result, Prefix);
	Framework.AssertStringContains(Result, Comment);
	Framework.AssertNotEqual(Result, Comment);

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure WarnWithPrefix(Framework) Export
	
	// given
	Event = NewEvent(NStr("ru = 'Предупреждение';en = 'Warning'"), 3);
	Prefix = Tests.RandomString();
	Comment = "WarnWithPrefix";
	
	// when
	Result = Logs.Warn(ToString(Event), Comment, Prefix);
	
	// then
	Framework.AssertStringContains(Result, Prefix);
	Framework.AssertStringContains(Result, Comment);
	Framework.AssertNotEqual(Result, Comment);

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ErrorWithPrefix(Framework) Export
	
	// given
	Event = NewEvent(NStr("ru = 'Ошибка';en = 'Error'"), 3);
	Prefix = Tests.RandomString();
	Comment = "ErrorWithPrefix";
	
	// when
	Result = Logs.Error(ToString(Event), Comment, Prefix);
	
	// then
	Framework.AssertStringContains(Result, Prefix);
	Framework.AssertStringContains(Result, Comment);
	Framework.AssertNotEqual(Result, Comment);

EndProcedure

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoEventWithObject(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	
	Event = NewEvent(NStr("ru = 'Информация';en = 'Information'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event);
	Comment = "InfoEventWithObject";

	// when
	Tests.Pause(1);
	Logs.Info(ToString(Event), Comment, , Tests.NewExternalRequestHandler().Ref );
	Tests.Pause(2);
	Result = Tests.GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	Framework.AssertFalse(IsBlankString(Result[0].MetadataPresentation));

EndProcedure

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure WarnEventWithObject(Framework) Export
	
	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");

	Event = NewEvent(NStr("ru = 'Предупреждение';en = 'Warning'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Warning");
	Comment = "WarnEventWithObject";
	
	// when
	Tests.Pause(1);
	Logs.Warn(ToString(Event), Comment, , Tests.NewExternalRequestHandler().Ref );
	Tests.Pause(2);
	Result = Tests.GetEventLog(EventLogFilterByEvent);
	
	// then	
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	Framework.AssertFalse(IsBlankString(Result[0].MetadataPresentation));
	
EndProcedure

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ErrorEventWithObject(Framework) Export

	// given
	Tests.CatalogCleanUp("ExternalRequestHandlers");
	
	Event = NewEvent(NStr("ru = 'Ошибка';en = 'Error'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Error");
	Comment = "ErrorEventWithObject";

	// when
	Tests.Pause(1);
	Logs.Error(ToString(Event), Comment, , Tests.NewExternalRequestHandler().Ref );
	Tests.Pause(2);
	Result = Tests.GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	Framework.AssertFalse(IsBlankString(Result[0].MetadataPresentation));
	
EndProcedure

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoEventWithObjectAndHTTPResponse200WithoutBody(Framework) Export
	
	// given
	StatusCode = 200;
	Event = NewEvent(NStr("ru = 'Информация';en = 'Information'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Information", StatusCode);
	Comment = "InfoEventWithObjectAndHTTPResponse200WithoutBody";
	Response = New HTTPServiceResponse(StatusCode);
	
	// when
	Tests.Pause(1);
	Logs.Info(ToString(Event), Comment, , , Response );
	Tests.Pause(2);
	Result = Tests.GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertStringContains(Result[0].Comment, Comment);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertTrue(IsBlankString(Response.GetBodyAsString()));
	
EndProcedure

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure WarnEventWithObjectAndHTTPResponse200WithoutBody(Framework) Export
	
	// given
	StatusCode = 200;
	Event = NewEvent(NStr("ru = 'Предупреждение';en = 'Warning'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Warning", StatusCode);
	Comment = "WarnEventWithObjectAndHTTPResponse200WithoutBody";
	Response = New HTTPServiceResponse(StatusCode);
	
	// when
	Tests.Pause(1);
	Logs.Warn(ToString(Event), Comment, , , Response );
	Tests.Pause(2);
	Result = Tests.GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertTrue(IsBlankString(Response.GetBodyAsString()));
	
EndProcedure

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ErrorEventWithObjectAndHTTPResponse200WithoutBody(Framework) Export
	
	// given
	StatusCode = 200;
	Event = NewEvent(NStr("ru = 'Ошибка';en = 'Error'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Error", StatusCode);
	Comment = "ErrorEventWithObjectAndHTTPResponse200WithoutBody";
	Response = New HTTPServiceResponse(StatusCode);

	// when
	Tests.Pause(1);
	Logs.Error(ToString(Event), Comment, , , Response );
	Tests.Pause(2);
	Result = Tests.GetEventLog(EventLogFilterByEvent);

	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertTrue(IsBlankString(Response.GetBodyAsString()));

EndProcedure

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoEventWithObjectAndHTTPResponse400WithBody(Framework) Export

	// given
	StatusCode = 400;
	Event = NewEvent(NStr("ru = 'Информация';en = 'Information'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Information", StatusCode);
	Comment = "InfoEventWithObjectAndHTTPResponse400WithBody";
	Response = New HTTPServiceResponse(StatusCode);
		
	// when
	Tests.Pause(1);
	Logs.Info(ToString(Event), Comment, , , Response );
	Tests.Pause(2);
	Result = Tests.GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].Comment, Comment);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertEqual(Response.Headers.Get("Content-Type"), "application/json");
	Framework.AssertStringContains(Response.GetBodyAsString(), """message"":");
	Framework.AssertStringContains(Response.GetBodyAsString(), Comment);

EndProcedure

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoEventWithObjectAndHTTPResponse401WithoutBody(Framework) Export
	
	// given
	StatusCode = 401;
	Event = NewEvent(NStr("ru = 'Информация';en = 'Information'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Information", StatusCode);
	Comment = "InfoEventWithObjectAndHTTPResponse401WithoutBody";
	Response = New HTTPServiceResponse(StatusCode);
	
	// when
	Tests.Pause(1);
	Logs.Info(ToString(Event), Comment, , , Response );
	Tests.Pause(2);
	Result = Tests.GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertTrue(IsBlankString(Response.GetBodyAsString()));				

EndProcedure	

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoEventWithObjectAndHTTPResponse404WithoutBody(Framework) Export
	
	// given
	StatusCode = 404;
	Event = NewEvent(NStr("ru = 'Информация';en = 'Information'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Information", StatusCode);
	Comment = "InfoEventWithObjectAndHTTPResponse404WithoutBody";
	Response = New HTTPServiceResponse(StatusCode);
	
	// when
	Tests.Pause(1);
	Logs.Info(ToString(Event), Comment, , , Response );
	Tests.Pause(2);
	Result = Tests.GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertTrue(IsBlankString(Response.GetBodyAsString()));				

EndProcedure

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure InfoEventWithObjectAndHTTPResponse423WithoutBody(Framework) Export
	
	// given
	StatusCode = 423;
	Event = NewEvent(NStr("ru = 'Информация';en = 'Information'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Information", StatusCode);
	Comment = "InfoEventWithObjectAndHTTPResponse423WithoutBody";
	Response = New HTTPServiceResponse(StatusCode);
	
	// when
	Tests.Pause(1);
	Logs.Info(ToString(Event), Comment, , , Response );
	Tests.Pause(2);
	Result = Tests.GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertTrue(IsBlankString(Response.GetBodyAsString()));				

EndProcedure

// @unit-test
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure ErrorEventWithObjectAndHTTPResponse500WithBody(Framework) Export
	
	// given
	StatusCode = 500;
	Event = NewEvent(NStr("ru = 'Ошибка';en = 'Error'"), 3);
	EventLogFilterByEvent = EventLogFilterByEvent(Event, "Error", StatusCode);
	Comment = "ErrorEventWithObjectAndHTTPResponse500WithBody";
	Response = New HTTPServiceResponse(StatusCode);
	
	// when
	Tests.Pause(1);
	Logs.Error(ToString(Event), Comment, , , Response );
	Tests.Pause(2);
	Result = Tests.GetEventLog(EventLogFilterByEvent);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Response.StatusCode, StatusCode);
	Framework.AssertEqual(Response.Headers.Get("Content-Type"), "text/plain");
	Framework.AssertStringContains(Response.GetBodyAsString(), Comment);			

EndProcedure

#EndRegion

#Region Private

#Region EventLog

Function NewLog()
	
	Result = New Array();
	Result.Add(Metadata.Catalogs.ExternalRequestHandlers.Synonym);

	Return Result;
	
EndFunction

Function NewEvent(Val Value, Val Level)
	
	Result = New Array();
	
	RandomString = Tests.RandomString();
	
	For Index = 1 To Level Do
		
		Result.Add(Value + RandomString + String(Index) );
		
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

	Return Tests.EventLogFilterByEvent(StrConcat(Result, "."), Level, "1CV8C");
	
EndFunction

#EndRegion

#EndRegion
