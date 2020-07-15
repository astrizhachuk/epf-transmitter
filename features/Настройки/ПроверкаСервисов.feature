#language: ru

Функционал: Проверка подключения к сервисам 1С для работы с GitLab

Как Пользователь
Я хочу иметь возможность проверять подключение к сервису 1С для работы с GitLab
Чтобы контролировать работоспособность сервиса информационной базы распределителя

Контекст:
	Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""
	И я закрыл все окна клиентского приложения
	И Я настраиваю сервис работы с GitLab по глобальным переменным
	И В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Настройки сервиса'
	Тогда открылось окно 'Настройки сервиса'

Сценарий: Я проверяю наличие предупреждения при незаполненном адресе

	И я нажимаю на кнопку 'Проверить подключение к сервису'
	Тогда открылось окно 'Проверка подключения'
	И элемент формы с именем "ФормаРезультатПроверки" стал равен ''

	И в поле "Адрес" я ввожу текст ''
	И я нажимаю на кнопку 'Проверить'

	Затем я жду, что в сообщениях пользователю будет подстрока 'Поле "Адрес" не заполнено.' в течение 1 секунд
	Тогда элемент формы с именем "ФормаРезультатПроверки" стал равен ''

Сценарий: Я проверяю отсутствие подключения к сервису по недоступному адресу

	И я нажимаю на кнопку 'Проверить подключение к сервису'
	Тогда открылось окно 'Проверка подключения'
	И элемент формы с именем "ФормаРезультатПроверки" стал равен ''

	И в поле "Адрес" я ввожу текст "http://блаблабла.ком"
	И я нажимаю на кнопку 'Проверить'
	Тогда элемент формы с именем "ФормаРезультатПроверки" стал равен "Ошибка подключения."

Сценарий: Я проверяю отсутствие подключения к сервису по фиктивному, но доступному адресу

	И я нажимаю на кнопку 'Проверить подключение к сервису'
	Тогда открылось окно 'Проверка подключения'
	И элемент формы с именем "ФормаРезультатПроверки" стал равен ''

	И в поле "Адрес" я ввожу текст "http://www.example.org"
	И я нажимаю на кнопку 'Проверить'
	Тогда элемент формы с именем "ФормаРезультатПроверки" стал равен "Сервис недоступен."

Сценарий: Я проверяю сохранение значения в поле "Адрес" при повторном открытии формы проверки подключения

	И я нажимаю на кнопку 'Проверить подключение к сервису'
	Тогда открылось окно 'Проверка подключения'
	И элемент формы с именем "ФормаРезультатПроверки" стал равен ''
	И элемент формы с именем "ФормаАдрес" стал равен 'http://www.example.org'

Сценарий: Я проверяю подключение к выключенному сервису

	И я снимаю флаг 'Обрабатывать запросы внешнего хранилища'
	И я нажимаю на кнопку 'Записать'

	И я нажимаю на кнопку 'Проверить подключение к сервису'
	Тогда открылось окно 'Проверка подключения'
	И элемент формы с именем "ФормаРезультатПроверки" стал равен ''

	И я запоминаю значение выражения '$$МестоположениеСервисовИБРаспределителя$$ + "/services" ' в переменную "ServicesАдрес"
	И в поле 'Адрес' я ввожу значение переменной "ServicesАдрес"
	И я нажимаю на кнопку 'Проверить'
	И Пауза 1
	Тогда элемент формы с именем "ФормаРезультатПроверки" стал равен "Сервис доступен. Статус работы: выключен."

Сценарий: Я проверяю подключение к включенному сервису

	И я нажимаю на кнопку 'Проверить подключение к сервису'
	Тогда открылось окно 'Проверка подключения'
	И элемент формы с именем "ФормаРезультатПроверки" стал равен ''

	И я запоминаю значение выражения '$$МестоположениеСервисовИБРаспределителя$$ + "/services" ' в переменную "ServicesАдрес"
	И в поле 'Адрес' я ввожу значение переменной "ServicesАдрес"
	И я нажимаю на кнопку 'Проверить'
	И Пауза 1
	Тогда элемент формы с именем "ФормаРезультатПроверки" стал равен "Сервис доступен. Статус работы: включен."

Сценарий: Я проверяю перезапись результата проверки при изменении условий проверки

	И я снимаю флаг 'Обрабатывать запросы внешнего хранилища'
	И я нажимаю на кнопку 'Записать'

	И я нажимаю на кнопку 'Проверить подключение к сервису'
	Тогда открылось окно 'Проверка подключения'
	И элемент формы с именем "ФормаРезультатПроверки" стал равен ''

	И я запоминаю значение выражения '$$МестоположениеСервисовИБРаспределителя$$ + "/services" ' в переменную "ServicesАдрес"
	И в поле 'Адрес' я ввожу значение переменной "ServicesАдрес"
	И я нажимаю на кнопку 'Проверить'
	И Пауза 1
	Тогда элемент формы с именем "ФормаРезультатПроверки" стал равен "Сервис доступен. Статус работы: выключен."

	И В панели открытых я выбираю 'Настройки сервиса'
	Тогда открылось окно 'Настройки сервиса'
	И я изменяю флаг 'Обрабатывать запросы внешнего хранилища'
	И я нажимаю на кнопку 'Записать'
	И В панели открытых я выбираю 'Проверка подключения'

	Тогда открылось окно 'Проверка подключения'
	И элемент формы с именем "ФормаРезультатПроверки" стал равен "Сервис доступен. Статус работы: выключен."
	И я нажимаю на кнопку 'Проверить'
	И Пауза 1
	Тогда элемент формы с именем "ФормаРезультатПроверки" стал равен "Сервис доступен. Статус работы: включен."
