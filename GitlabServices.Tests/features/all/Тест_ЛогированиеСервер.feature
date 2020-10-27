# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.Тест_ЛогированиеСервер
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: ТолькоСобытиеИнформация
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.ТолькоСобытиеИнформация(Context());' |

@OnServer
Scenario: ТолькоСобытиеПредупреждение
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.ТолькоСобытиеПредупреждение(Context());' |

@OnServer
Scenario: ТолькоСобытиеОшибка
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.ТолькоСобытиеОшибка(Context());' |

@OnServer
Scenario: СобытиеИнформацияСОбъектом
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.СобытиеИнформацияСОбъектом(Context());' |

@OnServer
Scenario: СобытиеПредупреждениеСОбъектом
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.СобытиеПредупреждениеСОбъектом(Context());' |

@OnServer
Scenario: СобытиеОшибкаСОбъектом
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.СобытиеОшибкаСОбъектом(Context());' |

@OnServer
Scenario: СобытиеИнформацияСОбъектомИHTTPСервисОтвет200
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.СобытиеИнформацияСОбъектомИHTTPСервисОтвет200(Context());' |

@OnServer
Scenario: СобытиеПредупреждениеСОбъектомИHTTPСервисОтвет200
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.СобытиеПредупреждениеСОбъектомИHTTPСервисОтвет200(Context());' |

@OnServer
Scenario: СобытиеОшибкаСОбъектомИHTTPСервисОтвет200
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.СобытиеОшибкаСОбъектомИHTTPСервисОтвет200(Context());' |

@OnServer
Scenario: СобытиеИнформацияСОбъектомИHTTPСервисОтвет400
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.СобытиеИнформацияСОбъектомИHTTPСервисОтвет400(Context());' |

@OnServer
Scenario: СобытиеПредупреждениеСОбъектомИHTTPСервисОтвет400
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.СобытиеПредупреждениеСОбъектомИHTTPСервисОтвет400(Context());' |

@OnServer
Scenario: СобытиеОшибкаСОбъектомИHTTPСервисОтвет400
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.СобытиеОшибкаСОбъектомИHTTPСервисОтвет400(Context());' |

@OnServer
Scenario: СобытиеИнформацияHTTPСервисОтветТелоОтвета200
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.СобытиеИнформацияHTTPСервисОтветТелоОтвета200(Context());' |

@OnServer
Scenario: СобытиеИнформацияHTTPСервисОтветТелоОтвета400
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.СобытиеИнформацияHTTPСервисОтветТелоОтвета400(Context());' |

@OnServer
Scenario: СобытиеИнформацияHTTPСервисОтветТелоОтвета403
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.СобытиеИнформацияHTTPСервисОтветТелоОтвета403(Context());' |

@OnServer
Scenario: СобытиеИнформацияHTTPСервисОтветТелоОтвета423
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.СобытиеИнформацияHTTPСервисОтветТелоОтвета423(Context());' |

@OnServer
Scenario: ДополнитьСообщениеПрефиксом
	And I execute 1C:Enterprise script at server
	| 'Тест_ЛогированиеСервер.ДополнитьСообщениеПрефиксом(Context());' |