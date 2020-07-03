#Область ПрограммныйИнтерфейс

// TODO описание

// Параметры доставки данных до веб-сервиса обслуживания внешних отчетов и обработок в информационной базе получателе.
// 
// Параметры:
// Возвращаемое значение:
// 	Структура - Описание:
// * АдресДоставки - Строка - end-point веб-сервиса обновления внешних отчетов и обработок;
// * Token - Строка - token доступа к сервису получателя;
// * Таймаут - Число - таймаут соединения с сервисом, секунд (если 0 - таймаут не устанавлен);
//
Функция ПараметрыСервисаПолучателя() Экспорт
	
	Перем Результат;
	
	Результат = Новый Структура();
	Результат.Вставить( "Token", AccessTokenReceiver() );
	Результат.Вставить( "Таймаут", ТаймаутДоставкиПолучатель() );
	
	Возврат Результат;
	
КонецФункции




























// Подготавливает структуру со всеми текущими настройками механизмов управления сервисами GitLab.
// 
// Параметры:
// Возвращаемое значение:
// ФиксированнаяСтруктура - описание:
// * ТаймаутДоставкиПолучатель - Число - (См. Константа.ТаймаутДоставкиПолучатель);
// * ТаймаутGitLab - Число - (См. Константа.ТаймаутGitLab);
// * AccessTokenReceiver - Строка - (См. Константа.AccessTokenReceiver);
// * ИмяФайлаНастроекМаршрутизации - Строка - (См. Константа.ИмяФайлаНастроекМаршрутизацииGitLab);
// * GitLabUserPrivateToken - Строка - (См. Константа.GitLabUserPrivateToken);
// * ЗагружатьФайлыИзВнешнегоХранилища - Булево - (См. Константа.ЗагружатьФайлыИзВнешнегоХранилища);
Функция НастройкиСервисовGitLab() Экспорт
	
	Перем Настройки;
	Перем ТекстСообщения;
	
	Настройки = Новый Структура;
	Настройки.Вставить("ЗагружатьФайлыИзВнешнегоХранилища", Ложь);
	Настройки.Вставить("GitLabUserPrivateToken", "");
	Настройки.Вставить("ИмяФайлаНастроекМаршрутизации", "");
	Настройки.Вставить("AccessTokenReceiver", "");
	Настройки.Вставить("ТаймаутGitLab", 0);
	Настройки.Вставить("ТаймаутДоставкиПолучатель", 0);
//	Настройки.Вставить("МестоположениеСервисаИБПолучателя", "");
	
	Попытка
		
		Настройки.ЗагружатьФайлыИзВнешнегоХранилища = Константы.ЗагружатьФайлыИзВнешнегоХранилища.Получить();
		Настройки.GitLabUserPrivateToken            = GitLabUserPrivateToken();
		Настройки.ИмяФайлаНастроекМаршрутизации     = ИмяФайлаНастроекМаршрутизации();
		Настройки.AccessTokenReceiver    = AccessTokenReceiver();
		Настройки.ТаймаутGitLab       = ТаймаутGitLab();
		Настройки.ТаймаутДоставкиПолучатель = ТаймаутДоставкиПолучатель();
		//Настройки.МестоположениеСервисаИБПолучателя = МестоположениеСервисаИБПолучателя();
		
		Настройки = Новый ФиксированнаяСтруктура(Настройки);
		
	Исключение
		ТекстСообщения = СтрШаблон(НСтр("ru = '%1'"), ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Логирование.Ошибка( "System.Настройки", ТекстСообщения );
		ВызватьИсключение;
	КонецПопытки;
	
	Возврат Настройки;
	
КонецФункции

// Получает значение константы с именем файла настроек маршрутизации, расположенном в корне репозитория GitLab.
//
// Параметры:
// Возвращаемое значение:
// 	Строка - возвращает имя файла (макс. 50), при незаполненном значении вызывается исключение.
Функция ИмяФайлаНастроекМаршрутизации() Экспорт
	
	Перем ИмяФайлаНастроекМаршрутизации;
	
	ИмяФайлаНастроекМаршрутизации = Константы.ИмяФайлаНастроекМаршрутизацииGitLab.Получить();
	ОбщегоНазначенияКлиентСервер.Проверить(НЕ ПустаяСтрока(ИмяФайлаНастроекМаршрутизации),
		НСтр("ru = 'Настройка ""Имя файла настроек маршрутизации"" должна быть заполнена.'"),
		"СервисыGitLab.ИмяФайлаНастроекМаршрутизации");
	
	Возврат ИмяФайлаНастроекМаршрутизации;
	
КонецФункции

// Получает значение константы с private token пользователя GitLab, имеющего доступ к api GitLab.
// 
// Параметры:
// Возвращаемое значение:
// 	Строка - возвращает значение PRIVATE-TOKEN (макс. 50), при незаполненном значении вызывается исключение. 
Функция GitLabUserPrivateToken() Экспорт
	
	Перем GitLabUserPrivateToken;
	
	GitLabUserPrivateToken = Константы.GitLabUserPrivateToken.Получить();
	ОбщегоНазначенияКлиентСервер.Проверить(НЕ ПустаяСтрока(GitLabUserPrivateToken),
		НСтр("ru = 'Настройка ""GitLab user private token"" должна быть заполнена.'"),
		"СервисыGitLab.GitLabUserPrivateToken");
	
	Возврат GitLabUserPrivateToken;
	
КонецФункции




// Получает значение константы с таймаутом соединения к серверу GitLab.
//
// Параметры:
// Возвращаемое значение:
// 	Число - секунд (если 0 - таймаут не устанавлен);
Функция ТаймаутGitLab() Экспорт
	Возврат ТаймаутСоединения("ТаймаутGitLab");
КонецФункции



#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Получает значение константы AccessTokenReceiver, используемое для подключения к сервисам
// конечных точек доставки файлов.
// 
// Параметры:
// Возвращаемое значение:
// 	Строка - возвращает AccessTokenReceiver подключения к базам-получателям (макс. 20);
// 
Функция AccessTokenReceiver()
	
	Перем Результат;
	
	Результат = Константы.AccessTokenReceiver.Получить();
	
	Возврат Результат;
	
КонецФункции

// Получает значение константы с таймаутом соединения к веб-сервису информационной базы получателя.
//
// Параметры:
// Возвращаемое значение:
// 	Число - секунд (если 0 - таймаут не устанавлен);
//
Функция ТаймаутДоставкиПолучатель()
	
	Возврат ТаймаутСоединения( "ТаймаутДоставкиПолучатель" );
	
КонецФункции

// Получает значение таймаута соединения из константы. Если константа не найдена, то таймаут не устанавливается (=0).
// 
// Параметры:
// 	ИмяКонстанты - Строка - имя константы, в которой хранится значение таймаута;
// 
// Возвращаемое значение:
// 	Число - секунд (если 0 - таймаут не устанавлен);
//
Функция ТаймаутСоединения( Знач ИмяКонстанты )

	Возврат ?(Метаданные.Константы.Найти(ИмяКонстанты) = Неопределено, 0, Константы[ИмяКонстанты].Получить());
	
КонецФункции

#КонецОбласти