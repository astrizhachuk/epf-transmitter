#Region EventHandlers

Procedure BeforeWrite( Cancel )
	
	Var Items;
	
	If ( Cancel OR DataExchange.Load ) Then
		
		Return;

	EndIf;
	
	Items = Catalogs.ExternalRequestHandlers.FindByURL( ThisObject.ProjectURL );
	
	For Each Item In Items Do
		
		If ( Ref = Item.Ref ) Then

			Continue;
			
		EndIf;
		
		Cancel = True;
		
		Return;
		
	EndDo;

EndProcedure

#EndRegion
