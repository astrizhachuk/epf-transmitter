# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsEndpointsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: SendFileExceptionEmptyURL
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.SendFileExceptionEmptyURL(Context());' |

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
Scenario: GetStatusServiceURLInlineAuth
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetStatusServiceURLInlineAuth(Context());' |

@OnServer
Scenario: GetStatusServiceBaseURLInlineAuth
	And I execute 1C:Enterprise script at server
	| 'TestsEndpointsServer.GetStatusServiceBaseURLInlineAuth(Context());' |