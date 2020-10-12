﻿#language: ru

Функционал: Сохранение запроса сервера GitLab и полученных внешних файлов

Как Пользователь
Я хочу иметь возможность сохранять данные, полученные с сервера GitLab
Чтобы проанализировать их и повторно отправить

Контекст:
	Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""
	И Я очищаю MockServer
	И Я создаю Expectation с телом запроса "/home/usr1cv8/test/expectation-routing.json"
	И Я создаю Expectation с телом запроса "/home/usr1cv8/test/expectation-epf-push.json"
	И я удаляю все элементы Справочника "ОбработчикиСобытий"
	И я удаляю все записи РегистрСведений "ДанныеЗапросов"
	И я удаляю все записи РегистрСведений "ВнешниеФайлы"
	И я закрыл все окна клиентского приложения
	И Я настраиваю сервис работы с GitLab для функционального тестирования
	И В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Обработчики событий'
	Тогда открылось окно 'Обработчики событий'
	И Я добавляю новый обработчик событий "Тест обработки запроса фэйк" с ключом "фэйк"
	И Я добавляю новый обработчик событий "Тест обработки запроса" с ключом "gita"
	И Я добавляю новый обработчик событий "Тест обработки запроса фэйк 2" с ключом "gita2"

Сценарий: Я проверяю что данные запроса и полученные внешние файлы сохранились в информационной базе

	Пусть Я отправляю "Push Hook" запрос с ключом "фэйк" и телом "/home/usr1cv8/test/request-epf-push-3.json" для "/api/hs/gitlab/webhooks/epf/push"
	И Я отправляю "Push Hook" запрос с ключом "gita" и телом "/home/usr1cv8/test/request-epf-push.json" для "/api/hs/gitlab/webhooks/epf/push"
	И Я отправляю "Push Hook" запрос с ключом "gita" и телом "/home/usr1cv8/test/request-epf-push-2.json" для "/api/hs/gitlab/webhooks/epf/push"
	
	Проверка записи данных на регистрах
		И Я подключаю TestClient "Этот клиент" логин "Администратор" пароль ""

		И Я открываю основную форму списка регистра сведений "ДанныеЗапросов"
		Тогда таблица "Список" стала равной:
			| 'Обработчик события'          | 'Ключ'                                     |
			| 'Тест обработки запроса фэйк' | '3b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
			| 'Тест обработки запроса'      | '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
			| 'Тест обработки запроса'      | '2b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |

		И Я открываю основную форму списка регистра сведений "ВнешниеФайлы"
		Тогда таблица "Список" стала равной:
			| 'Обработчик события'          | 'Ключ'                                     |
			| 'Тест обработки запроса фэйк' | '3b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
			| 'Тест обработки запроса'      | '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
			| 'Тест обработки запроса'      | '2b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
		
		И я закрываю TestClient "Этот клиент"

	Проверка данных на форме элемента обработчиков событий

		И Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""
		И В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Обработчики событий'
		Тогда открылось окно 'Обработчики событий'

		Тогда в таблице "Список" я перехожу к строке:
			| 'Наименование'                | 'Код'       | 'Секретный ключ (Secret Token)' |
			| 'Тест обработки запроса фэйк' | '000000001' | 'фэйк'                          |
		И в таблице "Список" я выбираю текущую строку
		Тогда таблица "ПолученныеЗапросы" стала равной:
			| 'checkout_sha'                             |
			| '3b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
		Тогда таблица "ВнешниеФайлы" стала равной:
			| 'checkout_sha'                             |
			| '3b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
		И Я закрываю окно 'Тест обработки запроса фэйк (Обработчики событий)'

		Тогда в таблице "Список" я перехожу к строке:
			| 'Наименование'            | 'Код'       | 'Секретный ключ (Secret Token)' |
			| 'Тест обработки запроса'  | '000000002' | 'gita'                          |
		И в таблице "Список" я выбираю текущую строку
		Тогда таблица "ПолученныеЗапросы" стала равной:
			| 'checkout_sha'                             |
			| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
			| '2b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
		Тогда таблица "ВнешниеФайлы" стала равной:
			| 'checkout_sha'                             |
			| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
			| '2b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
		И Я закрываю окно 'Тест обработки запроса (Обработчики событий)'

		Тогда в таблице "Список" я перехожу к строке:
			| 'Наименование'                  | 'Код'       | 'Секретный ключ (Secret Token)' |
			| 'Тест обработки запроса фэйк 2' | '000000003' | 'gita2'                         |
		И в таблице "Список" я выбираю текущую строку
		Тогда в таблице "ПолученныеЗапросы" количество строк "равно" 0
		Тогда в таблице "ВнешниеФайлы" количество строк "равно" 0
		И Я закрываю окно 'Тест обработки запроса фэйк 2 (Обработчики событий)'

		И я жду закрытия окна 'Тест обработки запроса фэйк 2 (Обработчики событий) *' в течение 2 секунд
