﻿#language: ru

@ExportScenarios
@ignoreoncimainbuild

Функционал: Заполнение настроек сервиса для работы с GitLab

Как Пользователь
Я хочу заполнить настройки сервиса 1С для работы GitLab предопределенными значениями
Чтобы протестировать функциональность сервисов

Контекст: 
	Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""
	И я закрыл все окна клиентского приложения

Сценарий: Я заполняю настройки сервиса работы с GitLab тестовыми значениями

	И я устанавливаю флаг 'Обрабатывать запросы внешнего хранилища'
	И в поле с именем "FormTokenGitLab" я ввожу текст "-U2ssrBsM4rmx85HXzZ1"
	И в поле с именем 'FormRoutingFileName' я ввожу текст ".ext-epf.json"
	И в поле с именем "FormTimeoutGitLab" я ввожу текст '5'
	И в поле с именем 'FormTokenendpoint' я ввожу текст "12345678901234567890"
	И в поле с именем "FormTimeoutDeliveryFile" я ввожу текст '5'
