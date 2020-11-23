// BSLLS-off

#Region Public

// Supplements the DestinationArray array with values from the SourceArray array.
//
// Parameters:
//  DestinationArray - Array - array to be supplied with values;
//  SourceArray      - Array - array of values to supply DestinationArray;
//  UniqueValuesOnly - Boolean, optional - if it is True, only values that are not included in
//                     the destination array will be supplied. Such values will be supplied
//                     only once. 
//
Procedure SupplementArray(DestinationArray, SourceArray, UniqueValuesOnly = False) Export

	UniqueValues = New Map;
	
	If UniqueValuesOnly Then
		For Each Value In DestinationArray Do
			UniqueValues.Insert(Value, True);
		EndDo;
	EndIf;
	
	For Each Value In SourceArray Do
		If UniqueValuesOnly And UniqueValues[Value] <> Undefined Then
			Continue;
		EndIf;
		DestinationArray.Add(Value);
		UniqueValues.Insert(Value, True);
	EndDo;
	
EndProcedure

// Deletes duplicate items from the array.
//
// Parameters:
// Array - Array - array of arbitrary values.
//
// Returns:
// Array;
// 
Function CollapseArray(Array) Export
	Result = New  Array;
	SupplementArray(Result, Array, True);
	Return Result;
EndFunction

// Returns value of the structure property.
//
// Parameters:
//   Structure - Structure, FixedStructure - Object from which it is required to read the key value.
//   Key - String - Structure property name for which it is required to read value.
//   DefaultValue - Arbitrary - Optional. Returned when there is no value
//                                        by the specified key in the structure.
//       To make it quicker, it is recommended to pass only
//       quickly calculated values (for example, primitive types) but execute the initialization of more
//       difficult values after check of the received value (only if needed).
//
// Returns:
//   Arbitrary - Value of the structure property. DefaultValue if the structure does not contain the specified property.
//
Function StructureProperty(Structure, Key, DefaultValue = Undefined) Export
	
	If Structure = Undefined Then
		Return Undefined;
	EndIf;
	
	Result = DefaultValue;
	If Structure.Property(Key, Result) Then
		Return Result;
	Else
		Return DefaultValue;
	EndIf;
	
EndFunction

// Adds the composition item into the composition item container.
//
// Parameters:
// ItemCollection - container with items and groups of the filter, for example
//                  List.Filter or a group in the filter;
// FieldName      - String - data composition field name. Must be filled.
// ComparisonType - DataCompositionComparisonType - comparison type; 
// RightValue     - Arbitrary - value to be compared; 
// Presentation   - String - data composition item presentation;
// Use            - Boolean - item usage;
//
Function AddCompositionItem(AreaToAdd,
							Val FieldName,
							Val ComparisonType,
							Val RightValue = Undefined,
							Val Presentation = Undefined,
							Val Use = Undefined) Export
	
	Item = AreaToAdd.Items.Add(Type("DataCompositionFilterItem"));
	Item.LeftValue = New DataCompositionField(FieldName);
	Item.ComparisonType = ComparisonType;
	
	If RightValue <> Undefined Then
		Item.RightValue = RightValue;
	EndIf;
	
	If Presentation <> Undefined Then
		Item.Presentation = Presentation;
	EndIf;
	
	If Use <> Undefined Then
		Item.Use = Use;
	EndIf;
 
	Return Item;
	
EndFunction

#EndRegion