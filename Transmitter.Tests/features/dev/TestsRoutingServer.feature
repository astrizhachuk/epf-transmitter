# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsRoutingServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: AddCustomRoute
	And I execute 1C:Enterprise script at server
	| 'TestsRoutingServer.AddCustomRoute(Context());' |

@OnServer
Scenario: AddCustomRouteException
	And I execute 1C:Enterprise script at server
	| 'TestsRoutingServer.AddCustomRouteException(Context());' |

@OnServer
Scenario: RemoveCustomRoute
	And I execute 1C:Enterprise script at server
	| 'TestsRoutingServer.RemoveCustomRoute(Context());' |

@OnServer
Scenario: RemoveCustomRouteNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsRoutingServer.RemoveCustomRouteNotFound(Context());' |