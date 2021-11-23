# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsLogServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: InfoOnlyEvent
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.InfoOnlyEvent(Context());' |

@OnServer
Scenario: WarnOnlyEvent
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.WarnOnlyEvent(Context());' |

@OnServer
Scenario: ErrorOnlyEvent
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.ErrorOnlyEvent(Context());' |

@OnServer
Scenario: InfoEventWithObject
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.InfoEventWithObject(Context());' |

@OnServer
Scenario: WarnEventWithObject
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.WarnEventWithObject(Context());' |

@OnServer
Scenario: ErrorEventWithObject
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.ErrorEventWithObject(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponse200
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.InfoEventWithObjectAndHTTPResponse200(Context());' |

@OnServer
Scenario: WarnEventWithObjectAndHTTPResponse200
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.WarnEventWithObjectAndHTTPResponse200(Context());' |

@OnServer
Scenario: ErrorEventWithObjectAndHTTPResponse200
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.ErrorEventWithObjectAndHTTPResponse200(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponse400
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.InfoEventWithObjectAndHTTPResponse400(Context());' |

@OnServer
Scenario: WarnEventWithObjectAndHTTPResponse400
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.WarnEventWithObjectAndHTTPResponse400(Context());' |

@OnServer
Scenario: ErrorEventWithObjectAndHTTPResponse400
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.ErrorEventWithObjectAndHTTPResponse400(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody200
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.InfoEventWithObjectAndHTTPResponseWithBody200(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody400
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.InfoEventWithObjectAndHTTPResponseWithBody400(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody403
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.InfoEventWithObjectAndHTTPResponseWithBody403(Context());' |

@OnServer
Scenario: InfoEventWithObjectAndHTTPResponseWithBody423
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.InfoEventWithObjectAndHTTPResponseWithBody423(Context());' |

@OnServer
Scenario: ДополнитьСообщениеПрефиксом
	And I execute 1C:Enterprise script at server
	| 'TestsLogServer.ДополнитьСообщениеПрефиксом(Context());' |