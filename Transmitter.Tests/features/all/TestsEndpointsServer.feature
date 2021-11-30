# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsEndpointsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: GetConnectionParams
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetConnectionParams(Context());' |

@OnServer
Scenario: SetURL
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SetURL(Context());' |

@OnServer
Scenario: SendFileErrorWithoutEndpointAndOptions
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFileErrorWithoutEndpointAndOptions(Context());' |

@OnServer
Scenario: SendFileErrorWithoutEndpoint
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFileErrorWithoutEndpoint(Context());' |

@OnServer
Scenario: SendFile4xxError
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFile4xxError(Context());' |

@OnServer
Scenario: SendFile200OkWithoutEventLog
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFile200OkWithoutEventLog(Context());' |

@OnServer
Scenario: SendFile200OkWithEventLog
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFile200OkWithEventLog(Context());' |

@OnServer
Scenario: SendFileBackgroundJobError
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFileBackgroundJobError(Context());' |

@OnServer
Scenario: SendFileBackgroundJob200OkMultipleFiles
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFileBackgroundJob200OkMultipleFiles(Context());' |