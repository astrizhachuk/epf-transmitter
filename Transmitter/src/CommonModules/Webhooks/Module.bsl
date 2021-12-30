#Region Public

// LoadEventsHistory loads data from the event log into the object by filter.
// 
// Parameters:
// 	Object - CatalogObject.ExternalRequestHandlers - target object; 
// 	Destination - String - tabular section name;
// 	Filter - Structure - event log filter (see global context UnloadEventLog);
// 	RecordsLoaded - Number - (returned) number of loaded records;
//
Procedure LoadEventsHistory( Object, Val Destination, Val Filter, RecordsLoaded ) Export
	
	If ( NOT Filter.Property( "Data" ) ) Then
		
		Filter.Insert( "Data", Object.Ref );
		
	EndIf;
	
	Catalogs.ExternalRequestHandlers.LoadEventsHistory( Object, Destination, Filter, RecordsLoaded );
	
EndProcedure

#EndRegion
