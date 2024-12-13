#language: ru

@UseMockserver

Функционал: Проверка сервиса загрузки внешних обработок для выбранного потребителя

Как Пользователь
Я хочу проверять статус сервиса загрузки внешних обработок с параметрами из элемента справочника
Чтобы контролировать возможность загрузки файлов для выбранной информационной базы

Контекст:
	Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""
	И я удаляю все элементы Справочника "Endpoints"
	И Я интерактивно заполняю настройки сервиса работы с GitLab тестовыми значениями

Сценарий: Предупреждение при незаполненном URL
	
	Дано Я проверяю или создаю для справочника "Endpoints" объекты:
		| 'Ref'                                                               | 'DeletionMark' | 'Code'   | 'Description' | 'BaseURL'                | 'RootURL' | 'StatusOperation' | 'UploadFileOperation' | 'User'          | 'Password'          | 'Timeout' |
		| 'e1cib/data/Catalog.Endpoints?ref=9b870242ac16000311eca5ea9319b680' | 'False'        | 'status' | 'status'      | 'http://mockserver:1080' | '/hs/epf' | '/status'         | '/uploadFile'         | 'endpoint user' | 'endpoint password' | 3         |
	И я закрыл все окна клиентского приложения
	
	Выбор потребителя для редактирования

		Когда В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Потребители'
		Тогда открылось окно 'Потребители'
		И в таблице "Список" я перехожу к строке:
			| 'Код'    |
			| 'status' |
		И я выбираю пункт контекстного меню с именем 'ListContextMenuChange' на элементе формы с именем "List"
		Тогда открылось окно 'status (Потребители)'
		И Элементы формы для отображения результатов проверки сервиса не заполнены

	И в поле с именем "BaseURL" я ввожу текст ''
	И я нажимаю на кнопку с именем "CommonCommandTestServiceStatus"
	И Пауза 1

	Затем я жду, что в сообщениях пользователю будет подстрока 'Поле "URL" не заполнено' в течение 1 секунд
	И элемент формы с именем "StatusCode" стал равен 0
	И элемент формы с именем "ResponseBody" стал равен ''
	И элемент формы с именем "FileUploadStatus" стал равен 'False'

Сценарий: Отображение отсутствия подключения к сервису по несуществующему URL
	
	Дано Я проверяю или создаю для справочника "Endpoints" объекты:
		| 'Ref'                                                               | 'DeletionMark' | 'Code'   | 'Description' | 'BaseURL'                | 'RootURL' | 'StatusOperation' | 'UploadFileOperation' | 'User'          | 'Password'          | 'Timeout' |
		| 'e1cib/data/Catalog.Endpoints?ref=9b870242ac16000311eca5ea9319b680' | 'False'        | 'status' | 'status'      | 'http://mockserver:1080' | '/hs/epf' | '/status'         | '/uploadFile'         | 'endpoint user' | 'endpoint password' | 3         |
	И я закрыл все окна клиентского приложения
	
	Выбор потребителя для редактирования

		Когда В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Потребители'
		Тогда открылось окно 'Потребители'
		И в таблице "Список" я перехожу к строке:
			| 'Код'    |
			| 'status' |
		И я выбираю пункт контекстного меню с именем 'ListContextMenuChange' на элементе формы с именем "List"
		Тогда открылось окно 'status (Потребители)'
		И Элементы формы для отображения результатов проверки сервиса не заполнены

	И в поле с именем "BaseURL" я ввожу текст "http://блаблабла.ком"
	И я нажимаю на кнопку с именем "CommonCommandTestServiceStatus"
	И Пауза 5

	Тогда элемент формы с именем "StatusCode" стал равен -1
	И значение поля с именем "ResponseBody" содержит текст "Couldn\'t resolve host name"
	И элемент формы с именем "FileUploadStatus" стал равен 'False'

Сценарий: Получение ответа от сервиса не требующего аутентификации

	Дано Я очищаю MockServer
	И Я создаю Expectation из файла "./test/expectations/noAuth.json"
	И Я проверяю или создаю для справочника "Endpoints" объекты:
		| 'Ref'                                                               | 'DeletionMark' | 'Code'   | 'Description' | 'BaseURL'                | 'RootURL' | 'StatusOperation' | 'UploadFileOperation' | 'User'          | 'Password'          | 'Timeout' |
		| 'e1cib/data/Catalog.Endpoints?ref=9b870242ac16000311eca5ea9319b681' | 'False'        | 'noAuth' | 'noAuth'      | 'http://mockserver:1080' | '/hs/epf' | '/noAuth'         | '/uploadFile'         | 'endpoint user' | 'endpoint password' | 3         |
	И я закрыл все окна клиентского приложения
	
	Выбор потребителя для редактирования

		Когда В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Потребители'
		Тогда открылось окно 'Потребители'
		И в таблице "Список" я перехожу к строке:
			| 'Код'    |
			| 'noAuth' |
		И я выбираю пункт контекстного меню с именем 'ListContextMenuChange' на элементе формы с именем "List"
		Тогда открылось окно 'noAuth (Потребители)'
		И Элементы формы для отображения результатов проверки сервиса не заполнены

	И я нажимаю на кнопку с именем "CommonCommandTestServiceStatus"
	И Пауза 1

	Тогда элемент формы с именем "StatusCode" стал равен 200
	И значение поля с именем "ResponseBody" содержит текст "noAuth body"
	И элемент формы с именем "FileUploadStatus" стал равен 'False'

Сценарий: Получение ответа от сервиса требующего аутентификацию BasicAuth

	Дано Я очищаю MockServer
	И Я создаю Expectation из файла "./test/expectations/basicAuth-200.json"
	И Я создаю Expectation из файла "./test/expectations/basicAuth-405.json"
	И Я проверяю или создаю для справочника "Endpoints" объекты:
		| 'Ref'                                                               | 'DeletionMark' | 'Code'      | 'Description' | 'BaseURL'                | 'RootURL' | 'StatusOperation' | 'UploadFileOperation' | 'User'          | 'Password'          | 'Timeout' |
		| 'e1cib/data/Catalog.Endpoints?ref=9b870242ac16000311eca5ea9319b682' | 'False'        | 'basicAuth' | 'basicAuth'   | 'http://mockserver:1080' | '/hs/epf' | '/basicAuth'      | '/uploadFile'         | 'endpoint user' | 'endpoint password' | 3         |
	И я закрыл все окна клиентского приложения

	Выбор потребителя для редактирования

		Когда В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Потребители'
		Тогда открылось окно 'Потребители'
		И в таблице "Список" я перехожу к строке:
			| 'Код'       |
			| 'basicAuth' |
		И я выбираю пункт контекстного меню с именем 'ListContextMenuChange' на элементе формы с именем "List"
		Тогда открылось окно 'basicAuth (Потребители)'
		И Элементы формы для отображения результатов проверки сервиса не заполнены

	Подключение без аутентификации

		И в поле с именем "User" я ввожу текст ''
		И в поле с именем "Password" я ввожу текст ''
		И я нажимаю на кнопку с именем "CommonCommandTestServiceStatus"
		И Пауза 1

		Тогда элемент формы с именем "StatusCode" стал равен 405
		И элемент формы с именем "ResponseBody" стал равен ''
		И элемент формы с именем "FileUploadStatus" стал равен 'False'

	Подключение с аутентификацией указанной непосредственно в URL

		И в поле "URL" я ввожу текст "http://User1:Password1@mockserver:1080/basicAuth"
		И я нажимаю на кнопку с именем "CommonCommandTestServiceStatus"
		И Пауза 1

		Тогда элемент формы с именем "StatusCode" стал равен 200
		И значение поля с именем "ResponseBody" содержит текст "basicAuth body"
		И элемент формы с именем "FileUploadStatus" стал равен 'False'

	Подключение с неверной аутентификацией указанной непосредственно в URL

		И в поле "URL" я ввожу текст "http://User1:Password2@mockserver:1080/basicAuth"
		И я нажимаю на кнопку с именем "CommonCommandTestServiceStatus"
		И Пауза 1

		Тогда элемент формы с именем "StatusCode" стал равен 405
		И элемент формы с именем "ResponseBody" стал равен ''
		И элемент формы с именем "FileUploadStatus" стал равен 'False'

	Подключение с неверной аутентификацией

		И в поле "URL" я ввожу текст "http://mockserver:1080/basicAuth"
		И в поле с именем "User" я ввожу текст 'User2'
		И в поле с именем "Password" я ввожу текст 'Password1'
		И я нажимаю на кнопку с именем "CommonCommandTestServiceStatus"
		И Пауза 1

		Тогда элемент формы с именем "StatusCode" стал равен 405
		И элемент формы с именем "ResponseBody" стал равен ''
		И элемент формы с именем "FileUploadStatus" стал равен 'False'

	Подключение с корректной аутентификацией

		И в поле "URL" я ввожу текст "http://mockserver:1080/basicAuth"
		И в поле с именем "User" я ввожу текст 'User1'
		И в поле с именем "Password" я ввожу текст 'Password1'
		И я нажимаю на кнопку с именем "CommonCommandTestServiceStatus"
		И Пауза 1

		Тогда элемент формы с именем "StatusCode" стал равен 200
		И значение поля с именем "ResponseBody" содержит текст "basicAuth body"
		И элемент формы с именем "FileUploadStatus" стал равен 'False'

Сценарий: Отображение включения загрузки файлов у потребителя
	
	Дано Я очищаю MockServer
	И Я создаю Expectation из файла "./test/expectations/status.json"
	И Я проверяю или создаю для справочника "Endpoints" объекты:
		| 'Ref'                                                               | 'DeletionMark' | 'Code'   | 'Description' | 'BaseURL'                | 'RootURL' | 'StatusOperation' | 'UploadFileOperation' | 'User'          | 'Password'          | 'Timeout' |
		| 'e1cib/data/Catalog.Endpoints?ref=9b870242ac16000311eca5ea9319b680' | 'False'        | 'status' | 'status'      | 'http://mockserver:1080' | '/hs/epf' | '/status'         | '/uploadFile'         | 'endpoint user' | 'endpoint password' | 3         |
	И я закрыл все окна клиентского приложения
	
	Выбор потребителя для редактирования

		Когда В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Потребители'
		Тогда открылось окно 'Потребители'
		И в таблице "Список" я перехожу к строке:
			| 'Код'    |
			| 'status' |
		И я выбираю пункт контекстного меню с именем 'ListContextMenuChange' на элементе формы с именем "List"
		Тогда открылось окно 'status (Потребители)'
		И Элементы формы для отображения результатов проверки сервиса не заполнены

	И я нажимаю на кнопку с именем "CommonCommandTestServiceStatus"
	И Пауза 5

	Тогда элемент формы с именем "StatusCode" стал равен 200
	И элемент формы с именем "ResponseBody" стал равен 
		|'{'|
		|'  \"message\" : \"загрузка файлов включена\"'|
		|'}'|
	И элемент формы с именем 'FileUploadStatus' стал равен 'Да'