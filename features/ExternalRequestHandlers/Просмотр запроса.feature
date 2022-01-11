﻿#language: ru

@UseMockserver

Функционал: Просмотр запроса с сервера GitLab

Как Пользователь
Я хочу иметь возможность просматривать полученный с сервера GitLab запрос
Чтобы анализировать и изменять данные запроса

Контекст:
	Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""
	И Я очищаю MockServer
	И Я создаю Expectation из файла "/test/expectations/routing.json"
	И Я создаю Expectation из файла "/test/expectations/push.json"
	И я удаляю все элементы Справочника "ExternalRequestHandlers"
	И я удаляю все записи РегистрСведений "ExternalRequests"
	И я удаляю все записи РегистрСведений "RemoteFiles"
	И я закрыл все окна клиентского приложения
	И Я заполняю настройки сервиса работы с GitLab тестовыми значениями
	И В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Обработчики внешних запросов'
	Тогда открылось окно 'Обработчики внешних запросов'
	И Я добавляю обработчик событий "Тест обработки запроса" проекта "http://mockserver:1080/root/external-epf" с ключом "Token1"
	#И Я добавляю обработчик событий "Тест обработки запроса" с ключом "gita"

Сценарий: Я проверяю сохраненный запрос в редакторе JSON

	Пусть Я отправляю "Push Hook" запрос с токеном "Token1" и телом из файла "/test/requests/push.json" для сервиса "/api/ru/hs/gitlab/events/push"
	#И Я отправляю "Push Hook" запрос с токеном "gita" и телом из файла "/home/usr1cv8/test/request-epf-push-2.json" для сервиса "/api/ru/hs/gitlab/events/push"
	И Пауза 2

	Когда в таблице "List" я перехожу к строке:
		| 'Наименование'           | 'Код'       | 'URL'                                      | 'Токен'  |
		| 'Тест обработки запроса' | '000000001' | 'http://mockserver:1080/root/external-epf' | 'Token1' |

	И в таблице "List" я выбираю текущую строку

	И в таблице "ReceivedRequests" я перехожу к строке:
		| 'checkout_sha'                             |
		| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
	И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenQueryJSON'
	
	Тогда открылось окно 'Запрос'
	И элемент формы с именем "GroupCommits" существует и невидим на форме
	И элемент формы с именем "GroupCustomSettings" существует и невидим на форме
	И элемент с именем "CommitsQueryJSON" доступен только для просмотра
	И значение поля "CommitsQueryJSON" содержит текст "\"checkout_sha\": \"1b9949a21e6c897b3dcb4dd510ddb5f893adae2f\","
	И значение поля "CommitsQueryJSON" не содержит текст "\"checkout_sha\": \"2b9949a21e6c897b3dcb4dd510ddb5f893adae2f\","
	И я закрываю окно 'Запрос'
	И я жду закрытия окна 'Запрос' в течение 2 секунд

	Когда в таблице "ReceivedRequests" я перехожу к строке:
		| 'checkout_sha'                             |
		| '2b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
	И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenQueryJSON'

	Тогда открылось окно 'Запрос'
	И элемент формы с именем "GroupCommits" существует и невидим на форме
	И элемент формы с именем "GroupCustomSettings" существует и невидим на форме
	И элемент с именем "CommitsQueryJSON" доступен только для просмотра
	И значение поля "CommitsQueryJSON" содержит текст "\"checkout_sha\": \"2b9949a21e6c897b3dcb4dd510ddb5f893adae2f\","
	И значение поля "CommitsQueryJSON" не содержит текст "\"checkout_sha\": \"1b9949a21e6c897b3dcb4dd510ddb5f893adae2f\","
	И я закрываю окно 'Запрос'
	И я жду закрытия окна 'Запрос' в течение 2 секунд

	И Я закрываю окно 'Тест обработки запроса (Обработчики внешних запросов)'
	И я жду закрытия окна 'Тест обработки запроса (Обработчики внешних запросов) *' в течение 2 секунд
