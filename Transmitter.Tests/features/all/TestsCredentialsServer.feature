# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsCredentialsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: FindByURL
	And I execute 1C:Enterprise script at server
	| 'TestsCredentialsServer.FindByURL(Context());' |

@OnServer
Scenario: FindByURLNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsCredentialsServer.FindByURLNotFound(Context());' |

@OnServer
Scenario: FindByURLDublicated
	And I execute 1C:Enterprise script at server
	| 'TestsCredentialsServer.FindByURLDublicated(Context());' |

@OnServer
Scenario: FindByURLWrongType
	And I execute 1C:Enterprise script at server
	| 'TestsCredentialsServer.FindByURLWrongType(Context());' |