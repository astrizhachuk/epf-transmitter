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
Scenario: СохранитьДанныеЗапросаУспешно
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.СохранитьДанныеЗапросаУспешно(Context());' |

@OnServer
Scenario: СохранитьДанныеЗапросаЗаписьОшибкаЗаписи
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.СохранитьДанныеЗапросаЗаписьОшибкаЗаписи(Context());' |

@OnServer
Scenario: СохранитьВнешниеФайлыЗаписьОшибкаЗаписи
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.СохранитьВнешниеФайлыЗаписьОшибкаЗаписи(Context());' |

@OnServer
Scenario: ЗагрузитьВнешниеФайлы
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.ЗагрузитьВнешниеФайлы(Context());' |

@OnServer
Scenario: ЗагрузитьВнешниеФайлыОтсутствуютДанные
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.ЗагрузитьВнешниеФайлыОтсутствуютДанные(Context());' |

@OnServer
Scenario: ЗагрузитьДанныеЗапроса
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.ЗагрузитьДанныеЗапроса(Context());' |

@OnServer
Scenario: ЗагрузитьДанныеЗапросаОтсутствуютДанные
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработчикиСобытийСервер.ЗагрузитьДанныеЗапросаОтсутствуютДанные(Context());' |