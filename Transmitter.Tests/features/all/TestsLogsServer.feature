# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsLogsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

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
Scenario: InfoEventWithObjectAndHTTPResponse200
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoEventWithObjectAndHTTPResponse200(Context());' |

@OnServer
Scenario: WarnEventWithObjectAndHTTPResponse200
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.WarnEventWithObjectAndHTTPResponse200(Context());' |

@OnServer
Scenario: ErrorEventWithObjectAndHTTPResponse200
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.ErrorEventWithObjectAndHTTPResponse200(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponse400
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoEventWithObjectAndHTTPResponse400(Context());' |

@OnServer
Scenario: WarnEventWithObjectAndHTTPResponse400
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.WarnEventWithObjectAndHTTPResponse400(Context());' |

@OnServer
Scenario: ErrorEventWithObjectAndHTTPResponse400
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.ErrorEventWithObjectAndHTTPResponse400(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody200
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoEventWithObjectAndHTTPResponseWithBody200(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody400
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoEventWithObjectAndHTTPResponseWithBody400(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody403
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoEventWithObjectAndHTTPResponseWithBody403(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody423
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.InfoEventWithObjectAndHTTPResponseWithBody423(Context());' |

@OnServer
Scenario: ДополнитьСообщениеПрефиксом
	And I execute 1C:Enterprise script at server
	| 'TestsLogsServer.ДополнитьСообщениеПрефиксом(Context());' |