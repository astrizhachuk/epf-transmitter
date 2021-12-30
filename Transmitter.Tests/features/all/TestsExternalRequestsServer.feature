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
Scenario: GetRequestBody
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetRequestBody(Context());' |

@OnServer
Scenario: GetRequestBodyNoData
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetRequestBodyNoData(Context());' |

@OnServer
Scenario: AppendRoutingSettingsNoData
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.AppendRoutingSettingsNoData(Context());' |

@OnServer
Scenario: AppendRoutingSettings
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.AppendRoutingSettings(Context());' |

@OnServer
Scenario: Dump
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.Dump(Context());' |

@OnServer
Scenario: DumpException
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.DumpException(Context());' |