# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsBackgroundsServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: GetJobsByKeyPrefixNoFilter
	And I execute 1C:Enterprise script at server
	| 'TestsBackgroundsServer.GetJobsByKeyPrefixNoFilter(Context());' |

@OnServer
Scenario: GetJobsByKeyPrefix
	And I execute 1C:Enterprise script at server
	| 'TestsBackgroundsServer.GetJobsByKeyPrefix(Context());' |