# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsGitLabAPIServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: GetConnectionParams
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetConnectionParams(Context());' |

@OnServer
Scenario: GetCheckoutSHANotFound
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetCheckoutSHANotFound(Context());' |

@OnServer
Scenario: GetCheckoutSHA
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetCheckoutSHA(Context());' |

@OnServer
Scenario: GetProjectWithoutProjectNode
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetProjectWithoutProjectNode(Context());' |

@OnServer
Scenario: GetProjectWithoutWebURL
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetProjectWithoutWebURL(Context());' |

@OnServer
Scenario: GetProjectWithoutProjectId
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetProjectWithoutProjectId(Context());' |

@OnServer
Scenario: GetProjectShortURL
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetProjectShortURL(Context());' |

@OnServer
Scenario: GetProjectLongURL
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetProjectLongURL(Context());' |

@OnServer
Scenario: GetCommitsWithoutCommitsNode
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetCommitsWithoutCommitsNode(Context());' |

@OnServer
Scenario: GetCommits
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetCommits(Context());' |

@OnServer
Scenario: GetRAWFilePath
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetRAWFilePath(Context());' |

@OnServer
Scenario: GetFileActions
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetFileActions(Context());' |

@OnServer
Scenario: GetRAWFilesNoRAWFilePaths
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetRAWFilesNoRAWFilePaths(Context());' |

@OnServer
Scenario: GetRAWFilesBadURL
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetRAWFilesBadURL(Context());' |

@OnServer
Scenario: GetRAWFiles404NotFound
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetRAWFiles404NotFound(Context());' |

@OnServer
Scenario: GetRAWFilesMixed
	And I execute 1C:Enterprise script at server
	| 'TestsGitLabAPIServer.GetRAWFilesMixed(Context());' |