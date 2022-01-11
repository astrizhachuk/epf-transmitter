# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsRemoteFilesServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: GetFromRemoteVCSEmptyData
	And I execute 1C:Enterprise script at server
	| 'TestsRemoteFilesServer.GetFromRemoteVCSEmptyData(Context());' |

@OnServer
Scenario: GetFromRemoteVCSCommitsNoCompiledFiles
	And I execute 1C:Enterprise script at server
	| 'TestsRemoteFilesServer.GetFromRemoteVCSCommitsNoCompiledFiles(Context());' |

@OnServer
Scenario: GetFromRemoteVCSGetFileMetadataFromCommits
	And I execute 1C:Enterprise script at server
	| 'TestsRemoteFilesServer.GetFromRemoteVCSGetFileMetadataFromCommits(Context());' |

@OnServer
Scenario: GetFromIB
	And I execute 1C:Enterprise script at server
	| 'TestsRemoteFilesServer.GetFromIB(Context());' |

@OnServer
Scenario: GetFromIBNoData
	And I execute 1C:Enterprise script at server
	| 'TestsRemoteFilesServer.GetFromIBNoData(Context());' |