# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.TestsLoggingServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponse200
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.InfoEventWithObjectAndHTTPResponse200(Context());' |