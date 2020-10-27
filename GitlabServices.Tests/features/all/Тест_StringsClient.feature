# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.Тест_StringsClient
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

Scenario: ПерекодироватьСтроку
	And I execute 1C:Enterprise script
	| 'Тест_StringsClient.ПерекодироватьСтроку(Context());' |