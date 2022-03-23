# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsEndpointsClient
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

Scenario: GetConnectionParams
	And I execute 1C:Enterprise script
	| 'TestsEndpointsClient.GetConnectionParams(Context());' |

Scenario: GetServiceStatusException
	And I execute 1C:Enterprise script
	| 'TestsEndpointsClient.GetServiceStatusException(Context());' |