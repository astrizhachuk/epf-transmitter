# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsEndpointsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: Connector
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.Connector(Context());' |

@OnServer
Scenario: SendFileExceptionEmptyURL
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFileExceptionEmptyURL(Context());' |

@OnServer
Scenario: SendFile4xxError
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFile4xxError(Context());' |

@OnServer
Scenario: SendFile200OkNoEndpoint
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFile200OkNoEndpoint(Context());' |

@OnServer
Scenario: SendFileExceptionDublicateEndpointBaseURL
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFileExceptionDublicateEndpointBaseURL(Context());' |

@OnServer
Scenario: SendFile200OkEndpointBaseURL
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFile200OkEndpointBaseURL(Context());' |

@OnServer
Scenario: BackgroundSendFilesEmptyFiles
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.BackgroundSendFilesEmptyFiles(Context());' |

@OnServer
Scenario: BackgroundSendFilesActiveJob
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.BackgroundSendFilesActiveJob(Context());' |

@OnServer
Scenario: BackgroundSendFilesJobError
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.BackgroundSendFilesJobError(Context());' |

@OnServer
Scenario: BackgroundSendFilesMixedResult
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.BackgroundSendFilesMixedResult(Context());' |

@OnServer
Scenario: GetStatusServiceException
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetStatusServiceException(Context());' |

@OnServer
Scenario: GetStatusServiceURL
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetStatusServiceURL(Context());' |

@OnServer
Scenario: GetStatusServiceConcat
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetStatusServiceConcat(Context());' |

@OnServer
Scenario: GetStatusServiceURLInlineAuth
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetStatusServiceURLInlineAuth(Context());' |

@OnServer
Scenario: GetStatusServiceBaseURLInlineAuth
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetStatusServiceBaseURLInlineAuth(Context());' |

@OnServer
Scenario: GetStatusServiceGlobalSettingsFailedAuth
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetStatusServiceGlobalSettingsFailedAuth(Context());' |

@OnServer
Scenario: GetStatusServiceGlobalSettings
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetStatusServiceGlobalSettings(Context());' |