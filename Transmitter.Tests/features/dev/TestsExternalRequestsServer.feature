# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsExternalRequestsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

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