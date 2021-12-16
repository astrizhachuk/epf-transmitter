#Region Public

Function IsActive( Val Key ) Export
	
	Return ValueIsFilled( GetActiveBackgroundJobs(Key) );
	
EndFunction

#EndRegion

#Region Private

Function GetActiveBackgroundJobs( Val Key )
	
	Var Filter;
	
	Filter = New Structure( "Key, State", Key, BackgroundJobState.Active );

	Return BackgroundJobs.GetBackgroundJobs( Filter );
	
EndFunction

#EndRegion
