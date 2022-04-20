# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsHTTPServicesServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: FindHeaderLower
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.FindHeaderLower(Context());' |

@OnServer
Scenario: FindHeaderUpper
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.FindHeaderUpper(Context());' |

@OnServer
Scenario: FindHeader
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.FindHeader(Context());' |

@OnServer
Scenario: CreateMessage
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.CreateMessage(Context());' |

@OnServer
Scenario: SetBodyAsJSON
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.SetBodyAsJSON(Context());' |