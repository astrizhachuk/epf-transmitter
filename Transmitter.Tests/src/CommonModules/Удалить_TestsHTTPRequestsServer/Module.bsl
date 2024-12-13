// BSLLS-off
#Region Public


// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure CustomSendPost400BadRequestMultiparts(Framework) Export
	
	// given
	Constants.ОбрабатыватьПользовательскийЗапрос.Set(True);
	Constants.ОбрабатыватьГитлабЗапрос.Set(False);
	Stub = StubCustomRequest();

	// when
	Result = КоннекторHTTP.Post(Stub.URL);
	
	// then
	Framework.AssertEqual(Result.StatusCode, 400);
	Body = КоннекторHTTP.КакТекст(Result, TextEncoding.UTF8);
	Framework.AssertFalse(IsBlankString(Body));
	Framework.AssertStringContains(Body, "multipart/form-data");

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure CustomSendPost400BadRequestWithoutToken(Framework) Export
	
	// given
	Constants.ОбрабатыватьПользовательскийЗапрос.Set(True);
	Constants.ОбрабатыватьГитлабЗапрос.Set(False);
	
	Stub = StubCustomRequest();

	// when
	Result = КоннекторHTTP.Post(Stub.URL, Stub.JSON);
	
	// then
	Framework.AssertEqual(Result.StatusCode, 400);
	Body = КоннекторHTTP.КакТекст(Result, TextEncoding.UTF8);
	Framework.AssertFalse(IsBlankString(Body));
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure CustomSendPost423Locked(Framework) Export

	// given
	Constants.ОбрабатыватьПользовательскийЗапрос.Set(False);
	Constants.ОбрабатыватьГитлабЗапрос.Set(True);
	
	Stub = StubCustomRequest();	

	// when
	Result = КоннекторHTTP.Post(Stub.URL, Stub.JSON);

	// then
	Framework.AssertEqual(Result.StatusCode, 423);
	Body = КоннекторHTTP.КакТекст(Result, TextEncoding.UTF8);
	Framework.AssertTrue(IsBlankString(Body));

EndProcedure

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Function StubCustomRequest()
	
	Result = New Structure();
	Result.Insert("URL", "http://transmitter/api/" + CurrentLanguage().LanguageCode + "/hs/custom/send");
	Result.Insert("JSON", "{}");
		
	Return Result;
	
EndFunction

#КонецОбласти