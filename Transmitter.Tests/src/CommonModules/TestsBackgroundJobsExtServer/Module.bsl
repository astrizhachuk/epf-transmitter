// BSLLS-off
#Region Public

// @unit-test:dev
// @timer
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure IsActive(Framework) Export

	// given
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	JOB_KEY = "key" + TIME;
	Duration = 2;
	Params = New Array();
	Params.Add(Duration);
	
	// when
	BackgroundJobs.Execute("TestsBackgroundJobsExtServer.Stub", Params, JOB_KEY);
	Result1 = BackgroundJobsExt.IsActive(JOB_KEY);
	Pause(Duration + 2);
	Result2 = BackgroundJobsExt.IsActive(JOB_KEY);
	
	// then
	Framework.AssertTrue(Result1);
	Framework.AssertFalse(Result2);
	
EndProcedure

#EndRegion

#Region Internal

Procedure Stub(Val Param1) Export
	
	Pause(Param1);
	
EndProcedure

#EndRegion

#Region Private

Procedure Pause(Val Period)
	
	UtilsServer.Pause(Period);
	
EndProcedure

#EndRegion
