# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsProjectsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: FindCredentials
	And I execute 1C:Enterprise script at server
	| 'TestsProjectsServer.FindCredentials(Context());' |

@OnServer
Scenario: FindCredentialsNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsProjectsServer.FindCredentialsNotFound(Context());' |

@OnServer
Scenario: FindCredentialsDublicated
	And I execute 1C:Enterprise script at server
	| 'TestsProjectsServer.FindCredentialsDublicated(Context());' |

@OnServer
Scenario: FindCredentialsWrongType
	And I execute 1C:Enterprise script at server
	| 'TestsProjectsServer.FindCredentialsWrongType(Context());' |