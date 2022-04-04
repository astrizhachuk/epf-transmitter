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
Scenario: CustomStatusGet200OkEnabled
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.CustomStatusGet200OkEnabled(Context());' |

@OnServer
Scenario: CustomStatusGet200OkDisabled
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.CustomStatusGet200OkDisabled(Context());' |

@OnServer
Scenario: EventsPostPushGitLab200Ok
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPushGitLab200Ok(Context());' |

@OnServer
Scenario: EventsPostPushGitLab400BadRequestWithoutToken
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPushGitLab400BadRequestWithoutToken(Context());' |

@OnServer
Scenario: EventsPostPushGitLab400BadRequestWithoutEvent
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPushGitLab400BadRequestWithoutEvent(Context());' |

@OnServer
Scenario: EventsPostPushGitLab400BadRequestWrongEventMethod
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPushGitLab400BadRequestWrongEventMethod(Context());' |

@OnServer
Scenario: EventsPostPushGitLab401Unauthorized
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPushGitLab401Unauthorized(Context());' |

@OnServer
Scenario: EventsPostPushGitLab404NotFound
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPushGitLab404NotFound(Context());' |

@OnServer
Scenario: EventsPostPushGitLab423Locked
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPushGitLab423Locked(Context());' |

@OnServer
Scenario: EventsPostPushGitLab500InternalServerErrorWrongBodyFormat
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPushGitLab500InternalServerErrorWrongBodyFormat(Context());' |

@OnServer
Scenario: EventsPostPushGitLab500InternalServerErrorCheckoutSHAMissed
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPRequests.EventsPostPushGitLab500InternalServerErrorCheckoutSHAMissed(Context());' |