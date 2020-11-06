#Region Public

// ConnectionParams returns the connection parameters to the GitLab server.
// 
// Parameters:
// 	URL - String - URL to GitLab server, for example: "http://www.example.org";
//
// Returns:
//	Structure - description:
// * URL - String - URL to GitLab server;
// * Token - String - access token to the server from the current settings;
// * Timeout - Number - the connection timeout from the current settings, sec (0 - timeout is not set);
//
Function ConnectionParams( Val URL ) Export
	
	Var CurrentSettings;
	Var Result;
	
	CurrentSettings = ServicesSettings.CurrentSettings();
	
	Result = New Structure();
	Result.Insert( "URL", URL );
	Result.Insert( "Token", CurrentSettings.TokenGitLab );
	Result.Insert( "Timeout", CurrentSettings.TimeoutGitLab );
	
	Return Result;
	
EndFunction

// RemoteFile returns the file from the GitLab server with its description.
// 
// Parameters:
// 	ConnectionParams - (See GitLab.ConnectionParams)
// 	RAWFilePath - Строка - закодированный в URL кодировке относительный путь к получаемому файлу, например,
// 							"/api/v4/projects/1/repository/files/D0%BA%D0%B0%201.epf/raw?ref=ef3529e5486ff";
// 	
// Returns:
//	Structure - description:
// * RAWFilePath - Строка - относительный путь к RAW файлу;
// * FileName - Строка - имя файла в кодировке UTF-8;
// * BinaryData - BinaryData - данные файла;
// * ErrorInfo - Строка - текст с описанием ошибки получения файла с сервера;
//
Function RemoteFile( Val ConnectionParams, Val RAWFilePath ) Export

	Var URL;
	Var Headers;
	Var AdditionalParams;
	Var Response;
	
	Var FileName;
	Var Message;
	Var ErrorInfo;
	
	Var Result;
	
	Result = RemoteFileDescription();
	Result.RAWFilePath = RAWFilePath;

	URL = ConnectionParams.URL + RAWFilePath;

	Try
	
		Headers = New Map();
		Headers.Insert( "PRIVATE-TOKEN", ConnectionParams.Token );
		
		AdditionalParams = New Structure();
		AdditionalParams.Insert( "Заголовки", Headers );
		AdditionalParams.Insert( "Таймаут", ConnectionParams.Timeout );
		
		Response = HTTPConnector.Get( URL, Undefined, AdditionalParams );

		If ( NOT HTTPStatusCodesClientServerCached.isOk(Response.КодСостояния) ) Then
			
			Raise HTTPStatusCodesClientServerCached.FindIdByCode( Response.КодСостояния );
		
		EndIf;
		
		FileName = Response["Заголовки"].Get( "X-Gitlab-File-Name" );
		
		If ( FileName = Undefined ) Then
			
			Raise NStr( "ru = 'Файл не найден.';en = 'File not found.'" );
			
		EndIf;

		If ( NOT ValueIsFilled(Response["Тело"]) ) Then
			
			Raise NStr( "ru = 'Пустой файл.';en = 'File is empty.'" );
			
		EndIf;

		Result.FileName = FileName;
		Result.BinaryData = Response["Тело"];
		
	Except
	
		Message = NStr( "ru = 'Ошибка получения файла: %1';en = 'Error getting file: %1'" );
		ErrorInfo = URL + Chars.LF + ErrorProcessing.DetailErrorDescription( ErrorInfo() );
		Result.ErrorInfo = StrTemplate( Message, ErrorInfo );
		
	EndTry;
	
	Return Result;
	
EndFunction

// Получает с сервера GitLab файлы и формирует их описание.
// 
// Параметры:
// 	ConnectionParams - (См. GitLab.ConnectionParams)
// 	ПутиКФайлам - Массив из Строка - массив закодированных в URL кодировке относительных путей к получаемым файлам,
//					например, "/api/v4/projects/1/repository/files/D0%BA%D0%B0%201.epf/raw?ref=ef3529e5486ff";
// 	
// Returns:
// 	Массив из Структура:
// * RAWFilePath - Строка - относительный путь к RAW файлу;
// * FileName - Строка - имя файла в кодировке UTF-8;
// * BinaryData - BinaryData - данные файла;
// * ErrorInfo - Строка - текст с описанием ошибки получения файла с сервера;
// 
Function RemoteFiles( Val ПараметрыСоединения, Val ПутиКФайлам ) Export
	
	Var Результат;

	Результат = Новый Массив;
	
	Для Каждого RAWFilePath Из ПутиКФайлам Цикл
		
		Результат.Добавить( RemoteFile(ПараметрыСоединения, RAWFilePath) );
		
	КонецЦикла;
	
	Возврат Результат;

EndFunction

// RemoteFilesEmpty returns an empty remote files collection.
// 
// Returns:
//	ValueTable - description:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * URLFilePath - String - relative URL path to the file (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
Function RemoteFilesEmpty() Export
	
	Var Result;
	
	Result = GitLabCached.RemoteFilesEmpty();
	Result.Clear(); // ValueTable is cached, so we exclude returning a filled values.

	Return Result;
	
EndFunction

// Возвращает описание файлов и сами файлы, которые необходимо распределить по информационным базам получателям.
// 
// Parameters:
//	Webhook - CatalogRef.ОбработчикиСобытий - a ref to webhook;
// 	QueryData - Map - GitLab request body deserialized from JSON;
//
// Returns:
//	ValueTable - description:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * URLFilePath - String - relative URL path to the file (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
Function FilesByQueryData( Val Webhook, QueryData ) Export
	
	Var LoggingOptions;
	Var ПараметрыПроекта;
	Var ПараметрыСоединения;
	Var Результат;
	
	EVENT_MESSAGE_BEGIN = NStr( "ru = 'Core.ПолучениеФайловGitLab.Начало';en = 'Core.ReceivingFilesGitLab.Begin'" );
	EVENT_MESSAGE = NStr( "ru = 'Core.ПолучениеФайловGitLab';en = 'Core.ReceivingFilesGitLab'" );
	EVENT_MESSAGE_END = NStr( "ru = 'Core.ПолучениеФайловGitLab.Окончание';en = 'Core.ReceivingFilesGitLab.End'" );
	
	RECEIVING_MESSAGE = NStr( "ru = 'получение файлов с сервера...';en = 'receiving files from the server...'" );
	
	LoggingOptions = Логирование.ДополнительныеПараметры( Webhook ); 
	Логирование.Информация( EVENT_MESSAGE_BEGIN, RECEIVING_MESSAGE, LoggingOptions );	

	ПараметрыПроекта = ProjectDescription( QueryData );
	Результат = ДействияНадФайламиПоДаннымЗапроса( QueryData, ПараметрыПроекта );
	Результат = ОписаниеФайловСрезПоследних( Результат );
	Маршрутизация.СформироватьОписаниеФайловМаршрутизации( Результат, QueryData, ПараметрыПроекта );

	ПараметрыСоединения = ConnectionParams( ПараметрыПроекта.URL );
	
	ЗаполнитьОтправляемыеДанныеФайлами( Результат, ПараметрыСоединения );	

	Для Каждого ОписаниеФайла Из Результат Цикл
		
		Если ( НЕ ПустаяСтрока(ОписаниеФайла.ErrorInfo) ) Тогда
			
			Логирование.Ошибка( EVENT_MESSAGE, ОписаниеФайла.ErrorInfo, LoggingOptions );
			
		КонецЕсли;
			
	КонецЦикла;
	
	Логирование.Информация( EVENT_MESSAGE_END, RECEIVING_MESSAGE, LoggingOptions );	

	Возврат Результат;	
	
EndFunction

// ProjectDescription returns a description of the project from the GitLab request data.
// 
// Parameters:
//	QueryData - Map - GitLab request body deserialized from JSON;
//
// Returns:
// 	Structure - description:
// * Id - String - project id;
// * URL - String - URL to GitLab server, for example: "http://www.example.org";
// 
Function ProjectDescription( Val QueryData ) Export
	
	Var Project;
	Var URL;
	Var Delim;

	Var Result;
	
	Project = QueryData.Get( "project" );
	URL = Project.Get( "http_url" );
	
	Delim = StrFind( URL, "/", , , 3 ) - 1;
	
	If ( Delim > 0 ) Then
		
		URL = Left( URL, Delim );
		
	EndIf;	
			
	Result = New Structure();
	Result.Insert( "Id", String(Project.Get("id")) );
	Result.Insert( "URL", URL );	

	Return Result;
	
EndFunction

// MergeRequests returns all GitLab Merge Requests deserialized from JSON for one project.
// 
// Parameters:
// 	URL - String - URL to GitLab server, for example: "http://www.example.org";
// 	Id - String - project id;
//
// Returns:
//   Array, Map, Structure - Merge Requests deserialized from JSON;
//
Function MergeRequests( Val URL, Val Id ) Export
	
	Var ConnectionParams;
	Var Headers;
	Var AdditionalParams;
	
	ConnectionParams = ConnectionParams( URL );
	
	Headers = New Map();
	Headers.Insert( "PRIVATE-TOKEN", ConnectionParams.Token );
		
	AdditionalParams = New Structure();
	AdditionalParams.Insert( "Заголовки", Headers );
	AdditionalParams.Insert( "Таймаут", ConnectionParams.Timeout );
	
	URL = ConnectionParams.URL + MergeRequestsPath( Id );

	Return HTTPConnector.GetJson( URL, Undefined, AdditionalParams );
	
EndFunction

#EndRegion

#Region Internal

// Возвращает перекодированный в URL относительный путь к RAW файлу. 
// 
// Параметры:
// 	ProjectId - Строка - id проекта;
// 	URLFilePath - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
// 	Commit - Строка - сommit SHA;
// 
// Returns:
// 	Строка - перекодированный в URL относительный путь к файлу.
//
Function RAWFilePath( Val ProjectId, Val URLFilePath, Val Commit ) Export
	
	Var Шаблон;
	
	Шаблон = "/api/v4/projects/%1/repository/files/%2/raw?ref=%3";
	URLFilePath = КодироватьСтроку( URLFilePath, СпособКодированияСтроки.КодировкаURL );
	
	Возврат СтрШаблон( Шаблон, ProjectId, URLFilePath, Commit );
	
EndFunction

#EndRegion

#Region Private

Function MergeRequestsPath( Val ProjectId )
	
	Return StrTemplate( "/api/v4/projects/%1/merge_requests", String(ProjectId) );
	
EndFunction

// FileActions returns a list of possible actions on files in accordance with the GitLab REST API.
// 
// Returns:
// 	Массив - "added", "modified", "removed";
//
Function FileActions()
		
	Возврат GitLabCached.FileActions();
	
EndFunction

// Возвращает результат проверки, что файл является скомпилированным файлом внешнего отчета или обработки.
// 
// Параметры:
// 	URLFilePath - Строка - относительный путь к файлу в репозитории (вместе с именем файла);
//
// Returns:
// 	Булево - Истина - это скомпилированный файл, иначе - Ложь;
//
Function ЭтоСкомпилированныйФайл( Val URLFilePath )
	
	Возврат ( СтрЗаканчиваетсяНа(URLFilePath, ".epf") ИЛИ СтрЗаканчиваетсяНа(URLFilePath, ".erf") );
	
EndFunction

Function ОписаниеФайловСрезПоследних( Val ОписаниеФайлов, Val Action = "modified" )
	
	Var Результат;
	Var ПараметрыОтбора;
	Var НайденныеСтроки;
	
	Результат = ОписаниеФайлов.СкопироватьКолонки();
	ПолныеИменаФайлов = CommonUseClientServer.CollapseArray( ОписаниеФайлов.ВыгрузитьКолонку("URLFilePath") );
	
	Если ( НЕ ЗначениеЗаполнено(ПолныеИменаФайлов) ) Тогда
		
		Возврат Результат;
	
	КонецЕсли;
	
	ОписаниеФайлов.Сортировать( "Date Убыв" );
	
	ПараметрыОтбора = Новый Структура( "URLFilePath, Action" );
	ПараметрыОтбора.Action = Action;
			
	Для каждого URLFilePath Из ПолныеИменаФайлов Цикл

		ПараметрыОтбора.URLFilePath = URLFilePath;
		НайденныеСтроки = ОписаниеФайлов.НайтиСтроки( ПараметрыОтбора );

		Если ( НЕ ЗначениеЗаполнено(НайденныеСтроки) ) Тогда

			Продолжить;
								
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств( Результат.Добавить(), НайденныеСтроки[0] );
		
	КонецЦикла;

	Возврат Результат;
	
EndFunction

Function ДействияНадФайламиПоДаннымЗапроса( Val ДанныеЗапроса, Val ПараметрыПроекта )
	
	Var Commits;
	Var CommitSHA;
	Var Date;
	Var ПолныеИменаФайлов;
	Var RAWFilePath;
	Var НоваяСтрока;
	Var Результат;
	
	Commits = ДанныеЗапроса.Получить( "commits" );
	Результат = RemoteFilesEmpty();
	
	Для каждого Commit Из Commits Цикл

		CommitSHA = Commit.Получить( "id" );
		Date = Commit.Получить( "timestamp" );
		
		Для каждого Action Из FileActions() Цикл

			ПолныеИменаФайлов = Commit.Получить( Action );

			Для каждого URLFilePath Из ПолныеИменаФайлов Цикл
				
				Если ( НЕ ЭтоСкомпилированныйФайл(URLFilePath) ) Тогда
					
					Продолжить;

				КонецЕсли;

				НоваяСтрока = Результат.Добавить();
				RAWFilePath = RAWFilePath( ПараметрыПроекта.Id, URLFilePath, CommitSHA );
				НоваяСтрока.RAWFilePath = RAWFilePath;
				НоваяСтрока.URLFilePath = URLFilePath;
				НоваяСтрока.Action = Action;
				НоваяСтрока.Date = Date;
				НоваяСтрока.CommitSHA = CommitSHA;

			КонецЦикла;

		КонецЦикла;
		
	КонецЦикла;
	
	Возврат Результат;
	
EndFunction

Процедура ЗаполнитьОтправляемыеДанныеФайлами( ОтправляемыеДанные, Val ПараметрыСоединения )

	Var ПутиКФайлам;
	Var Файл;
	Var Файлы;

	ПутиКФайлам = ОтправляемыеДанные.ВыгрузитьКолонку( "RAWFilePath" );
	Файлы = RemoteFiles( ПараметрыСоединения, ПутиКФайлам );
	
	Для каждого ОписаниеФайла Из Файлы Цикл
			
		Файл = ОтправляемыеДанные.Найти( ОписаниеФайла.RAWFilePath, "RAWFilePath" );
		ЗаполнитьЗначенияСвойств( Файл, ОписаниеФайла );

	КонецЦикла;

КонецПроцедуры

Function RemoteFileDescription()

	Var Result;
	
	Result = New Structure();
	Result.Insert( "RAWFilePath", "" );
	Result.Insert( "FileName", "" );
	Result.Insert( "BinaryData", Undefined );
	Result.Insert( "ErrorInfo", "" );
	
	Return Result;

EndFunction

#EndRegion