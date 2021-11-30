# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsEndpointsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: SendFile4xxError
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFile4xxError(Context());' |

@OnServer
Scenario: SendFileBackgroundJob200OkMultipleFiles
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFileBackgroundJob200OkMultipleFiles(Context());' |