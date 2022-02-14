# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsLogsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: WarnEventWithObject
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.WarnEventWithObject(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponse200WithoutBody
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoEventWithObjectAndHTTPResponse200WithoutBody(Context());' |

@OnServer
Scenario: GetEventsHistoryStatusCode
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.GetEventsHistoryStatusCode(Context());' |

@OnServer
Scenario: GetEventsHistoryWithoutStatusCode
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.GetEventsHistoryWithoutStatusCode(Context());' |