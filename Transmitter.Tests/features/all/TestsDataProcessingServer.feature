# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsDataProcessingServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: StartRunSuccess
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.StartRunSuccess(Context());' |

@OnServer
Scenario: StartException
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.StartException(Context());' |

@OnServer
Scenario: StartExceptionActiveJob
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.StartExceptionActiveJob(Context());' |

@OnServer
Scenario: StartSaveData
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.StartSaveData(Context());' |

@OnServer
Scenario: StartProjectDataNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.StartProjectDataNotFound(Context());' |

@OnServer
Scenario: StartCommitsNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.StartCommitsNotFound(Context());' |

@OnServer
Scenario: StartDownloadFromRemoteVCSErrors
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.StartDownloadFromRemoteVCSErrors(Context());' |

@OnServer
Scenario: ManualRunSuccess
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.ManualRunSuccess(Context());' |

@OnServer
Scenario: ManualRunErrorLoadDataRequestBodyNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.ManualRunErrorLoadDataRequestBodyNotFound(Context());' |

@OnServer
Scenario: ManualRunErrorLoadDataRemoteFilesNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.ManualRunErrorLoadDataRemoteFilesNotFound(Context());' |

@OnServer
Scenario: ManualLoadData
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.ManualLoadData(Context());' |

@OnServer
Scenario: RunLogs
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.RunLogs(Context());' |