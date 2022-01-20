﻿#language: ru

@UseMockserver

Функционал: Проверка сервисов загрузки внешних обработок

Как Пользователь
Я хочу проверять сервисы загрузки внешних обработок
Чтобы контролировать возможность загрузки файлов

Контекст:
	Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""
	И я закрыл все окна клиентского приложения
	И Я интерактивно заполняю настройки сервиса работы с GitLab тестовыми значениями
	И В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Настройки сервисов'
	Тогда открылось окно 'Настройки сервисов'
	И я нажимаю на кнопку с именем "CheckServiceStatus"

Сценарий: Предупреждение при незаполненном URL

	Тогда открылось окно 'Проверка статуса сервиса'
	И элемент формы с именем "StatusCode" стал равен 0
	И элемент формы с именем "ResponseBody" стал равен ''

	И в поле "URL" я ввожу текст ''
	И я нажимаю на кнопку с именем "CheckServiceStatus"
	И Пауза 1

	Затем я жду, что в сообщениях пользователю будет подстрока 'Поле "URL" не заполнено.' в течение 1 секунд
	И элемент формы с именем "StatusCode" стал равен 0
	И элемент формы с именем "ResponseBody" стал равен ''

	И я закрыл все окна клиентского приложения

Сценарий: Отображение отсутствия подключения к сервису по несуществующему URL

	Тогда открылось окно 'Проверка статуса сервиса'
	И элемент формы с именем "StatusCode" стал равен 0
	И элемент формы с именем "ResponseBody" стал равен ''

	И в поле "URL" я ввожу текст "http://блаблабла.ком"
	И я нажимаю на кнопку с именем "CheckServiceStatus"
	И Пауза 1

	Тогда элемент формы с именем "StatusCode" стал равен -1
	И я жду, что поле с именем "ResponseBody" перестанет быть пустым в течение 30 секунд
	И значение поля с именем "ResponseBody" содержит текст "Couldn't resolve host name"

	И я закрыл все окна клиентского приложения

Сценарий: Получение ответа от сервиса не требующего аутентификации

	Тогда открылось окно 'Проверка статуса сервиса'
	И элемент формы с именем "StatusCode" стал равен 0
	И элемент формы с именем "ResponseBody" стал равен ''

	Затем Я очищаю MockServer
	И Я создаю Expectation из файла "./test/expectations/noAuth.json"

	И в поле "URL" я ввожу текст "http://mockserver:1080/noAuth"
	И я нажимаю на кнопку с именем "CheckServiceStatus"
	И Пауза 1

	Тогда элемент формы с именем "StatusCode" стал равен 200
	И я жду, что поле с именем "ResponseBody" перестанет быть пустым в течение 5 секунд
	И значение поля с именем "ResponseBody" содержит текст "noAuth body"

	И я закрыл все окна клиентского приложения

Сценарий: Получение ответа от сервиса требующего аутентификацию BasicAuth

	Тогда открылось окно 'Проверка статуса сервиса'
	И элемент формы с именем "StatusCode" стал равен 0
	И элемент формы с именем "ResponseBody" стал равен ''

	Затем Я очищаю MockServer
	И Я создаю Expectation из файла "./test/expectations/basicAuth-200.json"
	И Я создаю Expectation из файла "./test/expectations/basicAuth-405.json"

	Подключение без аутентификации

		И я снимаю флаг с именем 'UseAuthFromSettings'
		И в поле "URL" я ввожу текст "http://mockserver:1080/basicAuth"
		И я нажимаю на кнопку с именем "CheckServiceStatus"
		И Пауза 1

		Тогда элемент формы с именем "StatusCode" стал равен 405
		И элемент формы с именем "ResponseBody" стал равен ''

	Подключение с аутентификацией указанной непосредственно в URL

		И я снимаю флаг с именем 'UseAuthFromSettings'
		И в поле "URL" я ввожу текст "http://User1:Password1@mockserver:1080/basicAuth"
		И я нажимаю на кнопку с именем "CheckServiceStatus"
		И Пауза 1

		Тогда элемент формы с именем "StatusCode" стал равен 200
		И я жду, что поле с именем "ResponseBody" перестанет быть пустым в течение 5 секунд
		И значение поля с именем "ResponseBody" содержит текст "basicAuth body"

	Подключение с неверной аутентификацией

		И я снимаю флаг с именем 'UseAuthFromSettings'
		И в поле "URL" я ввожу текст "http://User1:Password2@mockserver:1080/basicAuth"
		И я нажимаю на кнопку с именем "CheckServiceStatus"
		И Пауза 1

		Тогда элемент формы с именем "StatusCode" стал равен 405
		И элемент формы с именем "ResponseBody" стал равен ''

	Подключение с аутентификацией из настроек

		И я устанавливаю флаг с именем 'UseAuthFromSettings'
		И в поле "URL" я ввожу текст "http://mockserver:1080/basicAuth"
		И я нажимаю на кнопку с именем "CheckServiceStatus"
		И Пауза 1

		Тогда элемент формы с именем "StatusCode" стал равен 200
		И я жду, что поле с именем "ResponseBody" перестанет быть пустым в течение 5 секунд
		И значение поля с именем "ResponseBody" содержит текст "basicAuth body"

	И я закрыл все окна клиентского приложения

Сценарий: Сохранение предыдущих значений в полях формы

	Тогда открылось окно 'Проверка статуса сервиса'
	И элемент формы с именем "StatusCode" стал равен 0
	И элемент формы с именем "ResponseBody" стал равен ''

	И я устанавливаю флаг с именем 'UseAuthFromSettings'
	И в поле "URL" я ввожу текст "первое открытие формы"

	Затем я закрываю текущее окно
	И я нажимаю на кнопку с именем "CheckServiceStatus"
	
	Тогда открылось окно 'Проверка статуса сервиса'
	И элемент формы с именем "StatusCode" стал равен 0
	И элемент формы с именем "ResponseBody" стал равен ''
	И элемент формы с именем "URL" стал равен 'первое открытие формы'
	И флаг с именем 'UseAuthFromSettings' равен 'Да'

	И я закрыл все окна клиентского приложения
