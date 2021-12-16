#Region Public

// IsActive returns the result of checking the activity of a background job by its key.
// 
// Parameters:
// 	Key - String - job key;
// 	
// Returns:
// 	Boolean - True - is active, otherwise - False;
//
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
