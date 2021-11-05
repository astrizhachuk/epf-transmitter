# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsStringsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: ПерекодироватьСтроку
	And I execute 1C:Enterprise script at server
	| 'TestsStringsServer.ПерекодироватьСтроку(Context());' |