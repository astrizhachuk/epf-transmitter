# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsReceiversServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: GetConnectionParams
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.GetConnectionParams(Context());' |

@OnServer
Scenario: SendFileErrorWithoutEndpointAndEvent
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFileErrorWithoutEndpointAndEvent(Context());' |

@OnServer
Scenario: SendFileErrorWithoutEndpoint
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFileErrorWithoutEndpoint(Context());' |

@OnServer
Scenario: SendFile4xxError
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFile4xxError(Context());' |

@OnServer
Scenario: SendFile200OkWithoutEventLogging
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFile200OkWithoutEventLogging(Context());' |

@OnServer
Scenario: SendFile200OkWithEventLogging
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFile200OkWithEventLogging(Context());' |

@OnServer
Scenario: SendFileBackgroundJobError
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFileBackgroundJobError(Context());' |

@OnServer
Scenario: SendFileBackgroundJob200OkMultipleFiles
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFileBackgroundJob200OkMultipleFiles(Context());' |