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
Scenario: GetEndpointParams
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetEndpointParams(Context());' |

@OnServer
Scenario: SetURL
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SetURL(Context());' |

@OnServer
Scenario: SendFileErrorWithoutEndpoint
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFileErrorWithoutEndpoint(Context());' |

@OnServer
Scenario: SendFile4xxError
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFile4xxError(Context());' |

@OnServer
Scenario: SendFile200Ok
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFile200Ok(Context());' |

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
Scenario: GetServiceStatusException
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetServiceStatusException(Context());' |

@OnServer
Scenario: GetServiceStatusURL
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetServiceStatusURL(Context());' |

@OnServer
Scenario: GetServiceStatusConcat
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetServiceStatusConcat(Context());' |

@OnServer
Scenario: GetServiceStatusURLInlineAuth
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetServiceStatusURLInlineAuth(Context());' |

@OnServer
Scenario: GetServiceStatusBaseURLInlineAuth
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetServiceStatusBaseURLInlineAuth(Context());' |

@OnServer
Scenario: GetServiceStatusGlobalSettingsFailedAuth
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetServiceStatusGlobalSettingsFailedAuth(Context());' |

@OnServer
Scenario: GetServiceStatusGlobalSettings
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetServiceStatusGlobalSettings(Context());' |