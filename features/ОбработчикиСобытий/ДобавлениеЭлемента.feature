#language: ru

@ExportScenarios

Функционал: Регистрация нового элемента в справочнике событий внешнего хранилища

Как Пользователь
Я хочу иметь возможность добавлять новый элемент в справочник событий внешнего хранилища по секретному ключу
Чтобы управлять определенным сервисом и анализировать результаты его работы

Контекст:
	Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""

Сценарий: Я добавляю новую запись "Элемент" в справочник обработчиков событий

	Пусть В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Обработчики событий'
	Тогда открылось окно 'Обработчики событий'
	И я нажимаю на кнопку с именем 'ФормаСоздать'
	Тогда открылось окно 'Обработчики событий (создание)'
	И в поле 'Наименование' я ввожу текст 'Элемент'
	И в поле 'Секретный ключ (Secret Token)' я ввожу текст "$$GitlabToken$$"
	И я нажимаю на кнопку 'Записать и закрыть'
	И я жду закрытия окна 'Обработчики событий (создание)' в течение 5 секунд