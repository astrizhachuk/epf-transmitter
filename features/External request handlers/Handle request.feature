﻿#language: ru

@UseMockserver
@Timer

Функционал: Перехват и обработка запроса с сервера GitLab

Как Пользователь
Я хочу иметь возможность получить и обработать запрос с сервера GitLab
Чтобы проанализировать его и повторно обработать в случае необходимости

Контекст:
	Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""
	И Я очищаю MockServer
	И Я создаю Expectation из файла "/test/expectations/raw-epf.json"
	И Я создаю Expectation из файла "/test/expectations/routes.json"
	И Я создаю Expectation из файла "/test/expectations/endpoints.json"
	И я удаляю все элементы Справочника "ExternalRequestHandlers"
	И я удаляю все записи РегистрСведений "ExternalRequests"
	И я удаляю все записи РегистрСведений "RemoteFiles"
	И я проверяю или создаю для справочника "ExternalRequestHandlers" объекты:
	 	| 'Ref'                                                                             | 'DeletionMark' | 'Code'      | 'Description'            | 'ProjectURL'                               | 'SecretToken' |
	 	| 'e1cib/data/Catalog.ExternalRequestHandlers?ref=9d980242ac16000611ec736a4126063a' | 'False'        | '000000001' | 'Тест обработки запроса' | 'http://mockserver:1080/root/external-epf' | 'Token1'      |
	И я закрыл все окна клиентского приложения
	И Я программно заполняю настройки сервиса работы с GitLab тестовыми значениями
	И В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Обработчики внешних запросов'
	Тогда открылось окно 'Обработчики внешних запросов'

Сценарий: Проверка перехвата и обработки внешнего запроса с сервера GitLab

	Пусть Я отправляю "Push Hook" запрос с токеном "Token1" и телом из файла "/test/requests/push-1b9949a2.json" для сервиса "/api/ru/hs/gitlab/events/push"
	И Я отправляю "Push Hook" запрос с токеном "Token1" и телом из файла "/test/requests/push-2b9949a2.json" для сервиса "/api/ru/hs/gitlab/events/push"

	Проверяем отправку файла получателям

		И Пауза 5
		Тогда Я выполняю проверку запроса '{""httpRequest"": {""path"": ""/endpoint1""}, ""times"": { ""atLeast"": 2, ""atMost"": 2 }}'
		И Я выполняю проверку запроса '{""httpRequest"": {""path"": ""/endpoint3""}, ""times"": { ""atLeast"": 2, ""atMost"": 2 }}'

	Проверяем появление даннах на форме обработчика внешних запросов

		Пусть в таблице "List" я перехожу к строке:
			| 'Наименование'           | 'Код'       | 'URL'                                      | 'Токен'  |
			| 'Тест обработки запроса' | '000000001' | 'http://mockserver:1080/root/external-epf' | 'Token1' |

		И в таблице "List" я выбираю текущую строку

		И таблица "ReceivedRequests" стала равной:
			| 'checkout_sha'                             |
			| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
			| '2b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |

	Проверяем сохранение данных запроса и полученных внешних файлов в информационной базе

		И Я открываю основную форму списка регистра сведений "ExternalRequests"
		Тогда таблица "List" стала равной:
			| 'Обработчик внешнего запроса'  | 'checkout_sha'                             |
			| 'Тест обработки запроса'       | '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
			| 'Тест обработки запроса'       | '2b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |

		И Я открываю основную форму списка регистра сведений "RemoteFiles"
		Тогда таблица "List" стала равной:
			| 'Обработчик внешнего запроса'  | 'checkout_sha'                             |
			| 'Тест обработки запроса'       | '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
			| 'Тест обработки запроса'       | '2b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |

Сценарий: Ручной запуск обработки внешнего запроса

	Пусть Я отправляю "Push Hook" запрос с токеном "Token1" и телом из файла "/test/requests/push-1b9949a2.json" для сервиса "/api/ru/hs/gitlab/events/push"
	И Пауза 5

	Запуск обработки данных

		Пусть в таблице "List" я перехожу к строке:
			| 'Наименование'           | 'Код'       | 'URL'                                      | 'Токен'  |
			| 'Тест обработки запроса' | '000000001' | 'http://mockserver:1080/root/external-epf' | 'Token1' |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'HandleRequest'
		
		Тогда появилось предупреждение, содержащее текст "Задание на обработку запроса запущено."
		И я закрываю окно предупреждения
	
	Проверяем отправку файла получателям

		И Пауза 5
		# TODO как-то можно передавать многострочные параметры в экспортные сценарии, пока не понял как
		Тогда Я выполняю проверку запроса '{""httpRequest"": {""path"": ""/endpoint1""}, ""times"": { ""atLeast"": 2, ""atMost"": 2 }}'
		И Я выполняю проверку запроса '{""httpRequest"": {""path"": ""/endpoint3""}, ""times"": { ""atLeast"": 2, ""atMost"": 2 }}'

	Изменяем маршрут отправки файлов получателям

		И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'OpenRoutingSettings'
		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
		И я изменяю флаг 'Пользовательский вариант'
	
		# Исключаем "spb" в маршрутах для "Каталог с отчетами и обработками/Внешняя Обработка 1.epf"
		И в поле с именем 'RoutingJSON' я ввожу текст 
			|'{'|
			|'  "ws" : [ {'|
			|'    "name" : "spb",'|
			|'    "url" : "http://mockserver:1080/endpoint1",'|
			|'    "enabled" : true'|
			|'  }, {'|
			|'    "name" : "msk",'|
			|'    "url" : "http://mockserver:1080/endpoint2",'|
			|'    "enabled" : false'|
			|'  }, {'|
			|'    "name" : "szfo",'|
			|'    "url" : "http://mockserver:1080/endpoint3",'|
			|'    "enabled" : true'|
			|'  } ],'|
			|'  "epf" : [ {'|
			|'    "name" : "Каталог 1/test1.epf",'|
			|'    "exclude" : [ "spb", "msk" ]'|
			|'  }, {'|
			|'    "name" : "Каталог 2/test2.epf"'|
			|'  }, {'|
			|'    "name" : "Каталог с отчетами и обработками/Внешняя Обработка 1.epf",'|
			|'    "exclude" : [ "spb" ]'|
			|'  }, {'|
			|'    "name" : "Нет такого файла.epf"'|
			|'  } ]'|
			|'}'|
		И я нажимаю на кнопку 'Сохранить'
		И Я закрываю окно 'Маршрутизация'

	Запуск обработки данных

		И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'HandleRequest'
		
		Тогда появилось предупреждение, содержащее текст "Задание на обработку запроса запущено."
		И я закрываю окно предупреждения

	Проверка получения файла получателями

		И Пауза 5
		Тогда Я выполняю проверку запроса '{""httpRequest"": {""path"": ""/endpoint1""}, ""times"": { ""atLeast"": 2, ""atMost"": 2 }}'
		И Я выполняю проверку запроса '{""httpRequest"": {""path"": ""/endpoint3""}, ""times"": { ""atLeast"": 3, ""atMost"": 3 }}'
