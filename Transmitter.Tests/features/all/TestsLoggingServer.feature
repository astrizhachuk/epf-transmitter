# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsLoggingServer
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
Scenario: WarnEventWithObjectAndHTTPResponse200
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.WarnEventWithObjectAndHTTPResponse200(Context());' |

@OnServer
Scenario: ErrorEventWithObjectAndHTTPResponse200
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.ErrorEventWithObjectAndHTTPResponse200(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponse400
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.InfoEventWithObjectAndHTTPResponse400(Context());' |

@OnServer
Scenario: WarnEventWithObjectAndHTTPResponse400
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.WarnEventWithObjectAndHTTPResponse400(Context());' |

@OnServer
Scenario: ErrorEventWithObjectAndHTTPResponse400
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.ErrorEventWithObjectAndHTTPResponse400(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody200
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.InfoEventWithObjectAndHTTPResponseWithBody200(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody400
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.InfoEventWithObjectAndHTTPResponseWithBody400(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody403
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.InfoEventWithObjectAndHTTPResponseWithBody403(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody423
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.InfoEventWithObjectAndHTTPResponseWithBody423(Context());' |

@OnServer
Scenario: ДополнитьСообщениеПрефиксом
	And I execute 1C:Enterprise script at server
	| 'TestsLoggingServer.ДополнитьСообщениеПрефиксом(Context());' |