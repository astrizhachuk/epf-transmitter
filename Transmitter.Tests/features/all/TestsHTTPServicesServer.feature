# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsHTTPServicesServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: CreateMessage
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.CreateMessage(Context());' |

@OnServer
Scenario: SetBodyAsJSON
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.SetBodyAsJSON(Context());' |

@OnServer
Scenario: VersionGet200Ok
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.VersionGet200Ok(Context());' |

@OnServer
Scenario: GitLabStatusGet200OkEnabled
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.GitLabStatusGet200OkEnabled(Context());' |

@OnServer
Scenario: GitLabStatusGet200OkDisabled
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.GitLabStatusGet200OkDisabled(Context());' |

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