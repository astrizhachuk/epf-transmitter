#Region Public

// Encode converts a string from one encoding to another.
//
// Parameters:
// 	String - String - source string;
// 	From - String - the encoding from which you want to convert;
// 	Into - String - the encoding to be converted into;
//
// Returns:
// 	String - result string;
//
Function Encode (Val String, Val From, Val Into = "UTF-8") Export
	
	Var Stream;
	Var Writer;
	Var Reader;
	
	Stream = New MemoryStream();
	Writer = New DataWriter( Stream, From );
	Writer.WriteLine( String );
	Stream.Seek( 0, PositionInStream.Begin );
	Reader = New DataReader( Stream, Into );

	Return Reader.ReadLine();
	
EndFunction

#EndRegion