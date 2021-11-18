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
Scenario: IsHandleRequestsTrue
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.IsHandleRequestsTrue(Context());' |

@OnServer
Scenario: IsHandleRequestsFalse
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.IsHandleRequestsFalse(Context());' |

@OnServer
Scenario: ReceiverUserName
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.ReceiverUserName(Context());' |

@OnServer
Scenario: ReceiverUserPassword
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.ReceiverUserPassword(Context());' |

@OnServer
Scenario: DeliveryFileTimeout
	And I execute 1C:Enterprise script at server
	| 'TestsServicesSettingsServer.DeliveryFileTimeout(Context());' |