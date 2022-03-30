# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsEndpointsClient
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

Scenario: Connector
	And I execute 1C:Enterprise script
	| 'TestsEndpointsClient.Connector(Context());' |

Scenario: GetStatusServiceException
	And I execute 1C:Enterprise script
	| 'TestsEndpointsClient.GetStatusServiceException(Context());' |