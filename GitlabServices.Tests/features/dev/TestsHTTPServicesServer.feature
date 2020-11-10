# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.TestsHTTPServicesServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: WebhooksPOST403Forbidden
	And I execute 1C:Enterprise script at server
	| 'TestsHTTPServicesServer.WebhooksPOST403Forbidden(Context());' |