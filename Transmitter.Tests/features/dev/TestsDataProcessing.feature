# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsDataProcessing
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: BeginDataProcessingHandleRequestIsActiveBackgroundJob
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessing.BeginDataProcessingHandleRequestIsActiveBackgroundJob(Context());' |