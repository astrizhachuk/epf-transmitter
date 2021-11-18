# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsServicesSettingsClient
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

Scenario: Settings
	And I execute 1C:Enterprise script
	| 'TestsServicesSettingsClient.Settings(Context());' |