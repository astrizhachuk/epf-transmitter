#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure Settings(Framework) Export
	
	// given
	Result = Undefined;
	// when
	Result = ServicesSettingsClientCerver.Settings();
	// then
	Framework.AssertEqual(Result.Количество(), 7);
	
EndProcedure

#EndRegion
