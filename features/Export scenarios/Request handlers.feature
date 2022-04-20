#language: ru

@ExportScenarios
@ignoreoncimainbuild

Функционал: Повторяющиеся действия над обработчиками внешних запросов

Как Пользователь
Я хочу иметь возможность выполнять однотипные операции с обработчиками внешних запросов
Чтобы использовать их при подготовке тестов и сократить размеры тестовых файлов

Контекст:
	Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""

Сценарий: Я добавляю обработчик событий "НаименованиеОбработчика" проекта "Адрес" с ключом "Ключ"

	Когда В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Обработчики внешних запросов'
	Тогда открылось окно 'Обработчики внешних запросов'
	Затем я нажимаю на кнопку с именем 'FormCreate'
	И открылось окно 'Обработчики внешних запросов (создание)'

	Тогда в поле с именем 'Name' я ввожу текст "НаименованиеОбработчика"
	И в поле с именем 'ProjectURL' я ввожу текст "Адрес"
	И в поле с именем 'SecretToken' я ввожу текст "Ключ"
	И я нажимаю на кнопку 'Записать и закрыть'

	Затем я жду закрытия окна 'Обработчики внешних запросов (создание)' в течение 2 секунд

Сценарий: Я открываю обработчик запроса с кодом "КодОбработчика" для получения текущего состояния формы

	Выбираем обработчик запросов

		Пусть в таблице "List" я перехожу к строке:
			| 'Код'            |
			| "КодОбработчика" |
		И в таблице "List" я выбираю текущую строку

	Устанавливаем отбор "Сегодня"
	
		И я нажимаю на кнопку с именем 'LoadEventsHistory'
		И я нажимаю кнопку выбора у поля с именем "Period"
		И я нажимаю на гиперссылку с именем "SwitchText"
		И в таблице "PeriodVariantTable" я перехожу к строке:
			| 'Value'    |
			| 'Сегодня'  |
		И я нажимаю на кнопку 'Выбрать'
		Тогда открылось окно 'Отбор истории событий'
		И я нажимаю на кнопку 'Установить'
		И я нажимаю на кнопку 'OK'

Сценарий: Я в истории событий устанавливаю отбор "ЗначениеОтбора"

	И я нажимаю на кнопку с именем 'LoadEventsHistory'
	И я нажимаю кнопку выбора у поля с именем "Period"
	И я нажимаю на гиперссылку с именем "SwitchText"
	И в таблице "PeriodVariantTable" я перехожу к строке:
		| 'Value'           |
		| "ЗначениеОтбора"  |
	И я нажимаю на кнопку 'Выбрать'
	Тогда открылось окно 'Отбор истории событий'
	И я нажимаю на кнопку 'Установить'
	И я нажимаю на кнопку 'OK'