#Region EventHandlers

Procedure BeforeWrite( Cancel )
	
	Var WebhooksByToken;
	
	If ( Cancel OR DataExchange.Load ) Then
		
		Return;

	EndIf;
	
	WebhooksByToken = Catalogs.Webhooks.FindByToken( ThisObject.SecretToken );
	
	For Each Webhook In WebhooksByToken Do
		
		If ( Webhook = ThisObject.Ref) Then

			Continue;
			
		EndIf;
		
		Cancel = True;
		
		Return;
		
	EndDo;

EndProcedure

#EndRegion
