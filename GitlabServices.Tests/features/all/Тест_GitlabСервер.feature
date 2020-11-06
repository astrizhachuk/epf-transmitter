# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.Тест_GitlabСервер
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: ConnectionParams
	And I execute 1C:Enterprise script at server
	| 'Тест_GitlabСервер.ConnectionParams(Context());' |

@OnServer
Scenario: ПолучитьФайлФэйкURL
	And I execute 1C:Enterprise script at server
	| 'Тест_GitlabСервер.ПолучитьФайлФэйкURL(Context());' |

@OnServer
Scenario: ПолучитьФайл404NotFound
	And I execute 1C:Enterprise script at server
	| 'Тест_GitlabСервер.ПолучитьФайл404NotFound(Context());' |

@OnServer
Scenario: ПолучитьФайл401Unauthorized
	And I execute 1C:Enterprise script at server
	| 'Тест_GitlabСервер.ПолучитьФайл401Unauthorized(Context());' |

@OnServer
Scenario: ПолучитьФайлПустой
	And I execute 1C:Enterprise script at server
	| 'Тест_GitlabСервер.ПолучитьФайлПустой(Context());' |

@OnServer
Scenario: ПолучитьФайл200Ok
	And I execute 1C:Enterprise script at server
	| 'Тест_GitlabСервер.ПолучитьФайл200Ok(Context());' |

@OnServer
Scenario: ПолучитьФайлы
	And I execute 1C:Enterprise script at server
	| 'Тест_GitlabСервер.ПолучитьФайлы(Context());' |

@OnServer
Scenario: ПолучитьФайлыКОтправкеПоДаннымЗапроса
	And I execute 1C:Enterprise script at server
	| 'Тест_GitlabСервер.ПолучитьФайлыКОтправкеПоДаннымЗапроса(Context());' |

@OnServer
Scenario: GetMergeRequestsByQueryData
	And I execute 1C:Enterprise script at server
	| 'Тест_GitlabСервер.GetMergeRequestsByQueryData(Context());' |

@OnServer
Scenario: ОписаниеФайлов
	And I execute 1C:Enterprise script at server
	| 'Тест_GitlabСервер.ОписаниеФайлов(Context());' |

@OnServer
Scenario: RAWFilePath
	And I execute 1C:Enterprise script at server
	| 'Тест_GitlabСервер.RAWFilePath(Context());' |

@OnServer
Scenario: ПереченьОперацийНадФайлами
	And I execute 1C:Enterprise script at server
	| 'Тест_GitlabСервер.ПереченьОперацийНадФайлами(Context());' |