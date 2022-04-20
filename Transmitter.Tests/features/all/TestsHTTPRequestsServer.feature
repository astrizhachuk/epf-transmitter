# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsHTTPRequestsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: VersionGet200Ok
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.VersionGet200Ok(Context());' |

@OnServer
Scenario: GitLabStatusGet200OkEnabled
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.GitLabStatusGet200OkEnabled(Context());' |

@OnServer
Scenario: GitLabStatusGet200OkDisabled
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.GitLabStatusGet200OkDisabled(Context());' |

@OnServer
Scenario: CustomStatusGet200OkEnabled
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.CustomStatusGet200OkEnabled(Context());' |

@OnServer
Scenario: CustomStatusGet200OkDisabled
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.CustomStatusGet200OkDisabled(Context());' |

@OnServer
Scenario: EventsPostPushGitLab200Ok
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.EventsPostPushGitLab200Ok(Context());' |

@OnServer
Scenario: EventsPostPushGitLab400BadRequestWithoutToken
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.EventsPostPushGitLab400BadRequestWithoutToken(Context());' |

@OnServer
Scenario: EventsPostPushGitLab400BadRequestWithoutEvent
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.EventsPostPushGitLab400BadRequestWithoutEvent(Context());' |

@OnServer
Scenario: EventsPostPushGitLab400BadRequestWrongEventMethod
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.EventsPostPushGitLab400BadRequestWrongEventMethod(Context());' |

@OnServer
Scenario: EventsPostPushGitLab401Unauthorized
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.EventsPostPushGitLab401Unauthorized(Context());' |

@OnServer
Scenario: EventsPostPushGitLab404NotFound
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.EventsPostPushGitLab404NotFound(Context());' |

@OnServer
Scenario: EventsPostPushGitLab423Locked
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.EventsPostPushGitLab423Locked(Context());' |

@OnServer
Scenario: EventsPostPushGitLab500InternalServerErrorWrongBodyFormat
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.EventsPostPushGitLab500InternalServerErrorWrongBodyFormat(Context());' |

@OnServer
Scenario: EventsPostPushGitLab500InternalServerErrorCheckoutSHAMissed
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequestsServer.EventsPostPushGitLab500InternalServerErrorCheckoutSHAMissed(Context());' |