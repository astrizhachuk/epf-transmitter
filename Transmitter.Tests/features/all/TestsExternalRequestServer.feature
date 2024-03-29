# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsExternalRequestServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: FillDataTypeException
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.FillDataTypeException(Context());' |

@OnServer
Scenario: FillDeserializationException
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.FillDeserializationException(Context());' |

@OnServer
Scenario: Fill
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.Fill(Context());' |

@OnServer
Scenario: Load
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.Load(Context());' |

@OnServer
Scenario: Validate
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.Validate(Context());' |

@OnServer
Scenario: ValidateJSON
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.ValidateJSON(Context());' |

@OnServer
Scenario: ValidateProjectId
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.ValidateProjectId(Context());' |

@OnServer
Scenario: ValidateCheckoutSHA
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.ValidateCheckoutSHA(Context());' |

@OnServer
Scenario: ValidateProjectURL
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.ValidateProjectURL(Context());' |

@OnServer
Scenario: ValidateServerURL
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.ValidateServerURL(Context());' |

@OnServer
Scenario: GetJSON
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetJSON(Context());' |

@OnServer
Scenario: GetProjectId
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetProjectId(Context());' |

@OnServer
Scenario: GetProjectURL
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetProjectURL(Context());' |

@OnServer
Scenario: GetServerURL
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetServerURL(Context());' |

@OnServer
Scenario: GetCheckoutSHA
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetCheckoutSHA(Context());' |

@OnServer
Scenario: GetCommits
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetCommits(Context());' |

@OnServer
Scenario: GetCommitsException
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetCommitsException(Context());' |

@OnServer
Scenario: GetCommit
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetCommit(Context());' |

@OnServer
Scenario: GetCommitException
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetCommitException(Context());' |

@OnServer
Scenario: GetModifiedFiles
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetModifiedFiles(Context());' |

@OnServer
Scenario: ToCollection
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.ToCollection(Context());' |

@OnServer
Scenario: GetRouteJSON
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetRouteJSON(Context());' |

@OnServer
Scenario: GetRouteJSONNotFound
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetRouteJSONNotFound(Context());' |

@OnServer
Scenario: AddRoute
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.AddRoute(Context());' |

@OnServer
Scenario: AddRouteReWrite
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.AddRouteReWrite(Context());' |

@OnServer
Scenario: RemoveRoute
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.RemoveRoute(Context());' |

@OnServer
Scenario: RemoveRouteCustom
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.RemoveRouteCustom(Context());' |

@OnServer
Scenario: GetActualRoutesNoData
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetActualRoutesNoData(Context());' |

@OnServer
Scenario: GetActualRoutes
	And I execute 1C:Enterprise script at server
	| 'TestsExternalRequestServer.GetActualRoutes(Context());' |