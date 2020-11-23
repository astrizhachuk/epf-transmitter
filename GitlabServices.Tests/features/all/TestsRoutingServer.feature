# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.TestsRoutingServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: FilesByRoutes
	And I execute 1C:Enterprise script at server
	| 'TestsRoutingServer.FilesByRoutes(Context());' |

@OnServer
Scenario: AddRoutingFilesDescription
	And I execute 1C:Enterprise script at server
	| 'TestsRoutingServer.AddRoutingFilesDescription(Context());' |

@OnServer
Scenario: ExtendQueryDataWithRoutingSettings
	And I execute 1C:Enterprise script at server
	| 'TestsRoutingServer.ExtendQueryDataWithRoutingSettings(Context());' |