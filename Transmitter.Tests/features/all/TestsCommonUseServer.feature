# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsCommonUseServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: GetVersion
	And I execute 1C:Enterprise script at server
	| 'TestsCommonUseServer.GetVersion(Context());' |

@OnServer
Scenario: NewErrorInfo
	And I execute 1C:Enterprise script at server
	| 'TestsCommonUseServer.NewErrorInfo(Context());' |

@OnServer
Scenario: AppendCollectionFromStream
	And I execute 1C:Enterprise script at server
	| 'TestsCommonUseServer.AppendCollectionFromStream(Context());' |