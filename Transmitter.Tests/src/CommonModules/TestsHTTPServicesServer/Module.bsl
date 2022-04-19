// BSLLS-выкл.
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetHandleRequestStatusException(Framework) Export

	// given
	Error = NStr( "ru = 'неверный тип запроса';en = 'invalid request type'" );
	
	// when
	Try
		HTTPServices.GetHandleRequestStatus("");
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Error);
	EndTry;
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure CreateMessage(Framework) Export

	// given
	Text = "new text";
	
	// when
	Result = HTTPServices.CreateMessage(Text);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result.message, Text);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure SetBodyAsJSON(Framework) Export
	
	// given
	Result = New HTTPServiceResponse(200);
	Structure = New Structure();
	Structure.Insert("Key", 1);
	
	// when
	HTTPServices.SetBodyAsJSON(Result, Structure);
	
	// then
	Framework.AssertEqual(Result.GetBodyAsString(), "{""Key"":1}"); 
	
EndProcedure

#EndRegion