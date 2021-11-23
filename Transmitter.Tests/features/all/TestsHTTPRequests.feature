# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsHTTPRequests
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: VersionGet200Ok
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.VersionGet200Ok(Context());' |

@OnServer
Scenario: GitLabStatusGet200OkEnabled
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.GitLabStatusGet200OkEnabled(Context());' |

@OnServer
Scenario: GitLabStatusGet200OkDisabled
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.GitLabStatusGet200OkDisabled(Context());' |

@OnServer
Scenario: EventsPostPush200Ok
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPush200Ok(Context());' |

@OnServer
Scenario: EventsPostPush400BadRequestWithoutToken
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPush400BadRequestWithoutToken(Context());' |

@OnServer
Scenario: EventsPostPush400BadRequestWithoutEvent
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPush400BadRequestWithoutEvent(Context());' |

@OnServer
Scenario: EventsPostPush400BadRequestWrongEventMethod
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPush400BadRequestWrongEventMethod(Context());' |

@OnServer
Scenario: EventsPostPush401Unauthorized
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPush401Unauthorized(Context());' |

@OnServer
Scenario: EventsPostPush401UnauthorizedWithoutWebhook
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPush401UnauthorizedWithoutWebhook(Context());' |

@OnServer
Scenario: EventsPostPush423Locked
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPush423Locked(Context());' |

@OnServer
Scenario: EventsPostPush500InternalServerErrorWrongData
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPush500InternalServerErrorWrongData(Context());' |