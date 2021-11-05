# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsServicesSettingsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: CurrentSettings
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.CurrentSettings(Context());' |

@OnServer
Scenario: RoutingFileName
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.RoutingFileName(Context());' |

@OnServer
Scenario: TokenGitLab
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.TokenGitLab(Context());' |

@OnServer
Scenario: TimeoutGitLab
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.TimeoutGitLab(Context());' |

@OnServer
Scenario: TimeoutDeliveryFile
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.TimeoutDeliveryFile(Context());' |

@OnServer
Scenario: TokenReceiver
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.TokenReceiver(Context());' |