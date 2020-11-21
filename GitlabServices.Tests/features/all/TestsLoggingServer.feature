# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.TestsLoggingServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: InfoOnlyEvent
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.InfoOnlyEvent(Context());' |

@OnServer
Scenario: WarnOnlyEvent
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.WarnOnlyEvent(Context());' |

@OnServer
Scenario: ErrorOnlyEvent
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.ErrorOnlyEvent(Context());' |

@OnServer
Scenario: InfoEventWithObject
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.InfoEventWithObject(Context());' |

@OnServer
Scenario: WarnEventWithObject
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.WarnEventWithObject(Context());' |

@OnServer
Scenario: ErrorEventWithObject
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.ErrorEventWithObject(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponse200
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.InfoEventWithObjectAndHTTPResponse200(Context());' |

@OnServer
Scenario: орк
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.орк(Context());' |