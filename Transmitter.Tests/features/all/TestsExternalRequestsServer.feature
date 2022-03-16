# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsExternalRequestsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: CreateSourceTypeException
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.CreateSourceTypeException(Context());' |

@OnServer
Scenario: CreateFromJSONNoTypeException
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.CreateFromJSONNoTypeException(Context());' |

@OnServer
Scenario: CreateFromGitLabJSON
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.CreateFromGitLabJSON(Context());' |

@OnServer
Scenario: CreateFromInstance
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.CreateFromInstance(Context());' |

@OnServer
Scenario: GetObjectFromIB
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetObjectFromIB(Context());' |

@OnServer
Scenario: GetObjectFromIBNoData
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetObjectFromIBNoData(Context());' |

@OnServer
Scenario: SaveObject
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.SaveObject(Context());' |