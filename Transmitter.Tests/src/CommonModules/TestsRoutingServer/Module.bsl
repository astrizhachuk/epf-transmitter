#Region Public

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesNoData(Framework) Export

	// given
	FileName = NewFileName(".ext-epf", "json");
	Constants.RoutingFileName.Set(FileName);
	Data = New Map;
	Files = New ValueTable();

	// when
	Try
		Routing.GetFilesByRoutes(Data, Files);
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_COMMITS);
	EndTry;	
	
EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesRoutingSettingsNotFound(Framework) Export
	
	// given
	FilesMetadata = NewFilesMetadata();
	FileName = NewFileName("Файл", "epf");
	AddFileMetadata(FilesMetadata, "commit", FileName, "modifed");
	
	Commit = New Map;
	Commit.Insert("id", "commit");
	Commits = New Array;
	Commits.Add(Commit);
	Data = New Map;
	Data.Insert("commits", Commits);
	
	// when	
	Result = Routing.GetFilesByRoutes(Data, FilesMetadata);
	
	// then
	Framework.AssertEqual(Result[0].FileName, FileName);
	Framework.AssertEqual(Result[0].Routes, Undefined);
	Framework.AssertStringContains(GetStringFromBinaryData(Result[0].BinaryData), FileName);

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesSkipRoutingSettingsFile(Framework) Export
	
	// given
	FilesMetadata = NewFilesMetadata();
	FileName = NewFileName("Файл", "epf");
	SettingsFileName = NewFileName("Маршрутизация", "json");
	AddFileMetadata(FilesMetadata, "commit", SettingsFileName, "");

	WebServices = New Array;
	WebServices.Add(NewWebService("http://endpoint", True));
	EPF = New Array;
	EPF.Add(NewEPF(FileName));
	Settings = NewRoutes(WebServices, EPF);
	
	Commit = New Map;
	Commit.Insert("id", "commit");
	Commit.Insert("settings", Settings);
	Commits = New Array;
	Commits.Add(Commit);
	Data = New Map;
	Data.Insert("commits", Commits);
	
	// when	
	Result = Routing.GetFilesByRoutes(Data, FilesMetadata);
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesOneRouteBecauseExcludes(Framework) Export
	
	// given
	FilesMetadata = NewFilesMetadata();
	FileName = NewFileName("Файл", "epf");
	AddFileMetadata(FilesMetadata, "commit1", FileName, "modifed");

	URL1 = "http://endpoint1";
	URL2 = "http://endpoint2";
	URL3 = "http://endpoint3";
	WebServices = New Array;
	WebServices.Add(NewWebService(URL1, True));
	WebServices.Add(NewWebService(URL2, False));
	WebServices.Add(NewWebService(URL3, True));
	EPF = New Array;
	EPF.Add(NewEPF(FileName, NewExcludes(URL1 + "|" + URL2)));
	Settings = NewRoutes(WebServices, EPF);
	
	Commit1 = New Map;
	Commit1.Insert("id", "commit1");
	Commit1.Insert("settings", Settings);
	Commit2 = New Map;
	Commit2.Insert("id", "commit2");
	Commit2.Insert("settings", Settings);
	Commits = New Array;
	Commits.Add(Commit1);
	Commits.Add(Commit2);
	
	Data = New Map;
	Data.Insert("commits", Commits);
	
	// when	
	Result = Routing.GetFilesByRoutes(Data, FilesMetadata);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].FileName, FileName);
	Framework.AssertEqual(Result[0].Routes.Count(), 1);
	Framework.AssertEqual(Result[0].Routes[0], URL3);
	Framework.AssertStringContains(GetStringFromBinaryData(Result[0].BinaryData), FileName);

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesTwoRoutes(Framework) Export
	
	// given
	FilesMetadata = NewFilesMetadata();
	FileName = NewFileName("Файл", "epf");	
	AddFileMetadata(FilesMetadata, "commit2", FileName, "modifed");

	URL1 = "http://endpoint1";
	URL2 = "http://endpoint2";
	URL3 = "http://endpoint3";
	WebServices = New Array;
	WebServices.Add(NewWebService(URL1, True));
	WebServices.Add(NewWebService(URL2, False));
	WebServices.Add(NewWebService(URL3, True));
	EPF = New Array;
	EPF.Add(NewEPF(FileName));
	Settings = NewRoutes(WebServices, EPF);
	
	Commit1 = New Map;
	Commit1.Insert("id", "commit1");
	Commit2 = New Map;
	Commit2.Insert("id", "commit2");
	Commit2.Insert("settings", Settings);
	Commit3 = New Map;
	Commit3.Insert("id", "commit3");
	Commit3.Insert("settings", Settings);
	Commits = New Array;
	Commits.Add(Commit1);
	Commits.Add(Commit2);
	Commits.Add(Commit3);
	
	Data = New Map;
	Data.Insert("commits", Commits);
	
	// when	
	Result = Routing.GetFilesByRoutes(Data, FilesMetadata);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].FileName, FileName);
	Framework.AssertEqual(Result[0].Routes.Count(), 2);
	Framework.AssertEqual(Result[0].Routes[0], URL3);
	Framework.AssertEqual(Result[0].Routes[1], URL1);
	Framework.AssertStringContains(GetStringFromBinaryData(Result[0].BinaryData), FileName);

EndProcedure

// @unit-test:dev
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesNoFileInSettings(Framework) Export
	
	// given
	FilesMetadata = NewFilesMetadata();
	FileName1 = NewFileName("Файл1", "epf");
	FileName2 = NewFileName("Файл2", "epf");
	AddFileMetadata(FilesMetadata, "commit", FileName2, "modifed");

	WebServices = New Array;
	WebServices.Add(NewWebService("http://endpoint", True));
	EPF = New Array;
	EPF.Add(NewEPF(FileName1));
	Settings = NewRoutes(WebServices, EPF);
	
	Commit = New Map;
	Commit.Insert("id", "commit");
	Commit.Insert("settings", Settings);
	Commits = New Array;
	Commits.Add(Commit);
	
	Data = New Map;
	Data.Insert("commits", Commits);
	
	// when	
	Result = Routing.GetFilesByRoutes(Data, FilesMetadata);
	
	// then
	Framework.AssertEqual(Result[0].FileName, FileName2);
	Framework.AssertEqual(Result[0].Routes, Undefined);
	Framework.AssertStringContains(GetStringFromBinaryData(Result[0].BinaryData), FileName2);
	
EndProcedure

#EndRegion

#Region Private

#Region Data

Function NewFileName(Val Name, Val Ext)
	
	TIME = StrReplace(String(CurrentUniversalDateInMilliseconds()), " ", "");
	
	Return Name + TIME + "." + Ext;
	
EndFunction

Function NewFilesMetadata()
	
	Result = New ValueTable();
	Result.Columns.Add( "RAWFilePath", New TypeDescription("String") );
	Result.Columns.Add( "FileName", New TypeDescription("String") );
	Result.Columns.Add( "FilePath", New TypeDescription("String") );
	Result.Columns.Add( "BinaryData", New TypeDescription("BinaryData") );
	Result.Columns.Add( "Action", New TypeDescription("String") );
	Result.Columns.Add( "Date", New TypeDescription("Date") );
	Result.Columns.Add( "CommitSHA", New TypeDescription("String") );
	Result.Columns.Add( "ErrorInfo" );
	
	Return Result;

EndFunction
		
Procedure AddFileMetadata(FilesMetadata, Val CommitSHA, Val FileName, Val Action, Val Error = Undefined)
	
	Data = "{" + FileName + "}";
	FilePath = FileName;
	UtilsServer.AddFileMetadata(FilesMetadata, CommitSHA, FileName, FilePath, Action, Data, Error);
	
EndProcedure

Function NewWebService(Val URL, Val IsEnabled)
	
	Result = New Map;
	Result.Insert("name", URL);
	Result.Insert("url", URL);
	Result.Insert("enabled", IsEnabled);
	
	Return Result;
	
EndFunction

Function NewEPF(Val Name, Val Exclude = Undefined)
	
	Result = New Map;
	Result.Insert("name", Name);
	If Exclude <> Undefined Then
		Result.Insert("exclude", Exclude);
	EndIf;
	
	Return Result;
	
EndFunction

Function NewExcludes(Excludes)

	Return UtilsServer.SplitString(Excludes);
	
EndFunction

Function NewRoutes(Val WebServices, Val Files)
	
	Result = New Map;
	Result.Insert("ws", WebServices);
	Result.Insert("epf", Files);
	
	Return Result;
	
EndFunction

#EndRegion

#EndRegion