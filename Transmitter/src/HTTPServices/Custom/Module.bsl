#Region Private

#Region Methods

Function StatusGet(Request)
	
	Return HTTPServices.GetHandleRequestStatus( Enums.RequestSource.Custom );
	
EndFunction

#EndRegion

#EndRegion

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
