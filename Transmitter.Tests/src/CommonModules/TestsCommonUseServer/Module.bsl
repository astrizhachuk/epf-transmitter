#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetVersion(Framework) Export

	// given

	// when
	Result = CommonUseServerCall.GetVersion();
	
	// then
	Framework.AssertEqual(Result, Metadata.Version);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure NewErrorInfo(Framework) Export

	// given
	Message = "new description";

	// when
	Result = CommonUseServerCall.NewErrorInfo(Message);
	
	// then
	Framework.AssertStringContains(Result.Description, Message);
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure AppendCollectionFromStream(Framework) Export

	// given
	Stream = New MemoryStream();
	Writer = New TextWriter(Stream);
	Text = "text текст";
	Writer.Write(Text);
   	Writer.Close();

	Result = New Structure("Key", "Value");
	
	// when
	CommonUseServerCall.AppendCollectionFromStream(Result, "NewKey", Stream);
   	Stream.Close();

	// then
   	Framework.AssertEqual( Result.NewKey, Text );

EndProcedure

#EndRegion