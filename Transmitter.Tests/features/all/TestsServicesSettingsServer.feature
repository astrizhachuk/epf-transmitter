# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsServicesSettingsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: Settings
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.Settings(Context());' |

@OnServer
Scenario: CurrentSettings
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.CurrentSettings(Context());' |

@OnServer
Scenario: SetCurrentSettings
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.SetCurrentSettings(Context());' |

@OnServer
Scenario: IsHandleCustomRequestsTrue
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.IsHandleCustomRequestsTrue(Context());' |

@OnServer
Scenario: IsHandleCustomRequestsFalse
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.IsHandleCustomRequestsFalse(Context());' |

@OnServer
Scenario: IsHandleGitLabRequestsTrue
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.IsHandleGitLabRequestsTrue(Context());' |

@OnServer
Scenario: IsHandleGitLabRequestsFalse
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.IsHandleGitLabRequestsFalse(Context());' |

@OnServer
Scenario: GetEndpointUserName
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.GetEndpointUserName(Context());' |

@OnServer
Scenario: GetEndpointUserPassword
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.GetEndpointUserPassword(Context());' |

@OnServer
Scenario: GetEndpointTimeout
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.GetEndpointTimeout(Context());' |

@OnServer
Scenario: GetGitLabToken
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.GetGitLabToken(Context());' |

@OnServer
Scenario: GetGitLabTimeout
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.GetGitLabTimeout(Context());' |

@OnServer
Scenario: GetRoutingFileName
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.GetRoutingFileName(Context());' |