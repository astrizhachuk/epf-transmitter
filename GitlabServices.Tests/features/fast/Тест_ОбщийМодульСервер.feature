# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.Тест_ОбщийМодульСервер
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: МокСерверДоступен
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбщийМодульСервер.МокСерверДоступен(Context());' |