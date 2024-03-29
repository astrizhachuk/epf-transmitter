﻿#language: ru

@ExportScenarios
@UseMockserver
@Tool
@ignoreoncimainbuild

Функционал: Работа с MockServer

Как Администратор
Я хочу иметь возможность управлять MockServer
Чтобы выполнить функциональное тестирование

Сценарий: Я очищаю MockServer
	Пусть я выполняю код встроенного языка
	"""bsl
		HTTPСоединение = Новый HTTPСоединение("mockserver", 1080);
		HTTPЗапрос = Новый HTTPЗапрос("/mockserver/reset");
		HTTPОтвет = HTTPСоединение.Записать(HTTPЗапрос);
	"""

Сценарий: Я очищаю MockServer на сервере
	Пусть я выполняю код встроенного языка на сервере
	"""bsl
		HTTPСоединение = Новый HTTPСоединение("mockserver", 1080);
		HTTPЗапрос = Новый HTTPЗапрос("/mockserver/reset");
		HTTPОтвет = HTTPСоединение.Записать(HTTPЗапрос);
	"""

Сценарий: Я создаю Expectation из файла "ПутьКФайлу"
	Пусть Я запоминаю значение выражения "ПутьКФайлу" в переменную "ПутьКФайлуОжидания"
	Тогда я выполняю код встроенного языка
	"""bsl
		HTTPСоединение = Новый HTTPСоединение("mockserver", 1080);
		Заголовки = Новый Соответствие;
		Заголовки.Вставить("Content-Type", "application/json; charset=utf-8");
		HTTPЗапрос = Новый HTTPЗапрос("/mockserver/expectation", Заголовки);
		HTTPЗапрос.УстановитьИмяФайлаТела("$КаталогПроекта$/$ПутьКФайлуОжидания$");
		HTTPОтвет = HTTPСоединение.Записать(HTTPЗапрос);
	"""

Сценарий: Я создаю Expectation из файла на сервере "ПутьКФайлу"
	Пусть Я запоминаю значение выражения "ПутьКФайлу" в переменную "ПутьКФайлуОжидания"
	Тогда я выполняю код встроенного языка на сервере
	"""bsl
		HTTPСоединение = Новый HTTPСоединение("mockserver", 1080);
		Заголовки = Новый Соответствие;
		Заголовки.Вставить("Content-Type", "application/json; charset=utf-8");
		HTTPЗапрос = Новый HTTPЗапрос("/mockserver/expectation", Заголовки);
		HTTPЗапрос.УстановитьИмяФайлаТела("$ПутьКФайлуОжидания$");
		HTTPОтвет = HTTPСоединение.Записать(HTTPЗапрос);
	"""

Сценарий: Я выполняю проверку запроса "ТекстЗапроса"
	Пусть Я запоминаю значение выражения "ТекстЗапроса" в переменную "Запрос"
	Тогда я выполняю код встроенного языка на сервере
	"""bsl
		HTTPСоединение = Новый HTTPСоединение("mockserver", 1080);
		Заголовки = Новый Соответствие;
		Заголовки.Вставить("Content-Type", "application/json; charset=utf-8");
		HTTPЗапрос = Новый HTTPЗапрос("/mockserver/verify", Заголовки);
		HTTPЗапрос.УстановитьТелоИзСтроки("$Запрос$");
		HTTPОтвет = HTTPСоединение.Записать(HTTPЗапрос);
		Объект().ПроверитьИстину(HTTPОтвет.КодСостояния = 202);
	"""
