#language: ru

Функционал: Получение POST запроса с сервера GitLab

Как Пользователь
Я хочу иметь возможность проверить факт получения POST запроса и его обработки
Чтобы анализировать данные запроса, результат обработки и управлять фоновыми заданиями

Контекст:
    Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""
    И Я устанавливаю в константу "ЗагружатьФайлыИзВнешнегоХранилища" значение "Истина"
    И я закрыл все окна клиентского приложения

Сценарий: Проверка формы обработчика событий на наличие merge request

    Пусть Я делаю POST запрос на "$$МестоположениеСервисовИБРаспределителя$$" с данными "$$ЭталонWebHookGitLab$$" по ключу "$$GitlabToken$$"
    И Я нахожу обработчик событий "ТестированиеВнешниеОбработки" и открываю его
    Тогда в таблице "СохраненныеДанные" количество строк "равно" 1
    И в таблице "СохраненныеДанные" поле "checkout_sha" имеет значение "$$checkout_sha$$"