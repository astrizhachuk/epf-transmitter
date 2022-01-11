# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsExternalRequestsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: GetCheckoutSHA
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetCheckoutSHA(Context());' |

@OnServer
Scenario: GetProjectOrRaise
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetProjectOrRaise(Context());' |

@OnServer
Scenario: GetProjectOrRaiseException
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetProjectOrRaiseException(Context());' |

@OnServer
Scenario: GetCommitsOrRaise
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetCommitsOrRaise(Context());' |

@OnServer
Scenario: GetCommitsOrRaiseException
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetCommitsOrRaiseException(Context());' |

@OnServer
Scenario: GetFromIB
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetFromIB(Context());' |

@OnServer
Scenario: GetFromIBNoData
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetFromIBNoData(Context());' |

@OnServer
Scenario: AppendRoutingSettingsNoData
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.AppendRoutingSettingsNoData(Context());' |

@OnServer
Scenario: AppendRoutingSettings
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.AppendRoutingSettings(Context());' |