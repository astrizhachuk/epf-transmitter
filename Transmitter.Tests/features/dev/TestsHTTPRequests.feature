# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsHTTPRequests
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: EventsPostPush423Locked
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPush423Locked(Context());' |