# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsLoggingServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody403
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.InfoEventWithObjectAndHTTPResponseWithBody403(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody423
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.InfoEventWithObjectAndHTTPResponseWithBody423(Context());' |