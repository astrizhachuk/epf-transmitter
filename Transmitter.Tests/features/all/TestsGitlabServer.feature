# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsGitLabServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: GetStatusMessage
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.GetStatusMessage(Context());' |

@OnServer
Scenario: ConnectionParams
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.ConnectionParams(Context());' |

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
Scenario: RemoteFilesWithDescription
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.RemoteFilesWithDescription(Context());' |

@OnServer
Scenario: ProjectDescription
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.ProjectDescription(Context());' |

@OnServer
Scenario: MergeRequests
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.MergeRequests(Context());' |

@OnServer
Scenario: RemoteFilesEmpty
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.RemoteFilesEmpty(Context());' |

@OnServer
Scenario: RAWFilePath
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.RAWFilePath(Context());' |

@OnServer
Scenario: ListFileActions
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabServer.ListFileActions(Context());' |