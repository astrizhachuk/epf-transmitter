#Region EventHandlers

Procedure BeforeWrite( Cancel )
	
	Var Items;
	
	If ( Cancel OR DataExchange.Load ) Then
		
		Return;

	EndIf;
	
	Items = Catalogs.Webhooks.FindByURL( ThisObject.ProjectURL );
	
	For Each Item In Items Do
		
		If ( ThisObject.Ref = Item.Ref ) Then

			Continue;
			
		EndIf;
		
		Cancel = True;
		
		Return;
		
	EndDo;

EndProcedure

#EndRegion
