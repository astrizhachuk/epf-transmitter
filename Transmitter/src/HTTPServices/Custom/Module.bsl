#Region Private

#Region Methods

Function StatusGet(Request)
	
	Var Response;
	
	Response = New HTTPServiceResponse( FindCodeById("OK") );
	HTTPServices.SetBodyAsJSON( Response, HTTPServices.GetHandleRequestsStatus(Enums.RequestSource.Custom) );
	
	Return Response;
	
EndFunction

#EndRegion

Function StatusCodes()
	
	Возврат HTTPStatusCodesClientServerCached;
	
EndFunction

Function FindCodeById( Val Id )
	
	Return StatusCodes().FindCodeById( Id );
	
EndFunction

#EndRegion

// GetHandleRequestsStatus returns the current setting state for handling requests
// from external stores as a message object.
// 
// Returns:
// 	Structure - message object:
// * message - String - message text;
//
Function GetHandleRequestsStatus()
	
	Var Result;
	
	MESSAGE_ENABLED = NStr( "ru = 'обработка запросов включена';en = 'request handler enabled'" );
	MESSAGE_DISABLED = NStr( "ru = 'обработка запросов отключена';en = 'request handler disabled'" );
	
	If ( ServicesSettings.IsHandleCustomRequests() ) Then
		
		Result = HTTPServices.CreateMessage( MESSAGE_ENABLED );
		
	Else
		
		Result = HTTPServices.CreateMessage( MESSAGE_DISABLED );
		
	EndIf;
	
	Return Result;
	
EndFunction

Function SendPost(Request)
	Response = New HTTPServiceResponse(200);
	
//	
//	Файлы = Новый Массив;
//Файлы.Добавить(Новый Структура("Name,Data,FileName", "f1", Base64Значение("ZmlsZTE="), "file1.txt"));
//Файлы.Добавить(Новый Структура("Name,Data,FileName", "f2", Base64Значение("ZmlsZTI="), "file2.txt"));
//
//Данные = Новый Структура("field1,field1", "value1111", "Значение22222");
//
//Результат = HTTPConnector.Post("http://transmitter/api/hs/manual/send", Неопределено, Новый Структура("Files,Data", Файлы, Данные));
//	
	Return Response;
EndFunction
