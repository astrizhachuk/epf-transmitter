﻿#language: ru

@UseMockserver

Функционал: История событий обработки запросов и отправки данных получателям

Как Пользователь
Я хочу иметь возможность просматривать логи на форме элемента обработчика событий
Чтобы анализировать процессы обработки данных в одном окне в привязке к выбранному обработчику событий

Контекст:
	Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""
	И Я очищаю MockServer
	И Я создаю Expectation из файла "/tmp/expectations/routing.json"
	И Я создаю Expectation из файла "/tmp/expectations/push.json"
	И Я создаю Expectation из файла "/tmp/expectations/endpoints.json"
	И я удаляю все элементы Справочника "ExternalRequestHandlers"
	И я удаляю все записи РегистрСведений "ExternalRequests"
	И я удаляю все записи РегистрСведений "RemoteFiles"
	И я закрыл все окна клиентского приложения
	И Я заполняю настройки сервиса работы с GitLab тестовыми значениями
	И В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Обработчики внешних запросов'
	Тогда открылось окно 'Обработчики внешних запросов'
	И Я добавляю обработчик событий "Тест обработки запроса" с ключом "gita"

Сценарий: Загрузка истории событий с отказом от выбора периода загрузки данных

	Пусть Я отправляю "Push Hook" запрос с ключом "gita" и телом "/test/requests/push.json" для "/api/ru/hs/gitlab/webhooks/epf/push"
	И Пауза 1

	Проверяем что записей еще нет
	
		Когда в таблице "List" я перехожу к строке:
			| 'Наименование'            | 'Код'       | 'Секретный ключ' |
			| 'Тест обработки запроса'  | '000000001' | 'gita'           |
		И в таблице "List" я выбираю текущую строку
		Тогда открылось окно 'Тест обработки запроса (Обработчики внешних запросов)'
		И в таблице "EventsHistory" количество строк "равно" 0

	Открываем форму отборов и закрываем без установки периода отбора

		И я нажимаю на кнопку с именем "FormLoadEventsHistory"
		Тогда открылось окно 'Отбор истории событий'
		И я закрываю окно 'Отбор истории событий'

	Форма элемента не должна была измениться

		Тогда открылось окно 'Тест обработки запроса (Обработчики внешних запросов)'
		И в таблице "EventsHistory" количество строк "равно" 0

Сценарий: Загрузка истории событий с выбором по периоду "Сегодня"

	Пусть Я добавляю обработчик событий "Тест обработки запроса фэйк" с ключом "фэйк"
	И Я отправляю "Push Hook" запрос с ключом "gita" и телом "/test/requests/push.json" для "/api/ru/hs/gitlab/webhooks/epf/push"
	И Пауза 6

	Проверяем что записей еще нет для двух разных обработчиков событий

		Когда в таблице "List" я перехожу к строке:
			| 'Наименование'                 | 'Код'       | 'Секретный ключ' |
			| 'Тест обработки запроса фэйк'  | '000000002' | 'фэйк'           |
		И в таблице "List" я выбираю текущую строку
		Тогда открылось окно 'Тест обработки запроса фэйк (Обработчики внешних запросов)'
		И в таблице "EventsHistory" количество строк "равно" 0
		И Я закрываю окно 'Тест обработки запроса фэйк (Обработчики внешних запросов)'

		Когда в таблице "List" я перехожу к строке:
			| 'Наименование'            | 'Код'       | 'Секретный ключ' |
			| 'Тест обработки запроса'  | '000000001' | 'gita'           |
		И в таблице "List" я выбираю текущую строку
		Тогда открылось окно 'Тест обработки запроса (Обработчики внешних запросов)'
		И в таблице "EventsHistory" количество строк "равно" 0

	Устанавливаем отбор "Сегодня" и загружаем историю для выбранного события

		И я нажимаю на кнопку с именем 'FormLoadEventsHistory'
		Тогда открылось окно 'Отбор истории событий'
		И я нажимаю кнопку выбора у поля с именем "Period"
		Тогда открылось окно 'Выберите период'
		И я нажимаю на гиперссылку с именем "SwitchText"
		И в таблице "PeriodVariantTable" я перехожу к строке:
			| 'Value'    |
			| 'Сегодня'  |
		И я нажимаю на кнопку 'Выбрать'
		Тогда открылось окно 'Отбор истории событий'
		И я нажимаю на кнопку 'Установить'

		Тогда появилось предупреждение, содержащее текст "Добавлено записей"
		И я запоминаю значение поля с именем "Message" как "CountMessage"
		И Я запоминаю значение выражения 'Число(СтрЗаменить($CountMessage$, "Добавлено записей: ", ""))' в переменную "CountMessage"
		И я жду закрытия окна 'Загрузка истории событий' в течение 6 секунд
		И в таблице "EventsHistory" количество строк "больше" 0

	Проверяем что записи истории событий появились

		Когда открылось окно 'Тест обработки запроса (Обработчики внешних запросов)'
		И в таблице "EventsHistory" количество строк "равно" "$CountMessage$"

		И таблица "EventsHistory" содержит строки:
			| 'Уровень'    | 'Приложение'                 | 'Код состояния HTTP' | 'Представление события'              | 'Имя пользователя' | 'Комментарий'                                                                                                                                                                            |
			| 'Информация' | 'Cоединение c HTTP-сервисом' | ''                   | 'ПроверкаЗапроса.Начало'             | 'сайт'             | 'проверка данных запроса...'                                                                                                                                                             |
			| 'Информация' | 'Cоединение c HTTP-сервисом' | ''                   | 'ПроверкаЗапроса.Окончание'          | 'сайт'             | 'проверка данных запроса...'                                                                                                                                                             |
			| 'Информация' | 'Фоновое задание'            | ''                   | 'ОбработкаДанных.Начало'             | 'сайт'             | '[ 1b9949a21e6c897b3dcb4dd510ddb5f893adae2f ]: обработка данных...'                                                                                                                      |
			| 'Информация' | 'Фоновое задание'            | ''                   | 'ПодготовкаДанных.Начало'            | 'сайт'             | '[ 1b9949a21e6c897b3dcb4dd510ddb5f893adae2f ]: подготовка данных к отправке.'                                                                                                            |
			| 'Информация' | 'Фоновое задание'            | ''                   | 'ПолучениеФайловGitLab.Начало'       | 'сайт'             | 'получение файлов с сервера...'                                                                                                                                                          |
			| 'Информация' | 'Фоновое задание'            | ''                   | 'ПолучениеФайловGitLab.Окончание'    | 'сайт'             | 'получение файлов с сервера...'                                                                                                                                                          |
			| 'Информация' | 'Cоединение c HTTP-сервисом' | ''                   | 'Десериализация.Начало'              | 'сайт'             | 'десериализация запроса...'                                                                                                                                                              |
			| 'Информация' | 'Фоновое задание'            | ''                   | 'СохранениеВнешнихФайловВБазуДанных' | 'сайт'             | '[ 1b9949a21e6c897b3dcb4dd510ddb5f893adae2f ]: [СохранениеВнешнихФайловВБазуДанных]: операция выполнена успешно.'                                                                        |
			| 'Информация' | 'Фоновое задание'            | ''                   | 'ПодготовкаДанных.Окончание'         | 'сайт'             | '[ 1b9949a21e6c897b3dcb4dd510ddb5f893adae2f ]: подготовка данных к отправке.'                                                                                                            |
			| 'Информация' | 'Фоновое задание'            | ''                   | 'ОбработкаДанных'                    | 'сайт'             | '[ 1b9949a21e6c897b3dcb4dd510ddb5f893adae2f ]: отправляемых файлов: 1'                                                                                                                   |
			| 'Информация' | 'Фоновое задание'            | ''                   | 'ОбработкаДанных'                    | 'сайт'             | '[ 1b9949a21e6c897b3dcb4dd510ddb5f893adae2f ]: запущенных заданий: 2'                                                                                                                    |
			| 'Информация' | 'Фоновое задание'            | ''                   | 'ОбработкаДанных.Окончание'          | 'сайт'             | '[ 1b9949a21e6c897b3dcb4dd510ddb5f893adae2f ]: обработка данных...'                                                                                                                      |
			| 'Информация' | 'Фоновое задание'            | ''                   | 'СохранениеЗапросаВБазуДанных'       | 'сайт'             | '[ 1b9949a21e6c897b3dcb4dd510ddb5f893adae2f ]: [СохранениеЗапросаВБазуДанных]: операция выполнена успешно.'                                                                              |
			| 'Информация' | 'Cоединение c HTTP-сервисом' | ''                   | 'Десериализация.Окончание'           | 'сайт'             | 'десериализация запроса...'                                                                                                                                                              |
			| 'Информация' | 'Фоновое задание'            | '200'                | 'ОтправкаДанныхПолучателю'           | 'сайт'             | '[ 1b9949a21e6c897b3dcb4dd510ddb5f893adae2f ]: URL сервиса доставки: http://mockserver:1080/endpoint3; файл: Внешняя Обработка 1.epf; текст ответа:\n{"type":"info","message":"Успех"}' |
			| 'Информация' | 'Фоновое задание'            | '200'                | 'ОтправкаДанныхПолучателю'           | 'сайт'             | '[ 1b9949a21e6c897b3dcb4dd510ddb5f893adae2f ]: URL сервиса доставки: http://mockserver:1080/endpoint1; файл: Внешняя Обработка 1.epf; текст ответа:\n{"type":"info","message":"Успех"}' |

		И Я закрываю окно 'Тест обработки запроса (Обработчики внешних запросов)'
		И я жду закрытия окна 'Тест обработки запроса (Обработчики внешних запросов)' в течение 5 секунд

	Переоткроем форму и проверим что записи остались

		Когда в таблице "List" я выбираю текущую строку
		Тогда открылось окно 'Тест обработки запроса (Обработчики внешних запросов)'
		И в таблице "EventsHistory" количество строк "равно" "$CountMessage$"
		И Я закрываю окно 'Тест обработки запроса (Обработчики внешних запросов)'
		И я жду закрытия окна 'Тест обработки запроса (Обработчики внешних запросов)' в течение 5 секунд

	Для другого события записи не появились

		Когда в таблице "List" я перехожу к строке:
			| 'Наименование'                 | 'Код'       | 'Секретный ключ' |
			| 'Тест обработки запроса фэйк'  | '000000002' | 'фэйк'           |
		И в таблице "List" я выбираю текущую строку
		Тогда открылось окно 'Тест обработки запроса фэйк (Обработчики внешних запросов)'
		И в таблице "EventsHistory" количество строк "равно" 0
		И Я закрываю окно 'Тест обработки запроса фэйк (Обработчики внешних запросов)'

Сценарий: Загрузка истории событий с выбором по периоду "Сегодня" с перезаписью записями на "Завтра"

	Пусть Я отправляю "Push Hook" запрос с ключом "gita" и телом "/test/requests/push.json" для "/api/ru/hs/gitlab/webhooks/epf/push"
	И Пауза 1

	Проверяем что записей еще нет

		Когда в таблице "List" я перехожу к строке:
			| 'Наименование'            | 'Код'       | 'Секретный ключ' |
			| 'Тест обработки запроса'  | '000000001' | 'gita'           |
		И в таблице "List" я выбираю текущую строку
		Тогда открылось окно 'Тест обработки запроса (Обработчики внешних запросов)'
		И в таблице "EventsHistory" количество строк "равно" 0

	Устанавливаем отбор "Сегодня" и загружаем историю для выбранного события

		И я нажимаю на кнопку с именем 'FormLoadEventsHistory'
		Тогда открылось окно 'Отбор истории событий'
		И я нажимаю кнопку выбора у поля с именем "Period"
		Тогда открылось окно 'Выберите период'
		И я нажимаю на гиперссылку с именем "SwitchText"
		И в таблице "PeriodVariantTable" я перехожу к строке:
			| 'Value'    |
			| 'Сегодня'  |
		И я нажимаю на кнопку 'Выбрать'
		Тогда открылось окно 'Отбор истории событий'
		И я нажимаю на кнопку 'Установить'

		Тогда появилось предупреждение, содержащее текст "Добавлено записей"
		И я запоминаю значение поля с именем "Message" как "CountMessage"
		И Я запоминаю значение выражения 'Число(СтрЗаменить($CountMessage$, "Добавлено записей: ", ""))' в переменную "CountMessage"
		И я жду закрытия окна 'Загрузка истории событий' в течение 6 секунд
		И в таблице "EventsHistory" количество строк "больше" 0

	Проверяем что записи истории событий появились

		Когда открылось окно 'Тест обработки запроса (Обработчики внешних запросов)'
		Тогда в таблице "EventsHistory" количество строк "равно" "$CountMessage$"

	Устанавливаем отбор "Завтра" и загружаем историю для выбранного события

		И я нажимаю на кнопку с именем 'FormLoadEventsHistory'
		Тогда открылось окно 'Отбор истории событий'
		И я нажимаю кнопку выбора у поля с именем "Period"
		Тогда открылось окно 'Выберите период'
		И я нажимаю на гиперссылку с именем "SwitchText"
		И в таблице "PeriodVariantTable" я перехожу к строке:
			| 'Value'   |
			| 'Завтра'  |
		И я нажимаю на кнопку 'Выбрать'
		Тогда открылось окно 'Отбор истории событий'
		И я нажимаю на кнопку 'Установить'

		Тогда появилось предупреждение, содержащее текст "Добавлено записей: 0"
		И я жду закрытия окна 'Загрузка истории событий' в течение 6 секунд

	Проверяем что записи истории событий обновились

		Когда открылось окно 'Тест обработки запроса (Обработчики внешних запросов)'
		Тогда в таблице "EventsHistory" количество строк "равно" 0

		И Я закрываю окно 'Тест обработки запроса (Обработчики внешних запросов)'
		И я жду закрытия окна 'Тест обработки запроса (Обработчики внешних запросов)' в течение 5 секунд
