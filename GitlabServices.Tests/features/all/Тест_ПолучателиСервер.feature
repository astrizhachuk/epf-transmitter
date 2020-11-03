# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.Тест_ПолучателиСервер
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: ПараметрыПолучателя
	And I execute 1C:Enterprise script at server
	| 'Тест_ПолучателиСервер.ПараметрыПолучателя(Context());' |

@OnServer
Scenario: ПараметрыПолучателяОтрицательныйТаймаутДоставкиФайла
	And I execute 1C:Enterprise script at server
	| 'Тест_ПолучателиСервер.ПараметрыПолучателяОтрицательныйТаймаутДоставкиФайла(Context());' |

@OnServer
Scenario: ПередачаДвоичныхДанныхБезПараметровДоставкиОтсутствуютПараметрыСобытия
	And I execute 1C:Enterprise script at server
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхБезПараметровДоставкиОтсутствуютПараметрыСобытия(Context());' |

@OnServer
Scenario: ПередачаДвоичныхДанныхБезПараметровДоставкиЕстьПараметрыСобытия
	And I execute 1C:Enterprise script at server
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхБезПараметровДоставкиЕстьПараметрыСобытия(Context());' |

@OnServer
Scenario: ПередачаДвоичныхДанныхОшибка403ForbiddenОтсутствуютПараметрыСобытия
	And I execute 1C:Enterprise script at server
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхОшибка403ForbiddenОтсутствуютПараметрыСобытия(Context());' |

@OnServer
Scenario: ПередачаДвоичныхДанныхОшибка403ForbiddenЕстьПараметрыСобытия
	And I execute 1C:Enterprise script at server
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхОшибка403ForbiddenЕстьПараметрыСобытия(Context());' |

@OnServer
Scenario: ПередачаДвоичныхДанных200OkОтсутствуютПараметрыСобытия
	And I execute 1C:Enterprise script at server
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанных200OkОтсутствуютПараметрыСобытия(Context());' |

@OnServer
Scenario: ПередачаДвоичныхДанных200OkЕстьПараметрыСобытия
	And I execute 1C:Enterprise script at server
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанных200OkЕстьПараметрыСобытия(Context());' |

@OnServer
Scenario: ПередачаДвоичныхДанныхБезПараметровДоставкиВФоне
	And I execute 1C:Enterprise script at server
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхБезПараметровДоставкиВФоне(Context());' |

@OnServer
Scenario: ПередачаДвоичныхДанныхВФонеОдинФайл200OkЕстьПараметрыСобытия
	And I execute 1C:Enterprise script at server
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхВФонеОдинФайл200OkЕстьПараметрыСобытия(Context());' |

@OnServer
Scenario: ПередачаДвоичныхДанныхВФонеТриФайла200OkЕстьПараметрыСобытия
	And I execute 1C:Enterprise script at server
	| 'Тест_ПолучателиСервер.ПередачаДвоичныхДанныхВФонеТриФайла200OkЕстьПараметрыСобытия(Context());' |