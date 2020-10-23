﻿#language: ru

@Mock

Функционал: Фоновые задания обработки запроса

Как Пользователь
Я хочу иметь возможность просматривать информацию по фоновым заданиям обработчиков событий
Чтобы анализировать процессы обработки данных и управлять фоновыми заданиями

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
	И Я добавляю новый обработчик событий "Тест обработки запроса" с ключом "gita"

Сценарий: Просмотр фоновых заданий для выбранного запроса

	Пусть Я отправляю "Push Hook" запрос с ключом "gita" и телом "/home/usr1cv8/test/request-epf-push-2.json" для "/api/hs/gitlab/webhooks/epf/push"
	И Я отправляю "Push Hook" запрос с ключом "gita" и телом "/home/usr1cv8/test/request-epf-push.json" для "/api/hs/gitlab/webhooks/epf/push"
	И Пауза 1

	Выбираем тестируемый обработчик событий

		Когда в таблице "Список" я перехожу к строке:
			| 'Наименование'            | 'Код'       | 'Секретный ключ (Secret Token)' |
			| 'Тест обработки запроса'  | '000000001' | 'gita'                          |
		И в таблице "Список" я выбираю текущую строку
		Тогда открылось окно 'Тест обработки запроса (Обработчики событий)'
		И в таблице "ReceivedRequests" количество строк "равно" 2

	Выбираем тестируемый запрос

		Пусть в таблице "ReceivedRequests" я перехожу к строке:
			| 'checkout_sha'                             |
			| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |

	Запоминаем текущее состояние списка фоновых заданий

		Когда я нажимаю на кнопку с именем 'ReceivedRequestsOpenBackgroundJobs'
		Тогда открылось окно 'Фоновые задания'

		И я запоминаю количество строк таблицы "BackgroundJobs" как "BackgroundJobsCount"

		И Я закрываю окно 'Фоновые задания'
		И я жду закрытия окна 'Фоновые задания' в течение 2 секунд

	Выполняем запросы от сервера GitLab еще раз

		Пусть Я отправляю "Push Hook" запрос с ключом "gita" и телом "/home/usr1cv8/test/request-epf-push-2.json" для "/api/hs/gitlab/webhooks/epf/push"
		И Я отправляю "Push Hook" запрос с ключом "gita" и телом "/home/usr1cv8/test/request-epf-push.json" для "/api/hs/gitlab/webhooks/epf/push"
		И Пауза 1

	Проверяем появление новых фоновых заданий

		Когда я нажимаю на кнопку с именем 'ReceivedRequestsOpenBackgroundJobs'
		Тогда открылось окно 'Фоновые задания'
		И я жду, что в таблице "BackgroundJobs" количество строк будет "больше" "$BackgroundJobsCount$" в течение 5 секунд

	Проверяем отображение фоновых заданий только по текущему запросу

		Пусть я запоминаю количество строк таблицы "BackgroundJobs" как "BackgroundJobsCount"
		Когда в таблице "BackgroundJobs" я активизирую поле "Ключ"
		И я выбираю пункт контекстного меню "Расширенный поиск" на элементе формы с именем "BackgroundJobs"
		Тогда открылось окно 'Найти'
		И я меняю значение переключателя 'Как искать' на 'По началу строки'
		И в поле '&Что искать' я ввожу текст '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f'
		И я нажимаю на кнопку '&Найти'
		Тогда открылось окно 'Фоновые задания'
		И я жду, что в таблице "BackgroundJobs" количество строк будет "равно" "$BackgroundJobsCount$" в течение 5 секунд

	Запоминаем первую строку списка фоновых заданий

		Пусть в таблице "BackgroundJobs" я перехожу к первой строке
		И я запоминаю выделенные строки таблицы "BackgroundJobs" как "BackgroundJobsBefore"
			| 'Начало'                   |
			| 'Имя метода'               |
			| 'Уникальный идентификатор' |

	Выполняем запросы от сервера GitLab еще раз

		Пусть Я отправляю "Push Hook" запрос с ключом "gita" и телом "/home/usr1cv8/test/request-epf-push.json" для "/api/hs/gitlab/webhooks/epf/push"
		И Пауза 10

	Обновляем список фоновых и проверяем появление трех новых заданий
		
		Когда я нажимаю на кнопку с именем 'RefreshBackgroundJobs'
		И в таблице "BackgroundJobs" я перехожу к первой строке
		И в таблице "BackgroundJobs" я перехожу к следующей строке
		И в таблице "BackgroundJobs" я перехожу к следующей строке
		И в таблице "BackgroundJobs" я перехожу к следующей строке
		И я запоминаю выделенные строки таблицы "BackgroundJobs" как "BackgroundJobsCurrent"
			| 'Начало'                   |
			| 'Имя метода'               |
			| 'Уникальный идентификатор' |
		И таблица "BackgroundJobsBefore" содержится в таблице "BackgroundJobsCurrent"

Сценарий: Обновление состояния для выбранного фонового задания

	Пусть Я отправляю "Push Hook" запрос с ключом "gita" и телом "/home/usr1cv8/test/request-epf-push.json" для "/api/hs/gitlab/webhooks/epf/push"
	И Пауза 1

	Выбираем тестируемый обработчик событий

		Когда в таблице "Список" я перехожу к строке:
			| 'Наименование'            | 'Код'       | 'Секретный ключ (Secret Token)' |
			| 'Тест обработки запроса'  | '000000001' | 'gita'                          |
		И в таблице "Список" я выбираю текущую строку
		Тогда открылось окно 'Тест обработки запроса (Обработчики событий)'

	Открываем список фоновых заданий

		Когда я нажимаю на кнопку с именем 'ReceivedRequestsOpenBackgroundJobs'
		Тогда открылось окно 'Фоновые задания'

	Выполняем запросы от сервера GitLab еще раз

		# На получении файла с mock-server стоит задержка в 2 секунды
		Пусть Я создаю Expectation с телом запроса "/home/usr1cv8/test/expectation-receivers.json"
		И Я отправляю "Push Hook" запрос с ключом "gita" и телом "/home/usr1cv8/test/request-epf-push.json" для "/api/hs/gitlab/webhooks/epf/push"
		И Пауза 1

	Сразу проверяем появление новых фоновых заданий ожидая появление работающего задания

		Когда я нажимаю на кнопку с именем 'RefreshBackgroundJobs'
		Тогда таблица "BackgroundJobs" содержит строки:
			| 'Конец'               | 'Имя метода'                       | 'Ключ'                                                                                                 | 'Состояние'                    |
			| ''                    | 'Получатели.ОтправитьФайл'         | '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f\|http://mock-server:1080/receiver3\|Внешняя Обработка 1.epf' | 'Задание выполняется'          |
			| ''                    | 'Получатели.ОтправитьФайл'         | '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f\|http://mock-server:1080/receiver1\|Внешняя Обработка 1.epf' | 'Задание выполняется'          |

	Обновляем состояние задания после ожидания

		Когда Пауза 5
		И в таблице "BackgroundJobs" я перехожу к строке
			| 'Конец'               | 'Имя метода'                       | 'Ключ'                                                                                                 | 'Состояние'                    |
			| ''                    | 'Получатели.ОтправитьФайл'         | '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f\|http://mock-server:1080/receiver1\|Внешняя Обработка 1.epf' | 'Задание выполняется'          |
		И я нажимаю на кнопку с именем 'RefreshSelectedBackgroundJob'
		И в таблице "BackgroundJobs" поле "Состояние" имеет значение "Задание выполнено"

		И в таблице "BackgroundJobs" я перехожу к строке
			| 'Конец'               | 'Имя метода'                       | 'Ключ'                                                                                                 | 'Состояние'                    |
			| ''                    | 'Получатели.ОтправитьФайл'         | '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f\|http://mock-server:1080/receiver3\|Внешняя Обработка 1.epf' | 'Задание выполняется'          |
		И я нажимаю на кнопку с именем 'RefreshSelectedBackgroundJob'
		И в таблице "BackgroundJobs" поле "Состояние" имеет значение "Задание выполнено"

Сценарий: Принудительное завершение состояния для выбранного фонового задания

	Пусть Я отправляю "Push Hook" запрос с ключом "gita" и телом "/home/usr1cv8/test/request-epf-push.json" для "/api/hs/gitlab/webhooks/epf/push"
	И Пауза 1

	Выбираем тестируемый обработчик событий

		Когда в таблице "Список" я перехожу к строке:
			| 'Наименование'            | 'Код'       | 'Секретный ключ (Secret Token)' |
			| 'Тест обработки запроса'  | '000000001' | 'gita'                          |
		И в таблице "Список" я выбираю текущую строку
		Тогда открылось окно 'Тест обработки запроса (Обработчики событий)'

	Открываем список фоновых заданий

		Когда я нажимаю на кнопку с именем 'ReceivedRequestsOpenBackgroundJobs'
		Тогда открылось окно 'Фоновые задания'

	Выполняем запросы от сервера GitLab еще раз

		# На получении файла с mock-server стоит задержка в 3 секунды
		Пусть Я создаю Expectation с телом запроса "/home/usr1cv8/test/expectation-receivers.json"
		И Я отправляю "Push Hook" запрос с ключом "gita" и телом "/home/usr1cv8/test/request-epf-push.json" для "/api/hs/gitlab/webhooks/epf/push"
		И Пауза 1

	Сразу проверяем появление новых фоновых заданий ожидая появление работающего задания

		Когда я нажимаю на кнопку с именем 'RefreshBackgroundJobs'
		Тогда таблица "BackgroundJobs" содержит строки:
			| 'Конец'               | 'Имя метода'                       | 'Ключ'                                                                                                 | 'Состояние'                    |
			| ''                    | 'Получатели.ОтправитьФайл'         | '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f\|http://mock-server:1080/receiver3\|Внешняя Обработка 1.epf' | 'Задание выполняется'          |
			| ''                    | 'Получатели.ОтправитьФайл'         | '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f\|http://mock-server:1080/receiver1\|Внешняя Обработка 1.epf' | 'Задание выполняется'          |

	Принудительно завершаем задание

		И в таблице "BackgroundJobs" я перехожу к строке
			| 'Конец'               | 'Имя метода'                       | 'Ключ'                                                                                                 | 'Состояние'                    |
			| ''                    | 'Получатели.ОтправитьФайл'         | '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f\|http://mock-server:1080/receiver1\|Внешняя Обработка 1.epf' | 'Задание выполняется'          |
		И я нажимаю на кнопку с именем 'KillSelectedBackgroundJob'
		И в таблице "BackgroundJobs" поле "Состояние" имеет значение "Задание отменено пользователем"

