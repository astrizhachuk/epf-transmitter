#Region Public

// Возвращает фиксированную структуру со всеми текущими настройками механизмов управления сервисами GitLab.
// 
// Параметры:
// Возвращаемое значение:
// ФиксированнаяСтруктура - описание:
// * IsHandleRequests - Boolean - (see Constants.HandleRequests);
// * RoutingFileName - String - (see Constants.RoutingFileName);
// * TokenGitLab - String - (see Constants.TokenGitLab);
// * TimeoutGitLab - Number - (see Constants.TimeoutGitLab);
// * TokenReceiver - String - (see Constants.TokenReceiver);
// * TimeoutDeliveryFile - Number - (see Constants.TimeoutDeliveryFile);
//
Функция CurrentSettings() Экспорт
	
	Var Результат;

	Результат = Новый Структура();
	Результат.Вставить( "IsHandleRequests", IsHandleRequests() );
	Результат.Вставить( "RoutingFileName", RoutingFileName() );
	Результат.Вставить( "TokenGitLab", TokenGitLab() );
	Результат.Вставить( "TimeoutGitLab", TimeoutGitLab() );
	Результат.Вставить( "TokenReceiver", TokenReceiver() );
	Результат.Вставить( "TimeoutDeliveryFile", TimeoutDeliveryFile() );
	
	Результат = Новый ФиксированнаяСтруктура( Результат );

	Возврат Результат;
	
КонецФункции

// Параметры доставки данных до веб-сервиса работы с внешними отчетами и обработками в информационной базе получателе.
// 
// Параметры:
// Возвращаемое значение:
// 	Структура - Описание:
// * Адрес - Строка - адрес веб-сервиса для работы с внешними отчетами и обработками в информационной базе получателе;
// * Token - Строка - token доступа к сервису получателя;
// * Таймаут - Число - таймаут соединения с сервисом, секунд (если 0 - таймаут не установлен);
//
Функция ПараметрыПолучателя() Экспорт
	
	Var Результат;
	
	Результат = Новый Структура();
	Результат.Вставить( "Адрес", "localhost/receiver/hs/gitlab" );
	Результат.Вставить( "Token", TokenReceiver() );
	Результат.Вставить( "Таймаут", TimeoutDeliveryFile() );
	
	Возврат Результат;
	
КонецФункции

// RoutingFileName the constant value with the name of the routing settings file located in the project root.
//
// Parameters:
// Returns:
// 	String - file name (max. 50 chars);
//
Function RoutingFileName() Export
	
	Return Constants.RoutingFileName.Get();
	
EndFunction

// TokenGitLab returns the constant value from the private token of a GitLab user
// with access to the GitLab API.
// 
// Parameters:
// Returns:
// 	String - value of PRIVATE-TOKEN (max. 50 chars);
// 
Function TokenGitLab() Export
	
	Return Constants.TokenGitLab.Get();
	
EndFunction

// TimeoutGitLab returns the constant value with the connection timeout to the GitLab server.
//
// Parameters:
// Returns:
// 	Number - the connection timeout, sec (0 - timeout is not set);
//
Function TimeoutGitLab() Export
	
	Return Constants.TimeoutGitLab.Get();

EndFunction

#EndRegion

#Region Private

// IsHandleRequests returns the value of the setting of processing requests from the GitLab repository.
//
// Parameters:
// Returns:
// 	Boolean - True - to process requests, otherwise - False;
//
Function IsHandleRequests()
	
	Return Constants.HandleRequests.Get();

EndFunction

// TokenReceiver returns the constant value used to connect to file delivery end-point services.
// 
// Parameters:
// Returns:
// 	String - value of token (max. 20 chars);
//
Function TokenReceiver()
	
	Return Constants.TokenReceiver.Get();
	
EndFunction

// TimeoutDeliveryFile returns the constant value with the connection timeout to the receiver.
//
// Parameters:
// Returns:
// 	Number - the connection timeout, sec (0 - timeout is not set);
//
Function TimeoutDeliveryFile()
	
	Return Constants.TimeoutDeliveryFile.Get();
	
EndFunction

#EndRegion