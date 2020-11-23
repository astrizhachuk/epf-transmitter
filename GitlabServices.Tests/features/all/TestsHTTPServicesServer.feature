# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.TestsHTTPServicesServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: ResponseTemplate
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.ResponseTemplate(Context());' |

@OnServer
Scenario: ServiceDescriptionByNameServiceNotExists
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.ServiceDescriptionByNameServiceNotExists(Context());' |

@OnServer
Scenario: ServiceDescriptionByNameServiceExists
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.ServiceDescriptionByNameServiceExists(Context());' |

@OnServer
Scenario: ServiceDescriptionByURLBadURL
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.ServiceDescriptionByURLBadURL(Context());' |

@OnServer
Scenario: ServiceDescriptionByURLEmptyURL
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.ServiceDescriptionByURLEmptyURL(Context());' |

@OnServer
Scenario: ServiceDescriptionByURLURLBadType
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.ServiceDescriptionByURLURLBadType(Context());' |

@OnServer
Scenario: ServiceDescriptionByURLBadServiceName
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.ServiceDescriptionByURLBadServiceName(Context());' |

@OnServer
Scenario: ServiceDescriptionByURLDeserializationError
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.ServiceDescriptionByURLDeserializationError(Context());' |

@OnServer
Scenario: ServiceDescriptionByURL404NotFound
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.ServiceDescriptionByURL404NotFound(Context());' |

@OnServer
Scenario: ServiceDescriptionByURL
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.ServiceDescriptionByURL(Context());' |

@OnServer
Scenario: ServicesGET
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.ServicesGET(Context());' |

@OnServer
Scenario: WebhooksPOST
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.WebhooksPOST(Context());' |

@OnServer
Scenario: WebhooksPOST403Forbidden
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.WebhooksPOST403Forbidden(Context());' |

@OnServer
Scenario: WebhooksPOST423Locked
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.WebhooksPOST423Locked(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestXGitlabEvent
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.WebhooksPOST400BadRequestXGitlabEvent(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestBadURLEpf
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.WebhooksPOST400BadRequestBadURLEpf(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestBadURLPush
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.WebhooksPOST400BadRequestBadURLPush(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestCheckoutSHA
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.WebhooksPOST400BadRequestCheckoutSHA(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestProject
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.WebhooksPOST400BadRequestProject(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestProjectWebURL
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.WebhooksPOST400BadRequestProjectWebURL(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestCommits
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.WebhooksPOST400BadRequestCommits(Context());' |

@OnServer
Scenario: WebhooksPOST400BadRequestCommitsId
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.WebhooksPOST400BadRequestCommitsId(Context());' |