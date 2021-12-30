# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsRoutingServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: GetFilesByRoutesNoData
	And I execute 1C:Enterprise script at server
	| 'TestsRoutingServer.GetFilesByRoutesNoData(Context());' |

@OnServer
Scenario: GetFilesByRoutesRoutingSettingsNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsRoutingServer.GetFilesByRoutesRoutingSettingsNotFound(Context());' |

@OnServer
Scenario: GetFilesByRoutesSkipRoutingSettingsFile
	And I execute 1C:Enterprise script at server
	| 'TestsRoutingServer.GetFilesByRoutesSkipRoutingSettingsFile(Context());' |

@OnServer
Scenario: GetFilesByRoutesOneRouteBecauseExcludes
	And I execute 1C:Enterprise script at server
	| 'TestsRoutingServer.GetFilesByRoutesOneRouteBecauseExcludes(Context());' |

@OnServer
Scenario: GetFilesByRoutesTwoRoutes
	And I execute 1C:Enterprise script at server
	| 'TestsRoutingServer.GetFilesByRoutesTwoRoutes(Context());' |

@OnServer
Scenario: GetFilesByRoutesNoFileInSettings
	And I execute 1C:Enterprise script at server
	| 'TestsRoutingServer.GetFilesByRoutesNoFileInSettings(Context());' |