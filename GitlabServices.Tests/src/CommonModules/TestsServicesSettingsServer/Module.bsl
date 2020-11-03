#Region Internal

// @unit-test
Процедура CurrentSettings(Фреймворк) Экспорт

	// given		
	Константы.HandleRequests.Установить(Истина);
	Константы.RoutingFileName.Установить("ИмяФайла.json");
	Константы.TokenGitLab.Установить("TokenGitLab");
	Константы.TimeoutGitLab.Установить(998);
	Константы.TokenReceiver.Установить("TokenReceiver");
	Константы.TimeoutDeliveryFile.Установить(999);
	// when
	Результат = ServicesSettings.CurrentSettings();
	// then
	Фреймворк.ПроверитьТип(Результат, "ФиксированнаяСтруктура");
	Фреймворк.ПроверитьРавенство(Результат.Количество(), 6);
	Фреймворк.ПроверитьИстину(Результат.IsHandleRequests);
	Фреймворк.ПроверитьРавенство(Результат.RoutingFileName, "ИмяФайла.json");
	Фреймворк.ПроверитьРавенство(Результат.TokenGitLab, "TokenGitLab");		
	Фреймворк.ПроверитьРавенство(Результат.TimeoutGitLab, 998);		
	Фреймворк.ПроверитьРавенство(Результат.TokenReceiver, "TokenReceiver");
	Фреймворк.ПроверитьРавенство(Результат.TimeoutDeliveryFile, 999);		

КонецПроцедуры

// @unit-test
Процедура RoutingFileName(Фреймворк) Экспорт

	// given		
	Константы.RoutingFileName.Установить("НовоеИмяФайла.json");
	// when
	Результат = ServicesSettings.RoutingFileName();
	// then
	Фреймворк.ПроверитьРавенство(Результат, "НовоеИмяФайла.json");

КонецПроцедуры

// @unit-test
Процедура TokenGitLab(Фреймворк) Экспорт

	// given		
	Константы.TokenGitLab.Установить("NewTokenGitLab");
	// when
	Результат = ServicesSettings.TokenGitLab();
	// then
	Фреймворк.ПроверитьРавенство(Результат, "NewTokenGitLab");

КонецПроцедуры

// @unit-test
Процедура TimeoutGitLab(Фреймворк) Экспорт

	// given		
	Константы.TimeoutGitLab.Установить(5);
	// when
	Результат = ServicesSettings.TimeoutGitLab();
	// then
	Фреймворк.ПроверитьРавенство(Результат, 5);

КонецПроцедуры

// @unit-test
Процедура TimeoutDeliveryFile(Фреймворк) Экспорт

	// given		
	Константы.TimeoutDeliveryFile.Установить(9);
	// when
	Результат = ServicesSettings.TimeoutDeliveryFile();
	// then
	Фреймворк.ПроверитьРавенство(Результат, 9);

КонецПроцедуры

// @unit-test
Процедура TokenReceiver(Фреймворк) Экспорт

	// given		
	Константы.TokenReceiver.Установить("NewTokenReceiver");
	// when
	Результат = ServicesSettings.TokenReceiver();
	// then
	Фреймворк.ПроверитьРавенство(Результат, "NewTokenReceiver");

КонецПроцедуры

#EndRegion
