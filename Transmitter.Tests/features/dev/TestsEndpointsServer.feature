# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsEndpointsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: GetServiceStatusURLInlineAuth
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetServiceStatusURLInlineAuth(Context());' |

@OnServer
Scenario: GetServiceStatusBaseURLInlineAuth
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetServiceStatusBaseURLInlineAuth(Context());' |