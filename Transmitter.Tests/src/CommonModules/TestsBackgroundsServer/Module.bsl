#Region Public

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetJobsByKeyPrefixNoFilter(Framework) Export

	// given

	// when
	Result = Backgrounds.GetByKeyPrefix(Undefined, "");
	
	// then
	Framework.AssertType(Result, "Array");
	Framework.AssertNotFilled(Result);
	
EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetJobsByKeyPrefix(Framework) Export

	// given
	Prefix = Tests.RandomString();
	JobKey = Prefix + "|...";
	Filter = New Structure( "MethodName", "TestsBackgroundsServer.Stub" );
	BackgroundJobs.Execute( "TestsBackgroundsServer.Stub", , JobKey );
	For i = 1 To 3 Do
		BackgroundJobs.Execute( "TestsBackgroundsServer.Stub", , Tests.RandomString() );
	EndDo;

	// when
	Result = Backgrounds.GetByKeyPrefix(Filter, Prefix);
	
	// then
	Framework.AssertType(Result, "Array");
	Framework.AssertEqual(Result[0].Key, JobKey);
	
EndProcedure

#EndRegion

#Region Internal

Procedure Stub(Val Wait = 5) Export
	
	Tests.Pause(Wait);
	
EndProcedure

#EndRegion
