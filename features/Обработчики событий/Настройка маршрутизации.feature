﻿#language: ru

@Mock

Функционал: Настройка маршрутизации файлов

Как Пользователь
Я хочу иметь возможность просматривать настройки маршрутизации и редактировать их
Чтобы анализировать и изменять маршруты отправки данных

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
	Пусть Я отправляю "Push Hook" запрос с ключом "gita" и телом "/home/usr1cv8/test/request-epf-push.json" для "/api/hs/gitlab/webhooks/epf/push"
	И Я отправляю "Push Hook" запрос с ключом "gita" и телом "/home/usr1cv8/test/request-epf-push-2.json" для "/api/hs/gitlab/webhooks/epf/push"
	И Пауза 2

Сценарий: Я просматриваю сохраненные настройки маршрутизации

	Когда в таблице "Список" я перехожу к строке:
		| 'Наименование'            | 'Код'       | 'Секретный ключ' |
		| 'Тест обработки запроса'  | '000000001' | 'gita'           |
	И в таблице "Список" я выбираю текущую строку
	
	И в таблице "ReceivedRequests" я перехожу к строке:
		| 'checkout_sha'                             |
		| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
	И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'
	Тогда открылось окноИ я нажимаю на гиперссылку с именем "Гиперссылка" 'Настройка маршрутизации'

	И таблица "Commits" стала равной:
		| 'commit_sha'                               |
		| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
		| 'ef886bb4e372250d8212387350f7e139cbe5a1af' |
		| '968eca170a80a5c825b0808734cb5b109eaedcd3' |
	И Я проверяю состояние формы по строке "1b9949a21e6c897b3dcb4dd510ddb5f893adae2f" для эталонного значения настроек маршрутизации
	И Я проверяю состояние формы по строке "ef886bb4e372250d8212387350f7e139cbe5a1af" для эталонного значения настроек маршрутизации
	И Я проверяю состояние формы по строке "968eca170a80a5c825b0808734cb5b109eaedcd3" для эталонного значения настроек маршрутизации
	И я закрываю окно 'Настройка маршрутизации'
	И я жду закрытия окна 'Настройка маршрутизации' в течение 2 секунд

	И в таблице "ReceivedRequests" я перехожу к строке:
		| 'checkout_sha'                             |
		| '2b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
	И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'

	Тогда открылось окно 'Настройка маршрутизации'
	И таблица "Commits" стала равной:
		| 'commit_sha'                                   |
		| '2b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
		| 'ef886bb4e372250d8212387350f7e139cbe5a1af' |
		| '968eca170a80a5c825b0808734cb5b109eaedcd3' |
	И Я проверяю состояние формы по строке "2b9949a21e6c897b3dcb4dd510ddb5f893adae2f" для эталонного значения настроек маршрутизации
	И Я проверяю состояние формы по строке "ef886bb4e372250d8212387350f7e139cbe5a1af" для эталонного значения настроек маршрутизации
	И Я проверяю состояние формы по строке "968eca170a80a5c825b0808734cb5b109eaedcd3" для эталонного значения настроек маршрутизации
	И я закрываю окно 'Настройка маршрутизации'
	И я жду закрытия окна 'Настройка маршрутизации' в течение 2 секунд

Сценарий: Я редактирую сохраненные настройки маршрутизации

	Когда в таблице "Список" я перехожу к строке:
		| 'Наименование'            | 'Код'       | 'Секретный ключ' |
		| 'Тест обработки запроса'  | '000000001' | 'gita'           |
	И в таблице "Список" я выбираю текущую строку
	
	И в таблице "ReceivedRequests" я перехожу к строке:
		| 'checkout_sha'                             |
		| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
	И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'

	Редактируем текст по одной строке (некорректный формат)

		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| "ef886bb4e372250d8212387350f7e139cbe5a1af" |

		И элемент с именем "CommitsRoutingJSON" доступен только для просмотра
		И я устанавливаю флаг 'Пользовательский вариант'
		И в поле 'CommitsRoutingJSON' я ввожу текст 'простой текст не в формате JSON'
		И я нажимаю на кнопку 'Сохранить JSON'
		Тогда появилось предупреждение, содержащее текст "Непредвиденный символ при чтении JSON"
		И я закрываю окно предупреждения

	Редактируем текст по одной строке (JSON-формат)

		И я закрываю окно 'Настройка маршрутизации'
		И я жду закрытия окна 'Настройка маршрутизации' в течение 2 секунд
		И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'

		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| "ef886bb4e372250d8212387350f7e139cbe5a1af" |

		И элемент с именем "CommitsRoutingJSON" доступен только для просмотра
		И я устанавливаю флаг 'Пользовательский вариант'
		И в поле 'CommitsRoutingJSON' я ввожу текст '{"имя": "пользовательский вариант"}'
		И я нажимаю на кнопку 'Сохранить JSON'

	Проверяем что значение на форме не сбрасывается при переходе на другую строку

		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| '968eca170a80a5c825b0808734cb5b109eaedcd3' |
		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| 'ef886bb4e372250d8212387350f7e139cbe5a1af' |

		И элемент формы с именем "CommitsRoutingJSON" стал равен '{"имя": "пользовательский вариант"}'
		И элемент формы с именем "CommitsIsUserSetting" стал равен 'Да'
		И элемент с именем "CommitsRoutingJSON" доступен не только для просмотра
		И я жду доступности элемента с именем "SaveJSON" в течение 2 секунд
		И я закрываю окно 'Настройка маршрутизации'
		И я жду закрытия окна 'Настройка маршрутизации' в течение 2 секунд

		И Я закрываю окно 'Тест обработки запроса (Обработчики событий)'
		И я жду закрытия окна 'Тест обработки запроса (Обработчики событий) *' в течение 2 секунд

	Проверяем что значение сохранилось при повторном открытии формы элемента

		И в таблице "Список" я выбираю текущую строку
		И в таблице "ReceivedRequests" я перехожу к строке:
			| 'checkout_sha'                             |
			| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
		И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'
		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| 'ef886bb4e372250d8212387350f7e139cbe5a1af' |

		И элемент формы с именем "CommitsRoutingJSON" стал равен '{"имя": "пользовательский вариант"}'
		И элемент формы с именем "CommitsIsUserSetting" стал равен 'Да'
		И элемент с именем "CommitsRoutingJSON" доступен не только для просмотра
		И я жду доступности элемента с именем "SaveJSON" в течение 2 секунд

		И я закрываю окно 'Настройка маршрутизации'
		И я жду закрытия окна 'Настройка маршрутизации' в течение 2 секунд

Сценарий: Я перезаписываю пользовательский вариант настройки маршрутизации

	Когда в таблице "Список" я перехожу к строке:
		| 'Наименование'            | 'Код'       | 'Секретный ключ' |
		| 'Тест обработки запроса'  | '000000001' | 'gita'           |
	И в таблице "Список" я выбираю текущую строку
	
	И в таблице "ReceivedRequests" я перехожу к строке:
		| 'checkout_sha'                             |
		| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
	И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'

	Редактируем текст по одной строке

		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| "ef886bb4e372250d8212387350f7e139cbe5a1af" |

		И элемент с именем "CommitsRoutingJSON" доступен только для просмотра
		И я устанавливаю флаг 'Пользовательский вариант'
		И в поле 'CommitsRoutingJSON' я ввожу текст '{"имя": "пользовательский вариант"}'
		И я нажимаю на кнопку 'Сохранить JSON'

	Редактируем ту же настройку еще раз с подтверждением перезаписи данных

		И я закрываю окно 'Настройка маршрутизации'
		И я жду закрытия окна 'Настройка маршрутизации' в течение 2 секунд
		И в таблице "ReceivedRequests" я перехожу к строке:
			| 'checkout_sha'                             |
			| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
		И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'
		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| "ef886bb4e372250d8212387350f7e139cbe5a1af" |
		И значение поля "CommitsRoutingJSON" содержит текст '{"имя": "пользовательский вариант"}'

		И в поле 'CommitsRoutingJSON' я ввожу текст '{"имя": "пользовательский вариант2"}'
		И я нажимаю на кнопку 'Сохранить JSON'
		Тогда появилось предупреждение, содержащее текст "Пользовательская настройка уже существуют, перезаписать?"
		И я нажимаю на кнопку 'Да'

		Тогда открылось окно 'Настройка маршрутизации'
		И Я закрываю окно 'Настройка маршрутизации'
		Тогда открылось окно 'Тест обработки запроса (Обработчики событий)'
		И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'
		Тогда открылось окно 'Настройка маршрутизации'
		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| 'ef886bb4e372250d8212387350f7e139cbe5a1af' |
		И значение поля "CommitsRoutingJSON" содержит текст '{"имя": "пользовательский вариант2"}'
		И элемент с именем "CommitsRoutingJSON" доступен не только для просмотра

	Редактируем ту же настройку еще раз с отказом от перезаписи данных

		И я закрываю окно 'Настройка маршрутизации'
		И я жду закрытия окна 'Настройка маршрутизации' в течение 2 секунд
		И в таблице "ReceivedRequests" я перехожу к строке:
			| 'checkout_sha'                             |
			| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
		И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'
		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| "ef886bb4e372250d8212387350f7e139cbe5a1af" |
		И значение поля "CommitsRoutingJSON" содержит текст '{"имя": "пользовательский вариант2"}'

		И в поле 'CommitsRoutingJSON' я ввожу текст '{"имя": "пользовательский вариант3"}'
		И я нажимаю на кнопку 'Сохранить JSON'
		Тогда появилось предупреждение, содержащее текст "Пользовательская настройка уже существуют, перезаписать?"
		И я нажимаю на кнопку 'Нет'

		Тогда открылось окно 'Настройка маршрутизации'
		И Я закрываю окно 'Настройка маршрутизации'
		Тогда открылось окно 'Тест обработки запроса (Обработчики событий)'
		И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'
		Тогда открылось окно 'Настройка маршрутизации'
		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| 'ef886bb4e372250d8212387350f7e139cbe5a1af' |
		И значение поля "CommitsRoutingJSON" содержит текст '{"имя": "пользовательский вариант2"}'
		И элемент с именем "CommitsRoutingJSON" доступен не только для просмотра

Сценарий: Я удаляю пользовательский вариант настройки маршрутизации

	Когда в таблице "Список" я перехожу к строке:
		| 'Наименование'            | 'Код'       | 'Секретный ключ' |
		| 'Тест обработки запроса'  | '000000001' | 'gita'           |
	И в таблице "Список" я выбираю текущую строку
	
	И в таблице "ReceivedRequests" я перехожу к строке:
		| 'checkout_sha'                             |
		| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
	И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'

	Редактируем текст по одной строке

		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| "ef886bb4e372250d8212387350f7e139cbe5a1af" |

		И элемент с именем "CommitsRoutingJSON" доступен только для просмотра
		И я устанавливаю флаг 'Пользовательский вариант'
		И в поле 'CommitsRoutingJSON' я ввожу текст '{"имя": "пользовательский вариант"}'
		И я нажимаю на кнопку 'Сохранить JSON'

	Отказываемся от сброса настроек при снятии флага "Пользовательский вариант"

		И я закрываю окно 'Настройка маршрутизации'
		И я жду закрытия окна 'Настройка маршрутизации' в течение 2 секунд
		И в таблице "ReceivedRequests" я перехожу к строке:
			| 'checkout_sha'                             |
			| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
		И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'
		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| "ef886bb4e372250d8212387350f7e139cbe5a1af" |
		И значение поля "CommitsRoutingJSON" содержит текст '{"имя": "пользовательский вариант"}'
		И элемент с именем "CommitsRoutingJSON" доступен не только для просмотра

		И я снимаю флаг 'Пользовательский вариант'
		Тогда появилось предупреждение, содержащее текст "Сбросить настройку маршрутизации на значение по умолчанию?"
		И я нажимаю на кнопку 'Нет'

		Тогда открылось окно 'Настройка маршрутизации'
		И Я закрываю окно 'Настройка маршрутизации'
		Тогда открылось окно 'Тест обработки запроса (Обработчики событий)'
		И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'
		Тогда открылось окно 'Настройка маршрутизации'
		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| 'ef886bb4e372250d8212387350f7e139cbe5a1af' |
		И значение поля "CommitsRoutingJSON" содержит текст '{"имя": "пользовательский вариант"}'
		И элемент формы с именем "CommitsIsUserSetting" стал равен 'Да'
		И элемент с именем "CommitsRoutingJSON" доступен не только для просмотра
		И я жду доступности элемента с именем "SaveJSON" в течение 2 секунд

	Сбрасываем настройки до первоначального состояния при снятии флага "Пользовательский вариант"

		И я закрываю окно 'Настройка маршрутизации'
		И я жду закрытия окна 'Настройка маршрутизации' в течение 2 секунд
		И в таблице "ReceivedRequests" я перехожу к строке:
			| 'checkout_sha'                             |
			| '1b9949a21e6c897b3dcb4dd510ddb5f893adae2f' |
		И в таблице "ReceivedRequests" я нажимаю на кнопку с именем 'ReceivedRequestsOpenRoutingJSON'
		И в таблице "Commits" я перехожу к строке:
			| 'commit_sha'                               |
			| "ef886bb4e372250d8212387350f7e139cbe5a1af" |
		И значение поля "CommitsRoutingJSON" содержит текст '{"имя": "пользовательский вариант"}'
		И элемент с именем "CommitsRoutingJSON" доступен не только для просмотра

		И я снимаю флаг 'Пользовательский вариант'
		Тогда появилось предупреждение, содержащее текст "Сбросить настройку маршрутизации на значение по умолчанию?"
		И я нажимаю на кнопку 'Да'

		Тогда открылось окно 'Настройка маршрутизации'
		И Я проверяю состояние формы по строке "ef886bb4e372250d8212387350f7e139cbe5a1af" для эталонного значения настроек маршрутизации
		И я закрываю окно 'Настройка маршрутизации'
		И я жду закрытия окна 'Настройка маршрутизации' в течение 2 секунд