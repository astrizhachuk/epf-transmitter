# language: en

@tree
@classname=ModuleExceptionPath

Feature: GitLabServices.Tests.TestsGitlabServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: ConnectionParams
	And I execute 1C:Enterprise script at server
	| 'TestsGitlabServer.ConnectionParams(Context());' |

@OnServer
Scenario: RemoteFileBadURL
	And I execute 1C:Enterprise script at server
	| 'TestsGitlabServer.RemoteFileBadURL(Context());' |

@OnServer
Scenario: RemoteFile404NotFound
	And I execute 1C:Enterprise script at server
	| 'TestsGitlabServer.RemoteFile404NotFound(Context());' |

@OnServer
Scenario: RemoteFile401Unauthorized
	And I execute 1C:Enterprise script at server
	| 'TestsGitlabServer.RemoteFile401Unauthorized(Context());' |

@OnServer
Scenario: RemoteFileEmpty
	And I execute 1C:Enterprise script at server
	| 'TestsGitlabServer.RemoteFileEmpty(Context());' |

@OnServer
Scenario: RemoteFile200Ok
	And I execute 1C:Enterprise script at server
	| 'TestsGitlabServer.RemoteFile200Ok(Context());' |

@OnServer
Scenario: RemoteFiles
	And I execute 1C:Enterprise script at server
	| 'TestsGitlabServer.RemoteFiles(Context());' |

@OnServer
Scenario: RemoteFilesWithDescription
	And I execute 1C:Enterprise script at server
	| 'TestsGitlabServer.RemoteFilesWithDescription(Context());' |

@OnServer
Scenario: ProjectDescription
	And I execute 1C:Enterprise script at server
	| 'TestsGitlabServer.ProjectDescription(Context());' |

@OnServer
Scenario: MergeRequests
	And I execute 1C:Enterprise script at server
	| 'TestsGitlabServer.MergeRequests(Context());' |

@OnServer
Scenario: RemoteFilesEmpty
	And I execute 1C:Enterprise script at server
	| 'TestsGitlabServer.RemoteFilesEmpty(Context());' |

@OnServer
Scenario: RAWFilePath
	And I execute 1C:Enterprise script at server
	| 'TestsGitlabServer.RAWFilePath(Context());' |

@OnServer
Scenario: ListFileActions
	And I execute 1C:Enterprise script at server
	| 'TestsGitlabServer.ListFileActions(Context());' |