#Region Internal

// @unit-test
Procedure ПерекодироватьСтроку(Фреймворк) Экспорт
	
	// given
	Эталон_UTF8 = "тестовая строка";
	Эталон_KOI8_R = "я┌п╣я│я┌п╬п╡п╟я▐ я│я┌я─п╬п╨п╟";
	// when
	Кодировка_KOI8_R = StringsClientServer.Encode(Эталон_UTF8, "UTF-8", "KOI8-R");
	Кодировка_UTF8 = StringsClientServer.Encode(Кодировка_KOI8_R, "KOI8-R");
	// then
	Фреймворк.ПроверитьРавенство(Кодировка_KOI8_R, Эталон_KOI8_R); 
	Фреймворк.ПроверитьРавенство(Кодировка_UTF8, Эталон_UTF8);
	
EndProcedure

#EndRegion