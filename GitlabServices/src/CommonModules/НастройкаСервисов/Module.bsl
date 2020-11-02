#Region Public

// Возвращает фиксированную структуру со всеми текущими настройками механизмов управления сервисами GitLab.
// 
// Параметры:
// Возвращаемое значение:
// ФиксированнаяСтруктура - описание:
// * ОбрабатыватьЗапросыВнешнегоХранилища - Boolean - (see Constants.ОбрабатыватьЗапросыВнешнегоХранилища);
// * ИмяФайлаНастроекМаршрутизации - String - (see Constants.ИмяФайлаНастроекМаршрутизации);
// * GitLabPersonalAccessToken - String - (see Constants.GitLabPersonalAccessToken);
// * GitLabTimeout - Number - (see Constants.GitLabTimeout);
// * ReceiverAccessToken - String - (see Constants.ReceiverAccessToken);
// * ТаймаутДоставкиФайла - Number - (see Constants.ТаймаутДоставкиФайла);
//
Функция CurrentSettings() Экспорт
	
	Var Результат;

	Результат = Новый Структура();
	Результат.Вставить( "ОбрабатыватьЗапросыВнешнегоХранилища", ОбрабатыватьЗапросыВнешнегоХранилища() );
	Результат.Вставить( "ИмяФайлаНастроекМаршрутизации", ИмяФайлаНастроекМаршрутизации() );
	Результат.Вставить( "GitLabPersonalAccessToken", GitLabPersonalAccessToken() );
	Результат.Вставить( "GitLabTimeout", GitLabTimeout() );
	Результат.Вставить( "ReceiverAccessToken", ReceiverAccessToken() );
	Результат.Вставить( "ТаймаутДоставкиФайла", ТаймаутДоставкиФайла() );
	
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
	Результат.Вставить( "Token", ReceiverAccessToken() );
	Результат.Вставить( "Таймаут", ТаймаутДоставкиФайла() );
	
	Возврат Результат;
	
КонецФункции

// Получает значение константы с именем файла настроек маршрутизации, расположенном в корне репозитория GitLab.
//
// Параметры:
// Возвращаемое значение:
// 	Строка - имя файла (макс. 50);
//
Функция ИмяФайлаНастроекМаршрутизации() Экспорт
	
	Возврат Константы.ИмяФайлаНастроекМаршрутизации.Получить();
	
КонецФункции

// GitLabPersonalAccessToken returns the constant value from the private token of a GitLab user
// with access to the GitLab API.
// 
// Parameters:
// Returns:
// 	String - value of PRIVATE-TOKEN (max. 50 chars);
// 
Function GitLabPersonalAccessToken() Export
	
	Return Constants.GitLabPersonalAccessToken.Get();
	
EndFunction

// GitLabTimeout returns the constant value with the connection timeout to the GitLab server.
//
// Parameters:
// Returns:
// 	Number - the connection timeout, sec (0 - timeout is not set);
//
Function GitLabTimeout() Export
	
	Return Constants.GitLabTimeout.Get();

EndFunction

#EndRegion

#Region Private

// Получает значение настройки включения/отключения функционала обработки запросов от внешнего хранилища GitLab.
//
// Параметры:
// Возвращаемое значение:
// 	Булево - Истина - загружать, Ложь - загрузка запрещена;
//
Функция ОбрабатыватьЗапросыВнешнегоХранилища()
	
	Возврат Константы.ОбрабатыватьЗапросыВнешнегоХранилища.Получить();

КонецФункции

// ReceiverAccessToken returns the constant value used to connect to file delivery end-point services.
// 
// Parameters:
// Returns:
// 	String - the connection to the receiver token подключения к базе получателю (max. 20 chars);
//
Function ReceiverAccessToken()
	
	Return Constants.ReceiverAccessToken.Get();
	
EndFunction

// Получает значение константы с таймаутом соединения к веб-сервису информационной базы получателя.
//
// Параметры:
// Возвращаемое значение:
// 	Число - таймаут соединения, секунд (0 - таймаут не установлен);
//
Функция ТаймаутДоставкиФайла()
	
	Возврат Константы.ТаймаутДоставкиФайла.Получить();
	
КонецФункции

#EndRegion