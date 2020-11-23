# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.TestsWebhooksServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: FindByTokenEmptyRefIfNumber
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.FindByTokenEmptyRefIfNumber(Context());' |

@OnServer
Scenario: FindByTokenEmptyRefIfBlankRef
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.FindByTokenEmptyRefIfBlankRef(Context());' |

@OnServer
Scenario: FindByTokenEmptyRefIfUndefined
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.FindByTokenEmptyRefIfUndefined(Context());' |

@OnServer
Scenario: FindByTokenEmptyRefIfNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.FindByTokenEmptyRefIfNotFound(Context());' |

@OnServer
Scenario: FindByToken
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.FindByToken(Context());' |

@OnServer
Scenario: LoadEventsHistory
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.LoadEventsHistory(Context());' |

@OnServer
Scenario: SaveQueryData
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.SaveQueryData(Context());' |

@OnServer
Scenario: SaveQueryDataWriteError
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.SaveQueryDataWriteError(Context());' |

@OnServer
Scenario: SaveRemoteFilesWriteError
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.SaveRemoteFilesWriteError(Context());' |

@OnServer
Scenario: LoadRemoteFiles
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.LoadRemoteFiles(Context());' |

@OnServer
Scenario: LoadRemoteFilesNoData
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.LoadRemoteFilesNoData(Context());' |

@OnServer
Scenario: LoadQueryData
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.LoadQueryData(Context());' |

@OnServer
Scenario: LoadQueryDataNoData
	And I execute 1C:Enterprise script at server
	| 'TestsWebhooksServer.LoadQueryDataNoData(Context());' |