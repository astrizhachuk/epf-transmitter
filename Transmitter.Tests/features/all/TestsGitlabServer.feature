# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsGitLabServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: GetRequestHandlerStateMessage
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.GetRequestHandlerStateMessage(Context());' |

@OnServer
Scenario: RemoteFileBadURL
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.RemoteFileBadURL(Context());' |

@OnServer
Scenario: RemoteFile404NotFound
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.RemoteFile404NotFound(Context());' |

@OnServer
Scenario: RemoteFile401Unauthorized
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.RemoteFile401Unauthorized(Context());' |

@OnServer
Scenario: RemoteFileEmpty
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.RemoteFileEmpty(Context());' |

@OnServer
Scenario: RemoteFile200Ok
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.RemoteFile200Ok(Context());' |

@OnServer
Scenario: RemoteFiles
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.RemoteFiles(Context());' |

@OnServer
Scenario: MergeRequests
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.MergeRequests(Context());' |