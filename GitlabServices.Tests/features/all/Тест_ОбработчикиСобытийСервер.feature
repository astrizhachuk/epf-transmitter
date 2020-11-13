# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.Тест_ОбработчикиСобытийСервер
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: НайтиПоСекретномуКлючуПустаяСсылкаЕслиПараметрЧисло
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.НайтиПоСекретномуКлючуПустаяСсылкаЕслиПараметрЧисло(Context());' |

@OnServer
Scenario: НайтиПоСекретномуКлючуПустаяСсылкаЕслиПараметрПустаяСтрока
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.НайтиПоСекретномуКлючуПустаяСсылкаЕслиПараметрПустаяСтрока(Context());' |

@OnServer
Scenario: НайтиПоСекретномуКлючуПустаяСсылкаЕслиПараметрНеопределено
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.НайтиПоСекретномуКлючуПустаяСсылкаЕслиПараметрНеопределено(Context());' |

@OnServer
Scenario: НайтиПоСекретномуКлючуПустаяСсылкаЕслиНеНайдено
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.НайтиПоСекретномуКлючуПустаяСсылкаЕслиНеНайдено(Context());' |

@OnServer
Scenario: НайтиПоСекретномуКлючу
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.НайтиПоСекретномуКлючу(Context());' |

@OnServer
Scenario: ЗагрузитьИсториюСобытий
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.ЗагрузитьИсториюСобытий(Context());' |

@OnServer
Scenario: SaveQueryData
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.SaveQueryData(Context());' |

@OnServer
Scenario: SaveQueryDataWriteError
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.SaveQueryDataWriteError(Context());' |

@OnServer
Scenario: SaveRemoteFilesWriteError
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.SaveRemoteFilesWriteError(Context());' |

@OnServer
Scenario: LoadRemoteFiles
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.LoadRemoteFiles(Context());' |

@OnServer
Scenario: LoadRemoteFilesNoData
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.LoadRemoteFilesNoData(Context());' |

@OnServer
Scenario: LoadQueryData
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.LoadQueryData(Context());' |

@OnServer
Scenario: LoadQueryDataNoData
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.LoadQueryDataNoData(Context());' |