# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.Тест_Маршрутизация
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: РаспределитьОтправляемыеДанныеПоМаршрутам
	And I execute 1C:Enterprise script at server
	| 'Тест_Маршрутизация.РаспределитьОтправляемыеДанныеПоМаршрутам(Context());' |

@OnServer
Scenario: AddRoutingFilesDescription
	And I execute 1C:Enterprise script at server
	| 'Тест_Маршрутизация.AddRoutingFilesDescription(Context());' |

@OnServer
Scenario: ДополнитьЗапросНастройкамиМаршрутизации
	And I execute 1C:Enterprise script at server
	| 'Тест_Маршрутизация.ДополнитьЗапросНастройкамиМаршрутизации(Context());' |