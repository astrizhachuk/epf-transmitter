# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.TestsLoggingServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: ТолькоСобытиеИнформация
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.ТолькоСобытиеИнформация(Context());' |

@OnServer
Scenario: ТолькоСобытиеПредупреждение
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.ТолькоСобытиеПредупреждение(Context());' |

@OnServer
Scenario: ТолькоСобытиеОшибка
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.ТолькоСобытиеОшибка(Context());' |

@OnServer
Scenario: СобытиеИнформацияСОбъектом
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.СобытиеИнформацияСОбъектом(Context());' |

@OnServer
Scenario: СобытиеПредупреждениеСОбъектом
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.СобытиеПредупреждениеСОбъектом(Context());' |

@OnServer
Scenario: СобытиеОшибкаСОбъектом
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.СобытиеОшибкаСОбъектом(Context());' |

@OnServer
Scenario: СобытиеИнформацияСОбъектомИHTTPСервисОтвет200
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.СобытиеИнформацияСОбъектомИHTTPСервисОтвет200(Context());' |

@OnServer
Scenario: СобытиеПредупреждениеСОбъектомИHTTPСервисОтвет200
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.СобытиеПредупреждениеСОбъектомИHTTPСервисОтвет200(Context());' |

@OnServer
Scenario: СобытиеОшибкаСОбъектомИHTTPСервисОтвет200
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.СобытиеОшибкаСОбъектомИHTTPСервисОтвет200(Context());' |

@OnServer
Scenario: СобытиеИнформацияСОбъектомИHTTPСервисОтвет400
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.СобытиеИнформацияСОбъектомИHTTPСервисОтвет400(Context());' |

@OnServer
Scenario: СобытиеПредупреждениеСОбъектомИHTTPСервисОтвет400
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.СобытиеПредупреждениеСОбъектомИHTTPСервисОтвет400(Context());' |

@OnServer
Scenario: СобытиеОшибкаСОбъектомИHTTPСервисОтвет400
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.СобытиеОшибкаСОбъектомИHTTPСервисОтвет400(Context());' |

@OnServer
Scenario: ДополнитьСообщениеПрефиксом
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.ДополнитьСообщениеПрефиксом(Context());' |