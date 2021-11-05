# language: en

@tree
@classname=ModuleExceptionPath

Feature: Transmitter.Tests.TestsReceiversServer
	As Developer
	I want the returns value to be equal to expected value
	That I can guarantee the execution of the method

@OnServer
Scenario: ConnectionParams
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.ConnectionParams(Context());' |

@OnServer
Scenario: ConnectionParamsNegativeTimeout
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.ConnectionParamsNegativeTimeout(Context());' |

@OnServer
Scenario: SendFileWithoutSendParamsAndWithoutEventParams
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFileWithoutSendParamsAndWithoutEventParams(Context());' |

@OnServer
Scenario: SendFileWithoutSendParamsAndEventParamsExists
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFileWithoutSendParamsAndEventParamsExists(Context());' |

@OnServer
Scenario: SendFileError403ForbiddenWithoutEventParams
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFileError403ForbiddenWithoutEventParams(Context());' |

@OnServer
Scenario: SendFileError403ForbiddenEventParamsExists
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFileError403ForbiddenEventParamsExists(Context());' |

@OnServer
Scenario: SendFile200OkWithoutEventParams
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFile200OkWithoutEventParams(Context());' |

@OnServer
Scenario: SendFile200OkEventParamsExists
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFile200OkEventParamsExists(Context());' |

@OnServer
Scenario: SendFileWithoutSendParamsBackgroundJob
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFileWithoutSendParamsBackgroundJob(Context());' |

@OnServer
Scenario: SendFileBackgroundJobSingleFile200OkEventParamsExists
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFileBackgroundJobSingleFile200OkEventParamsExists(Context());' |

@OnServer
Scenario: SendFileBackgroundJobMultipleFiles200OkEventParamsExists
	And I execute 1C:Enterprise script at server
	| 'TestsReceiversServer.SendFileBackgroundJobMultipleFiles200OkEventParamsExists(Context());' |