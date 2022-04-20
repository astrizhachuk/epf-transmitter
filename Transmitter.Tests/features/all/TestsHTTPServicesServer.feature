# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsHTTPServicesServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: CreateMessage
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.CreateMessage(Context());' |

@OnServer
Scenario: SetBodyAsJSON
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.SetBodyAsJSON(Context());' |