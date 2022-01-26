#Region Public

// GetByKeyPrefix returns an array of BackgroundJob objects according to the specified filter
// and BackgroundJob key prefix.
// 
// Parameters:
// 	Filter - Structure - filter for global method BackgroundJobs.GetBackgroundJobs;
// 	Prefix - String - additional filter for BackgroundJob key prefix;
// 	
// Returns:
// 	Array of BackgroundJob - an array of backgrounds;
//
Function GetByKeyPrefix( Val Filter, Val Prefix ) Export
	
	Var Jobs;
	Var Result;
	
	Result = New Array();
	
	If ( TypeOf(Filter) <> Type("Structure") ) Then
		
		Return Result;
		
	EndIf;
	
	SetPrivilegedMode(True);
	
	Jobs = BackgroundJobs.GetBackgroundJobs( Filter );
	
	For Each Job In Jobs Do
		
		If ( NOT StrStartsWith(Job.Key, Prefix) ) Then
			
			Continue;
			
		EndIf;
		
		Result.Add( Job );
		
	EndDo;
	
	Return Result;

EndFunction

#EndRegion
