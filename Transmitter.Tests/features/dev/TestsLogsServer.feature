# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsLogsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: InfoOnlyEvent
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoOnlyEvent(Context());' |

@OnServer
Scenario: InfoWithPrefix
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoWithPrefix(Context());' |

@OnServer
Scenario: WarnWithPrefix
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.WarnWithPrefix(Context());' |

@OnServer
Scenario: ErrorWithPrefix
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.ErrorWithPrefix(Context());' |