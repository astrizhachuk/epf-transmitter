#language: ru

Функционал: Просмотр настроек маршрутизации для запроса с севера GitLab

Как Пользователь
Я хочу иметь возможность просмотреть настройки маршрутизации для выбранного merge request
Чтобы проанализировать маршруты отправки данных и иметь возможность их изменить

Контекст:
    Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""
    И Я устанавливаю в константу "ОбрабатыватьЗапросыВнешнегоХранилища" значение "Истина"
    И я закрыл все окна клиентского приложения
    И Я делаю POST запрос на "$$АдресСервисаИБРаспределителя$$" с данными "$$ЭталонWebHookGitLab$$" по ключу "$$GitlabToken$$"

Сценарий: Просмотр настроек маршрутизации для выбранного коммита по умолчанию
    И Я нахожу обработчик событий "ТестированиеВнешниеОбработки" и открываю его
    И в таблице "СохраненныеДанные" я перехожу к первой строке
    И в таблице "СохраненныеДанные" я нажимаю на кнопку '.json маршрутизации'
    Тогда открылось окно 'Редактор JSON'
    И элемент формы "Коммиты" доступен
    Тогда в таблице "Коммиты" количество строк "равно" 3
    И в таблице "Коммиты" я перехожу к последней строке
    И элемент формы "ТекстJSON" доступен
    И элемент формы с именем "ПользовательскийВариант" доступен
    И элемент формы с именем "СохранитьJSON" не доступен
    И Я получаю эталон маршрутизации из файла "$$ЭталонПравилаМаршрутизации$$"
    Тогда элемент формы с именем "ТекстJSON" стал равен "$$JSONПравилМаршрутизации$$"
    И Я закрываю окно 'Редактор JSON'