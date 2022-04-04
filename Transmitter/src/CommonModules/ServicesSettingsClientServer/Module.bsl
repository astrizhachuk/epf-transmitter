#Region Public

// Settings returns an undefined collection of the settings.
// 
// Returns:
// 	Structure - description:
// * HandleGitLabRequests - Boolean - True - to handle GitLab requests, otherwise - False;
// * RoutingFileName - String - the name of the routing settings file;
// * GitLabToken - String - a token for connecting to external storage on GitLab server;
// * GitLabTimeout - Number - the connection timeout to external storage on GitLab server;
// * EndpointUserName - String - endpoint infobase user name;
// * EndpointUserPassword - String - endpoint infobase user password;
// * EndpointTimeout - Number - endpoint infobase connection timeout;
// 
Function Settings() Export
	
	Var Result;

	Result = New Structure();
	Result.Insert( "HandleGitLabRequests" );
	Result.Insert( "RoutingFileName" );
	Result.Insert( "GitLabToken" );
	Result.Insert( "GitLabTimeout" );
	Result.Insert( "EndpointUserName" );
	Result.Insert( "EndpointUserPassword" );
	Result.Insert( "EndpointTimeout" );
	
	Return Result;
	
EndFunction

#EndRegion
