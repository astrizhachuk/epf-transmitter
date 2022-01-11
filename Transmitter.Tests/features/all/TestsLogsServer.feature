# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsLogsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: Events
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.Events(Context());' |

@OnServer
Scenario: Messages
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.Messages(Context());' |

@OnServer
Scenario: InfoOnlyEvent
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoOnlyEvent(Context());' |

@OnServer
Scenario: WarnOnlyEvent
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.WarnOnlyEvent(Context());' |

@OnServer
Scenario: ErrorOnlyEvent
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.ErrorOnlyEvent(Context());' |

@OnServer
Scenario: InfoWithPrefix
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoWithPrefix(Context());' |

@OnServer
Scenario: WarnWithPrefix
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.WarnWithPrefix(Context());' |

@OnServer
Scenario: ErrorWithPrefix
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.ErrorWithPrefix(Context());' |

@OnServer
Scenario: InfoEventWithObject
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoEventWithObject(Context());' |

@OnServer
Scenario: WarnEventWithObject
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.WarnEventWithObject(Context());' |

@OnServer
Scenario: ErrorEventWithObject
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.ErrorEventWithObject(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponse200WithoutBody
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoEventWithObjectAndHTTPResponse200WithoutBody(Context());' |

@OnServer
Scenario: WarnEventWithObjectAndHTTPResponse200WithoutBody
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.WarnEventWithObjectAndHTTPResponse200WithoutBody(Context());' |

@OnServer
Scenario: ErrorEventWithObjectAndHTTPResponse200WithoutBody
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.ErrorEventWithObjectAndHTTPResponse200WithoutBody(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponse400WithBody
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoEventWithObjectAndHTTPResponse400WithBody(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponse401WithoutBody
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoEventWithObjectAndHTTPResponse401WithoutBody(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponse404WithoutBody
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoEventWithObjectAndHTTPResponse404WithoutBody(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponse423WithoutBody
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoEventWithObjectAndHTTPResponse423WithoutBody(Context());' |

@OnServer
Scenario: ErrorEventWithObjectAndHTTPResponse500WithBody
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.ErrorEventWithObjectAndHTTPResponse500WithBody(Context());' |