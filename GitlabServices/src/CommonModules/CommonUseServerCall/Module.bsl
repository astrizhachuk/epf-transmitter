#Region Public

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

#EndRegion
