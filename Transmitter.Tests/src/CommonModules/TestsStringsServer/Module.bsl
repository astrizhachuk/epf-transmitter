#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure EncodeStringFromTo(Framework) Export
	
	// given
	UTF8 = "тестовая строка";
	KOI8 = "я┌п╣я│я┌п╬п╡п╟я▐ я│я┌я─п╬п╨п╟";
	
	// when
	NewKOI8 = StringsClientServer.Encode(UTF8, "UTF-8", "KOI8-R");
	NewUTF8 = StringsClientServer.Encode(NewKOI8, "KOI8-R");
	
	// then
	Framework.AssertEqual(KOI8, NewKOI8); 
	Framework.AssertEqual(UTF8, NewUTF8);
	
EndProcedure

#EndRegion