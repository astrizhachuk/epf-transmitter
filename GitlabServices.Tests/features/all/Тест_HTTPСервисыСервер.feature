# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.Тест_HTTPСервисыСервер
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: СтруктураОтвета
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.СтруктураОтвета(Context());' |

@OnServer
Scenario: ОписаниеНеСуществующегоСервиса
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.ОписаниеНеСуществующегоСервиса(Context());' |

@OnServer
Scenario: ОписаниеСуществующегоСервиса
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.ОписаниеСуществующегоСервиса(Context());' |

@OnServer
Scenario: ОписаниеСервисаURLBadURL
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.ОписаниеСервисаURLBadURL(Context());' |

@OnServer
Scenario: ОписаниеСервисаURLПустойURL
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.ОписаниеСервисаURLПустойURL(Context());' |

@OnServer
Scenario: ОписаниеСервисаURLНеверныйТип
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.ОписаниеСервисаURLНеверныйТип(Context());' |

@OnServer
Scenario: ОписаниеСервисаURLНеверноеИмяСервиса
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.ОписаниеСервисаURLНеверноеИмяСервиса(Context());' |

@OnServer
Scenario: ОписаниеСервисаURLОшибкаПреобразования
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.ОписаниеСервисаURLОшибкаПреобразования(Context());' |

@OnServer
Scenario: ОписаниеСервисаURL404NotFound
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.ОписаниеСервисаURL404NotFound(Context());' |

@OnServer
Scenario: ОписаниеСервисаURL
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.ОписаниеСервисаURL(Context());' |

@OnServer
Scenario: ServicesGET
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.ServicesGET(Context());' |

@OnServer
Scenario: WebhooksPOST
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.WebhooksPOST(Context());' |

@OnServer
Scenario: WebhooksPOST403Forbidden
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.WebhooksPOST403Forbidden(Context());' |

@OnServer
Scenario: WebhooksPOST423Locked
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.WebhooksPOST423Locked(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestXGitlabEvent
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.WebhooksPOST400BadRequestXGitlabEvent(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestBadURLEpf
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.WebhooksPOST400BadRequestBadURLEpf(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestBadURLPush
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.WebhooksPOST400BadRequestBadURLPush(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestCheckoutSHA
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.WebhooksPOST400BadRequestCheckoutSHA(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestProject
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.WebhooksPOST400BadRequestProject(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestProjectWebURL
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.WebhooksPOST400BadRequestProjectWebURL(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestCommits
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.WebhooksPOST400BadRequestCommits(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestCommitsId
	And I execute 1C:Enterprise script at server
	| 'Тест_HTTPСервисыСервер.WebhooksPOST400BadRequestCommitsId(Context());' |