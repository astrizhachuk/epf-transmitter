#Region Public

// GetVersion returns the version of the configuration.
// 
// Returns:
// 	String - version;
//
Function GetVersion() Export
	
	Return Metadata.Version;
	
EndFunction

// NewErrorInfo creates a new ErrorInfo instance with the specified description.
// 
// Parameters:
// 	Message - String - error text;
// 	
// Returns:
// 	ErrorInfo - new ErrorInfo;
//
Function NewErrorInfo( Val Message ) Export
	
	Try
		
		Raise Message;
		
	Except
		
		Return ErrorInfo();
		
	EndTry;
	
EndFunction

// TODO test ReadToMap and PropertiesNamesWithDateValues

// JsonToObject converts JSON into Object.
// 
// Parameters:
// 	JSON - String - JSON data;
// 	
// Returns:
// 	Arbitrary - deserialized JSON;
//
Function JsonToObject( Val JSON ) Export
		
	Var ConversionParams;
		
	ConversionParams = New Structure();
	ConversionParams.Insert( "ReadToMap", True );
	ConversionParams.Insert( "PropertiesNamesWithDateValues", "timestamp" );
	
	Return HTTPConnector.JsonToObject( JSON, , ConversionParams );

EndFunction

#Region Stream

// AppendCollectionFromStream adds an item to the collection with the value read from the stream.
// 
// Parameters:
// 	Collection - Structure, Map - destination;
// 	Key - String - the key of the new item;
// 	Stream - Stream - source;
//			
Procedure AppendCollectionFromStream( Collection, Val Key, Val Stream ) Export
	
	Var Reader;
	Var Text;

	Try
		
		Stream.Seek( 0, PositionInStream.Begin );
		Reader = New TextReader( Stream, TextEncoding.UTF8 );
		Text = Reader.Read();
		Collection.Insert( Key, Text );
		
	Except
		
		Reader.Close();
		Raise;
		
	EndTry;

	Reader.Close();
	
EndProcedure

#EndRegion

#Region SSL

// BSLLS-off

// ValueTableToArray converts a table of values to an array of structures.
// 
// Parameters:
// 	ValueTable - ValueTable - arbitrary table of values;
// 	
// Returns:
// 	Array of Structure - array of structures:
// 	* Key - column name;
// 	* Value - value;
//
Function ValueTableToArray( ValueTable ) Export

	Array = New Array();
	StructureString = "";
	NeedSeparator = False;
	
	For Each Column In ValueTable.Columns Do
		If NeedSeparator Then
			StructureString = StructureString + ",";
		EndIf;
		StructureString = StructureString + Column.Name;
		NeedSeparator = True;	
	EndDo;
	
	For Each String In ValueTable Do	
		NewString = New Structure(StructureString);
		FillPropertyValues(NewString, String);
		Array.Add(NewString);
	EndDo;
	
	Return Array;

EndFunction

// BSLLS-on

#EndRegion

#EndRegion
