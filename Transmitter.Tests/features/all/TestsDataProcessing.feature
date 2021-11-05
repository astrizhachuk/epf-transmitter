# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsDataProcessing
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: BeginDataProcessing
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessing.BeginDataProcessing(Context());' |

@OnServer
Scenario: BeginDataProcessingManualStart
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessing.BeginDataProcessingManualStart(Context());' |

@OnServer
Scenario: BeginDataProcessingHandleRequest
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessing.BeginDataProcessingHandleRequest(Context());' |

@OnServer
Scenario: BeginDataProcessingHandleRequestWithoutCheckoutSHA
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessing.BeginDataProcessingHandleRequestWithoutCheckoutSHA(Context());' |

@OnServer
Scenario: BeginDataProcessingHandleRequestErrorDataType
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessing.BeginDataProcessingHandleRequestErrorDataType(Context());' |

@OnServer
Scenario: BeginDataProcessingHandleRequestIsActiveBackgroundJob
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessing.BeginDataProcessingHandleRequestIsActiveBackgroundJob(Context());' |

@OnServer
Scenario: BeginDataProcessingHandleRequestErrorStartBackgroundLob
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessing.BeginDataProcessingHandleRequestErrorStartBackgroundLob(Context());' |

@OnServer
Scenario: BeginDataProcessingHandleRequestWithoutData
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessing.BeginDataProcessingHandleRequestWithoutData(Context());' |

@OnServer
Scenario: BeginDataProcessingHandleRequestQueryDataEmpty
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessing.BeginDataProcessingHandleRequestQueryDataEmpty(Context());' |

@OnServer
Scenario: BeginDataProcessingManualStartWithoutSavedData
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessing.BeginDataProcessingManualStartWithoutSavedData(Context());' |

@OnServer
Scenario: BeginDataProcessingManualStartWithSavedData
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessing.BeginDataProcessingManualStartWithSavedData(Context());' |

@OnServer
Scenario: BeginDataProcessingManualStartFileSendingBackgroundJob
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessing.BeginDataProcessingManualStartFileSendingBackgroundJob(Context());' |