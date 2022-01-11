#Region Public

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesNoData(Framework) Export

	// given
	Constants.RoutingFileName.Set(Tests.NewFileName(".ext-epf", "json"));
	
	// when
	Try
		Routing.GetFilesByRoutes(New Map, New ValueTable());
		Framework.AddError("Method Executed");
	Except
	// then
		ErrorInfo = ErrorInfo();
		Framework.AssertStringContains(ErrorInfo.Description, Logs.Messages().NO_COMMITS);
	EndTry;	
	
EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesRoutingSettingsNotFound(Framework) Export
	
	// given
	File = Tests.NewFile("каталог", "файл", "epf");

	Commit = Tests.NewCommit("commit");
	Commits = New Array;
	Commits.Add(Commit);
	Data = New Map;
	Data.Insert("commits", Commits);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, File, Commit, "modifed");
	
	// when	
	Result = Routing.GetFilesByRoutes(Data, FilesMetadata);
	
	// then
	Framework.AssertEqual(Result[0].CommitSHA, Commit.Get("id"));
	Framework.AssertEqual(Result[0].FileName, File.FileName);
	Framework.AssertEqual(Result[0].Routes, Undefined);
	Framework.AssertStringContains(GetStringFromBinaryData(Result[0].BinaryData), File.Data);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesSkipRoutingSettingsFile(Framework) Export
	
	// given
	FileEPF = Tests.NewFile("каталог", "файл", "epf");
	FileSettings = Tests.NewFile("", "Маршрутизация", "json");
	
	WebServices = New Array;
	WebServices.Add(Tests.NewWebService("http://endpoint", True));
	
	EPF = New Array;
	EPF.Add(Tests.NewEPF(FileEPF.FilePath));
	
	Settings = Tests.NewRoutes(WebServices, EPF);
	
	Commit = Tests.NewCommit("commit");
	Commit.Insert("settings", Settings);
	Commits = New Array;
	Commits.Add(Commit);
	
	Data = New Map;
	Data.Insert("commits", Commits);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, FileSettings, Commit, "");

	// when	
	Result = Routing.GetFilesByRoutes(Data, FilesMetadata);
	
	// then
	Framework.AssertNotFilled(Result);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesOneRouteBecauseExcludes(Framework) Export
	
	// given
	File = Tests.NewFile("каталог", "файл", "epf");
	
	URL1 = "http://endpoint1";
	URL2 = "http://endpoint2";
	URL3 = "http://endpoint3";
	WebServices = New Array;
	WebServices.Add(Tests.NewWebService(URL1, True));
	WebServices.Add(Tests.NewWebService(URL2, False));
	WebServices.Add(Tests.NewWebService(URL3, True));
	EPF = New Array;
	EPF.Add(Tests.NewEPF(File.FilePath, StrSplit(URL1 + "|" + URL2, "|", False)));
	
	Settings = Tests.NewRoutes(WebServices, EPF);
	
	Commit1 = Tests.NewCommit("commit1");
	Commit1.Insert("settings", Settings);
	Commit2 = Tests.NewCommit("commit2");
	Commit2.Insert("settings", Settings);
	Commits = New Array;
	Commits.Add(Commit1);
	Commits.Add(Commit2);
	
	Data = New Map;
	Data.Insert("commits", Commits);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, File, Commit1, "modifed");
	
	// when	
	Result = Routing.GetFilesByRoutes(Data, FilesMetadata);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].CommitSHA, Commit1.Get("id"));
	Framework.AssertEqual(Result[0].FileName, File.FileName);
	Framework.AssertEqual(Result[0].Routes.Count(), 1);
	Framework.AssertEqual(Result[0].Routes[0], URL3);
	Framework.AssertStringContains(GetStringFromBinaryData(Result[0].BinaryData), File.Data);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesTwoRoutes(Framework) Export
	
	// given
	File = Tests.NewFile("каталог", "файл", "epf");
	
	URL1 = "http://endpoint1";
	URL2 = "http://endpoint2";
	URL3 = "http://endpoint3";
	WebServices = New Array;
	WebServices.Add(Tests.NewWebService(URL1, True));
	WebServices.Add(Tests.NewWebService(URL2, False));
	WebServices.Add(Tests.NewWebService(URL3, True));
	EPF = New Array;
	EPF.Add(Tests.NewEPF(File.FilePath));
	
	Settings = Tests.NewRoutes(WebServices, EPF);

	Commit1 = Tests.NewCommit("commit1");
	Commit2 = Tests.NewCommit("commit2");
	Commit2.Insert("settings", Settings);
	Commit3 = Tests.NewCommit("commit3");
	Commit3.Insert("settings", Settings);
	Commits = New Array;
	Commits.Add(Commit1);
	Commits.Add(Commit2);
	Commits.Add(Commit3);
	
	Data = New Map;
	Data.Insert("commits", Commits);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, File, Commit2, "modifed");
	
	// when	
	Result = Routing.GetFilesByRoutes(Data, FilesMetadata);
	
	// then
	Framework.AssertEqual(Result.Count(), 1);
	Framework.AssertEqual(Result[0].CommitSHA, Commit2.Get("id"));
	Framework.AssertEqual(Result[0].FileName, File.FileName);
	Framework.AssertEqual(Result[0].Routes.Count(), 2);
	Framework.AssertEqual(Result[0].Routes[0], URL3);
	Framework.AssertEqual(Result[0].Routes[1], URL1);
	Framework.AssertStringContains(GetStringFromBinaryData(Result[0].BinaryData), File.Data);

EndProcedure

// @unit-test
// Params:
// 	Framework - TestFramework - Test framework
//
Procedure GetFilesByRoutesNoFileInSettings(Framework) Export
	
	// given
	File1 = Tests.NewFile("каталог", "файл 1", "epf");
	File2 = Tests.NewFile("каталог", "файл 2", "epf");
	
	WebServices = New Array;
	WebServices.Add(Tests.NewWebService("http://endpoint", True));
	EPF = New Array;
	EPF.Add(Tests.NewEPF(File1.FilePath));
	Settings = Tests.NewRoutes(WebServices, EPF);
	
	Commit = Tests.NewCommit("commit");
	Commit.Insert("settings", Settings);
	Commits = New Array;
	Commits.Add(Commit);
	
	Data = New Map;
	Data.Insert("commits", Commits);
	
	FilesMetadata = Tests.NewFilesMetadata();
	Tests.AddFileMetadata(FilesMetadata, File2, Commit, "modifed");	
	
	// when	
	Result = Routing.GetFilesByRoutes(Data, FilesMetadata);
	
	// then
	Framework.AssertEqual(Result[0].CommitSHA, Commit.Get("id"));
	Framework.AssertEqual(Result[0].FileName, File2.FileName);
	Framework.AssertEqual(Result[0].Routes, Undefined);
	Framework.AssertStringContains(GetStringFromBinaryData(Result[0].BinaryData), File2.Data);
	
EndProcedure

#EndRegion
