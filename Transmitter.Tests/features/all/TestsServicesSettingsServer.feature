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
Scenario: IsHandleGitLabRequestsTrue
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.IsHandleGitLabRequestsTrue(Context());' |

@OnServer
Scenario: IsHandleGitLabRequestsFalse
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.IsHandleGitLabRequestsFalse(Context());' |

@OnServer
Scenario: EndpointUserName
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.EndpointUserName(Context());' |

@OnServer
Scenario: EndpointUserPassword
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.EndpointUserPassword(Context());' |

@OnServer
Scenario: EndpointTimeout
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.EndpointTimeout(Context());' |

@OnServer
Scenario: GitLabToken
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.GitLabToken(Context());' |

@OnServer
Scenario: GetGitLabTimeout
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.GetGitLabTimeout(Context());' |

@OnServer
Scenario: RoutingFileName
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.RoutingFileName(Context());' |