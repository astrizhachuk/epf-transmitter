// BSLLS-выкл.
#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FindHeaderLower(Framework) Export

	// given
	Text = "test";
	Headers = New Map;
	Headers.Insert("content-type", Text);	
	Request = New HTTPRequest("localhost", Headers);
	
	// when
	Result = HTTPServices.FindHeader(Request, "Content-Type");
	
	// then
	Framework.AssertEqual(Result, Text);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FindHeaderUpper(Framework) Export

	// given
	Text = "test";
	Headers = New Map;
	Headers.Insert("CONTENT-TYPE", Text);	
	Request = New HTTPRequest("localhost", Headers);
	
	// when
	Result = HTTPServices.FindHeader(Request, "Content-Type");
	
	// then
	Framework.AssertEqual(Result, Text);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure FindHeader(Framework) Export

	// given
	Text = "test";
	Headers = New Map;
	Headers.Insert("Content-Type", Text);	
	Request = New HTTPRequest("localhost", Headers);
	
	// when
	Result = HTTPServices.FindHeader(Request, "Content-Type");
	
	// then
	Framework.AssertEqual(Result, Text);
	
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