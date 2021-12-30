# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsWebhooksServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: LoadEventsHistory
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.LoadEventsHistory(Context());' |