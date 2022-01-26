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
Scenario: StartDumpData
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.StartDumpData(Context());' |

@OnServer
Scenario: StartProjectDataNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.StartProjectDataNotFound(Context());' |

@OnServer
Scenario: StartCommitsNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.StartCommitsNotFound(Context());' |

@OnServer
Scenario: StartDownloadFromRemoteVCSNoRouts
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.StartDownloadFromRemoteVCSNoRouts(Context());' |

@OnServer
Scenario: ManualRunErrorLoadDataRequestBodyNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.ManualRunErrorLoadDataRequestBodyNotFound(Context());' |

@OnServer
Scenario: ManualRunErrorLoadDataRemoteFilesNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.ManualRunErrorLoadDataRemoteFilesNotFound(Context());' |

@OnServer
Scenario: ManualLoadDataSaccess
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.ManualLoadDataSaccess(Context());' |

@OnServer
Scenario: ManualRunCompleted
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.ManualRunCompleted(Context());' |

@OnServer
Scenario: GetBackgroundsByCommit
	And I execute 1C:Enterprise script at server
	| 'TestsDataProcessingServer.GetBackgroundsByCommit(Context());' |