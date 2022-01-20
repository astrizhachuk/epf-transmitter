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
Scenario: GetCommitOrRaise
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetCommitOrRaise(Context());' |

@OnServer
Scenario: GetCommitOrRaiseExceptionCommits
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetCommitOrRaiseExceptionCommits(Context());' |

@OnServer
Scenario: GetCommitOrRaiseExceptionCommit
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetCommitOrRaiseExceptionCommit(Context());' |

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

@OnServer
Scenario: AppendCustomRoutingSettingsNoData
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.AppendCustomRoutingSettingsNoData(Context());' |

@OnServer
Scenario: AppendCustomRoutingSettingsCommitNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.AppendCustomRoutingSettingsCommitNotFound(Context());' |

@OnServer
Scenario: AppendCustomRoutingSettings
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.AppendCustomRoutingSettings(Context());' |

@OnServer
Scenario: RemoveCustomRoutingSettingsNoData
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.RemoveCustomRoutingSettingsNoData(Context());' |

@OnServer
Scenario: RemoveCustomRoutingSettingsCommitNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.RemoveCustomRoutingSettingsCommitNotFound(Context());' |

@OnServer
Scenario: RemoveCustomRoutingSettingsNoCustomSettings
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.RemoveCustomRoutingSettingsNoCustomSettings(Context());' |

@OnServer
Scenario: RemoveCustomRoutingSettings
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.RemoveCustomRoutingSettings(Context());' |

@OnServer
Scenario: GetCustomSettingsJSONNoCustomSettings
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetCustomSettingsJSONNoCustomSettings(Context());' |

@OnServer
Scenario: GetCustomSettingsJSONNoJSON
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetCustomSettingsJSONNoJSON(Context());' |

@OnServer
Scenario: GetCustomSettingsJSON
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetCustomSettingsJSON(Context());' |

@OnServer
Scenario: GetDefaultSettingsJSONNoSettings
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetDefaultSettingsJSONNoSettings(Context());' |

@OnServer
Scenario: GetDefaultSettingsJSONNoJSON
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetDefaultSettingsJSONNoJSON(Context());' |

@OnServer
Scenario: GetDefaultSettingsJSON
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestsServer.GetDefaultSettingsJSON(Context());' |