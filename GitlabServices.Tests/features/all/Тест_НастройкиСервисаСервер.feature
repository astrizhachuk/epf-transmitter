# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.Тест_НастройкиСервисаСервер
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: ПараметрыПолучателя
	And I execute 1C:Enterprise script at server
	| 'Тест_НастройкиСервисаСервер.ПараметрыПолучателя(Context());' |

@OnServer
Scenario: ПараметрыПолучателяОтрицательныйТаймаутДоставкиФайла
	And I execute 1C:Enterprise script at server
	| 'Тест_НастройкиСервисаСервер.ПараметрыПолучателяОтрицательныйТаймаутДоставкиФайла(Context());' |

@OnServer
Scenario: CurrentSettings
	And I execute 1C:Enterprise script at server
	| 'Тест_НастройкиСервисаСервер.CurrentSettings(Context());' |