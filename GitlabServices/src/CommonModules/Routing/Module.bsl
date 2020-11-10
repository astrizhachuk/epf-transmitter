#Region Internal

// TODO подумать об упрощении
// TODO подумать о возвращении отправки по доступным маршрутам, если файл не имеет описания в json

// FilesByRoutes returns remote files with delivery URLs.
// 
// Parameters:
// 	Commits - Map - deserialized commits from the GitLab request;
// 	RemoteFiles - ValueTable - files from the GitLab server with its descriptions:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the repository file (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
// Returns:
// 	Array of Structure:
// * FileName - String - file name; 
// * BinaryData - BinaryData - file data;
// * Routes - Array of String - delivery URLs;
// * ErrorInfo - String - description of an error while processing files;
//
Function FilesByRoutes( Val RemoteFiles, Val Commits ) Export
	
	Var FileRoutes;
	Var FileToSend;
	Var CommitSHA;
	Var Result;
	
	ROUTING_SETTINGS_MISSING_MESSAGE = NStr( "ru = '%1: отсутствуют настройки маршрутизации.';
										|en = '%1: there are no routing settings.'" );
										
	DELIVERY_ROUTE_MISSING_MESSAGE = NStr( "ru = '%1: не задан маршрут доставки файла.';
										|en = '%1: file delivery route not specified.'" );
	
	FileRoutes = FileRoutes( Commits );
	
	Result = New Array();
	
	For Each RemoteFile In RemoteFiles Do
		
		If ( IsSettingFile(RemoteFile) ) Then
			
			Продолжить;
			
		EndIf;
		
		FileToSend = FileToSend();
		
		ЗаполнитьЗначенияСвойств( FileToSend, RemoteFile );
		
		Если ( НЕ ПустаяСтрока(FileToSend.ErrorInfo) ) Тогда
			
			Result.Добавить(FileToSend);
			
			Продолжить;
			
		КонецЕсли;
			
		CommitSHA = FileRoutes.Получить( RemoteFile.CommitSHA );
	
		Если ( CommitSHA = Неопределено ) Тогда
			
			FileToSend.ErrorInfo = СтрШаблон( ROUTING_SETTINGS_MISSING_MESSAGE, RemoteFile.CommitSHA );

		Иначе

			FileToSend.Routes = CommitSHA.Получить( RemoteFile.FilePath );
			
			Если ( FileToSend.Routes = Неопределено ) Тогда

				FileToSend.ErrorInfo = СтрШаблон( DELIVERY_ROUTE_MISSING_MESSAGE, RemoteFile.CommitSHA );
				
			КонецЕсли;

		КонецЕсли;
		
		Result.Добавить( FileToSend );
		
	EndDo;
	
	Return Result;
	
EndFunction

// AddRoutingFilesDescription adds a description of files with Routing settings.
// 
// Parameters:
// 	Commits - Map - deserialized commits from the GitLab request;
//	ProjectId - String - project id from the GitLab request;
// 	RemoteFiles - ValueTable - files from the GitLab server with its descriptions:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the repository file (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
Procedure AddRoutingFilesDescription( RemoteFiles, Val Commits, Val ProjectId ) Export
	
	Var FilePath;
	Var CommitSHA;
	Var RAWFilePath;
	Var NewDescription;
	
	If ( Commits = Undefined ) Then
		
		Return;
		
	EndIf;

	FilePath = ServicesSettings.CurrentSettings().RoutingFileName;
	
	For Each Commit In Commits Do

		NewDescription = RemoteFiles.Add();
		CommitSHA = Commit.Get( "id" );
		RAWFilePath = GitLab.RAWFilePath( ProjectId, FilePath, CommitSHA );
		NewDescription.RAWFilePath = RAWFilePath;
		NewDescription.FilePath = FilePath;
		NewDescription.Action = "";
		NewDescription.Date = Commit.Get( "timestamp" );
		NewDescription.CommitSHA = CommitSHA;
	
	EndDo;

EndProcedure

// AppendQueryDataByRoutingSettings adds file Routing settings deserialized from JSON to the request data.
// 
// Parameters:
// 	Commits - Map - deserialized commits from the GitLab request;
// 	RemoteFiles - ValueTable - files from the GitLab server with its descriptions:
// * RAWFilePath - String - relative URL path to the RAW file;
// * FileName - String - file name;
// * FilePath - String - relative path to the repository file (with the filename);
// * BinaryData - BinaryData - file data;
// * Action - String - file operation type: "added", "modified", "removed";
// * Date - Date - date of operation on the file;
// * CommitSHA - String - сommit SHA;
// * ErrorInfo - String - description of an error while processing files;
//
Procedure AppendQueryDataByRoutingSettings( Commits, Val RemoteFiles ) Export
	
	Var FilePath;
	Var Filter;
	Var File;
	Var Stream;
	Var Settings;

	FilePath = ServicesSettings.CurrentSettings().RoutingFileName;	
	
	For Each Commit In Commits Do
		
		Filter = New Structure();
		Filter.Insert( "CommitSHA", Commit.Get( "id" ) );
		Filter.Insert( "FilePath", FilePath );
		Filter.Insert( "Action", "" );
		Filter.Insert( "ErrorInfo", "" );
		
		File = RemoteFiles.FindRows( Filter );
		
		If ( NOT ValueIsFilled(File) ) Then
			
			Continue;
			
		EndIf;
		
		Stream = File[0].BinaryData.OpenStreamForRead();
		Settings = HTTPConnector.JsonВОбъект( Stream );
		CommonUseServerCall.AppendCollectionFromStream( Settings, "json", Stream );
		
		Commit.Insert( "settings", Settings );
		
	EndDo;
	
EndProcedure
 
#EndRegion

#Region Private

// File returns a description of the file to delivery it to the receivers.
//
// Returns:
// 	Structure - description:
// * FileName - String - file name; 
// * BinaryData - BinaryData - file data;
// * Routes - Array of String - delivery URLs;
// * ErrorInfo - String - description of an error while processing files;
//
Function FileToSend()
	
	Var Result;
	
	Result = New Structure();
	Result.Insert( "FileName", "" );
	Result.Insert( "BinaryData", Undefined );
	Result.Insert( "Routes", Undefined );
	Result.Insert( "ErrorInfo", "" );
	
	Return Result;
	
EndFunction

// FileRoutes returns delivery URLs.
// Routes are taken from the settings file (see ServicesSettings.RoutingFileName) or from user settings.
// For user settings, the priority is higher than for settings from the file.
// 
// Parameters:
// 	Commits - Map - deserialized commits from the GitLab request;
// 	
// Returns:
// 	Map - description:
// 	* Key - String - commit SHA;
// 	* Value - Map - description;
// 	** Key - String - relative path to the repository file (with the filename);
// 	** Value - Array of String - file delivery end-point service URLs;
//
Function FileRoutes( Val Commits )

	Var Settings;
	Var Result;
	
	Result = New Map();
	
	For Each Commit In Commits Do
		
		Settings = Commit.Get( "user_settings" );
		
		If ( Settings = Undefined ) Then
			
			Settings = Commit.Get( "settings" );
			
		EndIf;
		
		If ( Settings = Undefined ) Then
			
			Continue;
			
		EndIf;
		
		Result.Insert( Commit.Get( "id" ), Routes( Settings ) );

	EndDo;
	
	Return Result;
	
EndFunction

Function IsSettingFile( Val File )
	
	Return IsBlankString( File.Action );
	
EndFunction

// EnabledServices returns a list of enabled file delivery services with its URL from the Routing settings.
// 
// Parameters:
// 	Settings - Map - deserialized Routing settings;
// 	  
// Returns:
// 	Map - enabled file delivery services:
//	* Key - Sting - service name;
//	* Value - Sting - service URL;
//
Function EnabledServices( Val Settings )

	Var Services;
	Var ServiceName;
	Var IsServiceEnabled;
	Var URL;
	Var Result;
	
	Result = New Map();
	
	Services = Settings.Get( "ws" );
	
	If ( Services = Undefined ) Then
		
		Return Result;
		
	EndIf;
	
	For Each Service In Services Do
		
		ServiceName = Service.Get( "name" );
		
		If ( ServiceName = Undefined ) Then
			
			Continue;
			
		EndIf;
		
		IsServiceEnabled = Service.Get( "enabled" );
		
		If ( IsServiceEnabled = Undefined OR NOT IsServiceEnabled ) Then
			
			Continue;
			
		EndIf;
			
		URL = Service.Get( "address" );
		
		If ( URL = Undefined ) Then
			
			Continue;
			
		EndIf;
		
		Result.Insert( ServiceName, URL );

	EndDo;
	
	Return Result;
	
EndFunction

Функция АдресаДоставкиПоПравиламИсключения( Знач СервисыДоставки, Знач ИсключаемыеСервисы )
	
	Var Результат;
	
	Результат = Новый Массив();
	
	Для Каждого Элемент Из СервисыДоставки Цикл
		
		Если ( ИсключаемыеСервисы = Неопределено ИЛИ ИсключаемыеСервисы.Найти(Элемент.Ключ) = Неопределено ) Тогда
	
			Результат.Добавить( Элемент.Значение );
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Возвращает адреса доставки файлов по данным настройки маршрутизации.
// 
// Параметры:
// 	Settings - Соответствие - преобразованные в коллекцию настройки маршрутизации;
// 	
// Returns:
// 	Соответствие - описание:
// 	*Ключ - Строка - полное имя файла;
// 	*Значение - Массив из Строка - перечень адресов доставки файла;
//
Function Routes( Val Settings )
	
	Var EnabledServices;
	Var FilePath;
	Var ExcludedServices;
	Var URLs;
	Var Result;
	
	EnabledServices = EnabledServices( Settings );
	Routes = Settings.Get( "epf" );
	
	Result = New Map();
	
	For Each Route In Routes Do
		
		FilePath = Route.Get( "name" );
		
		If ( FilePath = Undefined ) Then
			
			Continue;
			
		EndIf;
		
		ExcludedServices = Route.Get( "exclude" );
		URLs = АдресаДоставкиПоПравиламИсключения( EnabledServices, ExcludedServices );

		Result.Insert( FilePath, URLs );
		
	EndDo;
	
	Return Result;
	
EndFunction

#EndRegion