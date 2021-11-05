#Region Internal

// @unit-test
Procedure CurrentSettings(Фреймворк) Export

	// given		
	Константы.HandleRequests.Установить(Истина);
	Константы.RoutingFileName.Установить("FileName.json");
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
	Фреймворк.ПроверитьРавенство(Результат.RoutingFileName, "FileName.json");
	Фреймворк.ПроверитьРавенство(Результат.TokenGitLab, "TokenGitLab");		
	Фреймворк.ПроверитьРавенство(Результат.TimeoutGitLab, 998);		
	Фреймворк.ПроверитьРавенство(Результат.TokenReceiver, "TokenReceiver");
	Фреймворк.ПроверитьРавенство(Результат.TimeoutDeliveryFile, 999);		

EndProcedure

// @unit-test
Procedure RoutingFileName(Фреймворк) Export

	// given		
	Константы.RoutingFileName.Установить("НовоеFileName.json");
	// when
	Результат = ServicesSettings.RoutingFileName();
	// then
	Фреймворк.ПроверитьРавенство(Результат, "НовоеFileName.json");

EndProcedure

// @unit-test
Procedure TokenGitLab(Фреймворк) Export

	// given		
	Константы.TokenGitLab.Установить("NewTokenGitLab");
	// when
	Результат = ServicesSettings.TokenGitLab();
	// then
	Фреймворк.ПроверитьРавенство(Результат, "NewTokenGitLab");

EndProcedure

// @unit-test
Procedure TimeoutGitLab(Фреймворк) Export

	// given		
	Константы.TimeoutGitLab.Установить(5);
	// when
	Результат = ServicesSettings.TimeoutGitLab();
	// then
	Фреймворк.ПроверитьРавенство(Результат, 5);

EndProcedure

// @unit-test
Procedure TimeoutDeliveryFile(Фреймворк) Export

	// given		
	Константы.TimeoutDeliveryFile.Установить(9);
	// when
	Результат = ServicesSettings.TimeoutDeliveryFile();
	// then
	Фреймворк.ПроверитьРавенство(Результат, 9);

EndProcedure

// @unit-test
Procedure TokenReceiver(Фреймворк) Export

	// given		
	Константы.TokenReceiver.Установить("NewTokenReceiver");
	// when
	Результат = ServicesSettings.TokenReceiver();
	// then
	Фреймворк.ПроверитьРавенство(Результат, "NewTokenReceiver");

EndProcedure

#EndRegion
