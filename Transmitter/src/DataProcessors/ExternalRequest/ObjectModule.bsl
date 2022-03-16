#If Server OR ThickClientOrdinaryApplication OR ExternalConnection Then

#Region Public

// TODO desc
Procedure Fill( Val RequestBody ) Export
	
	If ( TypeOf(RequestBody) <> Type("String") ) Then
		
		Raise NStr( "ru = 'недопустимый тип данных';en = 'invalid data type'" );
		
	EndIf;
	
	JSON = RequestBody;
	
	If ( IsGitLab() ) Then
		
		FillFromGitLab( CommonUseServerCall.JsonToObject(RequestBody) );
		
	EndIf;
	
EndProcedure

// TODO desc
Procedure Load( Val Instance ) Export
	
	FillPropertyValues( ThisObject, Instance );
	
	For Each Commit In Instance.Commits Do
		
		NewCommit = Commits.Add();
		FillPropertyValues( NewCommit, Commit );
		
	EndDo;
	
	For Each ModifiedFile In Instance.ModifiedFiles Do
		
		NewModifiedFile = ModifiedFiles.Add();
		FillPropertyValues( NewModifiedFile, ModifiedFile );
		
	EndDo;
	
	For Each Route In Instance.Routes Do
		
		NewRoute = Routes.Add();
		FillPropertyValues( NewRoute, Route );
		
	EndDo;
	
EndProcedure

// TODO desc
Procedure Validate() Export
	
	If ( IsBlankString(JSON) ) Then
		
		Raise Logs.Messages().NO_REQUEST_DATA;
		
	EndIf;

	If ( IsBlankString(ProjectId) OR IsBlankString(ProjectURL) OR IsBlankString(ServerURL) ) Then
		
		Raise Logs.Messages().NO_PROJECT;
		
	EndIf;
	
	If ( IsBlankString(CheckoutSHA) ) Then
		
		Raise Logs.Messages().NO_CHECKOUT_SHA;
		
	EndIf;

EndProcedure

// GetJSON returns the external request data in JSON format. 
// 
// Returns:
// 	String - JSON;
//
Function GetJSON() Export
	
	Return JSON;
	
EndFunction

// GetProjectId returns the project id from the external request data. 
// 
// Returns:
// 	String - project id;
//
Function GetProjectId() Export
	
	Return ProjectId;
	
EndFunction

// GetProjectURL returns the project URL from the external request data. 
// 
// Returns:
// 	String - project URL, for example, "http://server:80/root/example";
//
Function GetProjectURL() Export
	
	Return ProjectURL;
	
EndFunction

// GetServerURL returns the server URL from the external request data. 
// 
// Returns:
// 	String - server URL, for example, "http://server:80";
//
Function GetServerURL() Export
	
	Return ServerURL;
	
EndFunction

// GetCheckoutSHA returns "checkout_sha" from the external request data. 
// 
// Returns:
// 	String - value "checkout_sha";
//
Function GetCheckoutSHA() Export
	
	Return CheckoutSHA;
	
EndFunction

// GetCommits returns "commits" from the external request data.
// If there are no commits, an exception will be thrown. 
// 
// Returns:
// 	DataProcessorTabularSection.ExternalRequest.Commits - commits description;
//
Function GetCommits() Export
	
	If ( NOT ValueIsFilled(Commits) ) Then
		
		Raise Logs.Messages().NO_COMMITS;
		
	EndIf;
	
	Return Commits;
	
EndFunction

// GetCommit returns the selected commit from the external request data.
// If there are no commit, an exception will be thrown.
// 
// Parameters:
// 	CommitSHA - String - сommit SHA;
// 	
// Returns:
// 	DataProcessorTabularSectionRow.ExternalRequest.Commits - selected commit description;
//
Function GetCommit( Val CommitSHA ) Export
	
	For Each Commit In GetCommits() Do

		If ( Commit.Id <> CommitSHA ) Then
			
			Continue;
			
		EndIf;
		
		Return Commit;
		
	EndDo;

	Raise Logs.Messages().NO_COMMIT;
	
EndFunction

// GetModifiedFiles returns all modified files by commits.
// 
// Returns:
// 	Array of Structure - modified file:
// * Id - String - commit id; 
// * Date - Date - file operation date;
// * FilePath - String - relative path to the file for the remote repository (with the filename);
//
Function GetModifiedFiles() Export
	
	Var Result;
	
	Result = ModifiedFiles.Unload();
	
	Result.Columns.Add( "Date", New TypeDescription("Date") );
	
	For Each File In Result Do
		
		File.Date = Commits.Find( File.Id, "Id" ).Date;
		
	EndDo;

	Return CommonUseServerCall.ValueTableToArray( Result );
	
EndFunction

// TODO desc
Function ToCollection() Export
	
	Var Result;
	
	// TODO подумать над рефлексией
	Result = New Structure();
	Result.Insert( "Type" );
	Result.Insert( "JSON" );
	Result.Insert( "ProjectId" );
	Result.Insert( "ProjectURL" );
	Result.Insert( "ServerURL" );
	Result.Insert( "CheckoutSHA" );
	
	FillPropertyValues( Result, ThisObject );
	
	Result.Insert( "Commits", CommonUseServerCall.ValueTableToArray(Commits.Unload()) );
	Result.Insert( "ModifiedFiles", CommonUseServerCall.ValueTableToArray(ModifiedFiles.Unload()) );
	Result.Insert( "Routes", CommonUseServerCall.ValueTableToArray(Routes.Unload()) );
	
	Return Result;
	
EndFunction

// GetRouteJSON returns route in JSON format. Returns empty string if not found.
// 
// Parameters:
// 	Id - String - commit id;
// 	IsCustom - Boolean - custom route option;
// 	
// Returns:
// 	String - route in JSON format, empty string if not found;
//
Function GetRouteJSON( Val Id, Val IsCustom = False ) Export
	
	Var SelectedRoutes;
	
	SelectedRoutes = FindRoutes( Id, IsCustom );
	
	If ( NOT ValueIsFilled(SelectedRoutes) ) Then
		
		Return "";
		
	EndIf;
	
	Return SelectedRoutes[0].JSON;
	
EndFunction

// AddRoute adds route in JSON format to the external request data for the selected commit and custom route option.
// 
// Parameters:
// 	Id - String - commit id;
// 	JSON - route in JSON format;
// 	IsCustom - Boolean - custom route option;
//
Procedure AddRoute( Val Id, Val JSON, Val IsCustom = False ) Export
	
	Var SelectedRoutes;
	
	SelectedRoutes = FindRoutes( Id, IsCustom );
	
	If ( NOT ValueIsFilled(SelectedRoutes) ) Then
		
		SelectedRoutes.Add( Routes.Add() );
		
	EndIf;		
		
	For Each Route In SelectedRoutes Do
		
		Route.Id = Id;
		Route.JSON = JSON;
		Route.IsCustom = IsCustom;
		
	EndDo;
	
EndProcedure

// RemoveRoute removes route from the external request data for the selected commit and custom route option.
// 
// Parameters:
// 	Id - String - commit id;
// 	IsCustom - Boolean - custom route option;
//
Procedure RemoveRoute( Val Id, Val IsCustom = False ) Export
	
	Var SelectedRoutes;
	
	SelectedRoutes = FindRoutes( Id, IsCustom );
	
	For Each Route In SelectedRoutes Do
		
		Routes.Delete( Route );
		
	EndDo;
	
EndProcedure

// TODO нэйминг, мозг не хочет думать, переделать

// GetActualRoutes returns deserialized routes by commits. Custom routes take precedence.
// 
// Returns:
// 	Map - deserialized routes by commits:
// 	* Key - String - commit id;
// 	* Value - Structure - routes data:
// 		** JSON - String - routes in JSON format;
// 		** IsCustom - Boolean - custom route option;
// 		** Data - Map - deserialized routes; 
// 	 
Function GetActualRoutes() Export
	
	Var Records;
	Var NewRoute;
	Var Result;
	
	Records = GetRoutesByCommit( GetRoutesSortedByCustomOption() );

	Result = New Map();
	
	For Each Entity In Records Do
		
		NewRoute = New Structure();
		NewRoute.Insert( "JSON", Entity.Value.JSON );
		NewRoute.Insert( "IsCustom", Entity.Value.IsCustom );
		NewRoute.Insert( "Data", CommonUseServerCall.JsonToObject(Entity.Value.JSON) );
		
		Result.Insert( Entity.Key, NewRoute );
		
	EndDo;

	Return Result;

EndFunction

#EndRegion

#Region Private

Function IsGitLab()
	
	Return ( Type = Enums.RequestSource.GitLab );
	
EndFunction

Procedure FillFromGitLab( Val Object )
	
	// TODO to refactor
	
	Project = GitLabAPI.GetProject( Object );
	
	If ( Project = Undefined ) Then
		
		Return;
	
	EndIf;
	
	// TODO привести к единному неймингу
	ProjectId = Project.Id;
	ProjectURL = Project.URL;
	ServerURL = Project.ServerURL;
	
	CheckoutSHA = GitLabAPI.GetCheckoutSHA( Object );
	
	For Each Commit In GitLabAPI.GetCommits( Object ) Do
		
		NewCommit = Commits.Add();
		NewCommit.Id = Commit.Get( "id" );
		NewCommit.Date = Commit.Get( "timestamp" );
		
	EndDo;
	
	For Each ModifiedFile In GitLabAPI.GetModifiedFiles( Object ) Do
		
		NewModifiedFile = ModifiedFiles.Add();
		FillPropertyValues( NewModifiedFile, ModifiedFile );
		
	EndDo;
	
EndProcedure

Function FindRoutes( Val Id, Val IsCustom )
	
	Var Filter;
	
	Filter = New Structure( "Id, IsCustom", Id, IsCustom );
	
	Return Routes.FindRows( Filter );
	
EndFunction

Function GetRoutesSortedByCustomOption()
	
	Var Result;
	
	Result = Routes.Unload();
	Result.Sort( "IsCustom" );
	
	Return Result;
	
EndFunction

Function GetRoutesByCommit( Val Routes )
	
	Var Entity;
	Var Result;
	
	Result = New Map();
	
	For Each Route In Routes Do
		
		Entity = New Structure( "JSON, IsCustom" );
		FillPropertyValues( Entity, Route );
	
		Result.Insert( Route.Id, Entity );
			
	EndDo;
	
	Return Result;
	
EndFunction

#EndRegion

#EndIf
