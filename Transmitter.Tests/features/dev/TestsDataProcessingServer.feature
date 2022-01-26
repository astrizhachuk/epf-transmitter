# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsDataProcessingServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: GetBackgroundsByCommit
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.GetBackgroundsByCommit(Context());' |