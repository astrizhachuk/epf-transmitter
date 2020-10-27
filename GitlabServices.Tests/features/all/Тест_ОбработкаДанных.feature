# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.Тест_ОбработкаДанных
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: НачатьЗапускОбработкиДанных
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработкаДанных.НачатьЗапускОбработкиДанных(Context());' |

@OnServer
Scenario: НачатьЗапускОбработкиДанныхРучнойЗапуск
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработкаДанных.НачатьЗапускОбработкиДанныхРучнойЗапуск(Context());' |

@OnServer
Scenario: НачатьЗапускОбработкиДанныхWebhook
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработкаДанных.НачатьЗапускОбработкиДанныхWebhook(Context());' |

@OnServer
Scenario: НачатьЗапускОбработкиДанныхWebhookОтсутствуетCheckoutSHA
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработкаДанных.НачатьЗапускОбработкиДанныхWebhookОтсутствуетCheckoutSHA(Context());' |

@OnServer
Scenario: НачатьЗапускОбработкиДанныхWebhookОшибочныйТипДанных
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработкаДанных.НачатьЗапускОбработкиДанныхWebhookОшибочныйТипДанных(Context());' |

@OnServer
Scenario: НачатьЗапускОбработкиДанныхЕстьАктивноеЗадание
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработкаДанных.НачатьЗапускОбработкиДанныхЕстьАктивноеЗадание(Context());' |

@OnServer
Scenario: НачатьЗапускОбработкиДанныхОшибкаЗапускаЗадания
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработкаДанных.НачатьЗапускОбработкиДанныхОшибкаЗапускаЗадания(Context());' |

@OnServer
Scenario: НачатьЗапускОбработкиДанныхДанныеЗапроса
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработкаДанных.НачатьЗапускОбработкиДанныхДанныеЗапроса(Context());' |

@OnServer
Scenario: НачатьЗапускОбработкиДанныхОтправляемыеДанныеПусто
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработкаДанных.НачатьЗапускОбработкиДанныхОтправляемыеДанныеПусто(Context());' |

@OnServer
Scenario: НачатьЗапускОбработкиДанныхРучнойЗапускНетЗаписанныхДанных
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработкаДанных.НачатьЗапускОбработкиДанныхРучнойЗапускНетЗаписанныхДанных(Context());' |

@OnServer
Scenario: НачатьЗапускОбработкиДанныхРучнойЗапускЕстьЗаписанныеДанные
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработкаДанных.НачатьЗапускОбработкиДанныхРучнойЗапускЕстьЗаписанныеДанные(Context());' |

@OnServer
Scenario: НачатьЗапускОбработкиДанныхЕстьАктивноеЗаданиеЗапускаФайла
	And I execute 1C:Enterprise script at server
	| 'Тест_ОбработкаДанных.НачатьЗапускОбработкиДанныхЕстьАктивноеЗаданиеЗапускаФайла(Context());' |