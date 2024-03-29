﻿#language: ru

Функционал: Типовые операции над элементами справочника Обработчики внешних запросов

Как Пользователь
Я хочу иметь возможность добавлять, модифицировать и удалять элементы справочника
Чтобы управлять обработчиками событий и анализировать результаты их работы

Контекст:
	Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""
	И Я устанавливаю в константу "HandleRequests" значение "Истина"
	И я удаляю все элементы Справочника "ExternalRequestHandlers"
	И я удаляю все записи РегистрСведений "ExternalRequests"
	И я удаляю все записи РегистрСведений "RemoteFiles"
	И я закрыл все окна клиентского приложения
	
	Пусть В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Обработчики внешних запросов'
	Тогда открылось окно 'Обработчики внешних запросов'
	И Я очищаю фильтр на форме списка

Сценарий: Добавление нового элемента справочника

	Проверка обязательности заполнения полей

		Пусть я очищаю окно сообщений пользователю

		Когда я нажимаю на кнопку с именем 'FormCreate'
		И открылось окно 'Обработчики внешних запросов (создание)'
		И я нажимаю на кнопку 'Записать'

		Тогда в логе сообщений TestClient есть строки:
			| 'Поле "Наименование" не заполнено' |
			| 'Поле "URL" не заполнено'          |
			| 'Поле "Токен" не заполнено'        |

		И Я закрываю окно 'Обработчики внешних запросов (создание)'

	Добавление нового элемента справочника

		Когда Я добавляю обработчик событий "Наименование1" проекта "http://example1.com/path/to/project" с ключом "Token1"
		Тогда таблица "List" стала равной:
			| 'Наименование'  | 'Код'       | 'URL'                                 | 'Токен'  |
			| 'Наименование1' | '000000001' | 'http://example1.com/path/to/project' | 'Token1' |

Сценарий: Редактирование элемента справочника
	
	Дано Я добавляю обработчик событий "Наименование1" проекта "http://example1.com/path/to/project" с ключом "Token1"

	Когда в таблице "List" я перехожу к строке:
		| 'Наименование'  | 'Код'       | 'Токен'  |
		| 'Наименование1' | '000000001' | 'Token1' |

	Редактирование ранее созданного элемента справочника

		И я выбираю пункт контекстного меню с именем 'ListContextMenuChange' на элементе формы с именем "List"
		Тогда открылось окно 'Наименование1 (Обработчики внешних запросов)'

		И в поле с именем 'Name' я ввожу текст 'Наименование2'
		И в поле с именем 'SecretToken' я ввожу текст 'Token2'
		И я нажимаю на кнопку 'Записать и закрыть'
		И я жду закрытия окна 'Наименование2 (Обработчики внешних запросов) *' в течение 2 секунд

		Тогда таблица "List" стала равной:
			| 'Наименование'  | 'Код'       | 'URL'                                 | 'Токен'  |
			| 'Наименование2' | '000000001' | 'http://example1.com/path/to/project' | 'Token2' |

	Отсутствие сообщения о дублировании при повторной записи элемента справочника

		Пусть в таблице "List" я перехожу к строке:
			| 'Наименование'  | 'Код'       | 'Токен'  |
			| 'Наименование2' | '000000001' | 'Token2' |
		И я выбираю пункт контекстного меню с именем 'ListContextMenuChange' на элементе формы с именем "List"
		Тогда открылось окно 'Наименование2 (Обработчики внешних запросов)'
		
		И я нажимаю на кнопку 'Записать и закрыть'
		И я жду закрытия окна 'Наименование2 (Обработчики внешних запросов) *' в течение 2 секунд

		Тогда таблица "List" стала равной:
			| 'Наименование'  | 'Код'       | 'URL'                                 | 'Токен'  |
			| 'Наименование2' | '000000001' | 'http://example1.com/path/to/project' | 'Token2' |

Сценарий: Пометка на удаление элемента справочника
	
	Дано Я добавляю обработчик событий "Наименование1" проекта "http://example1.com/path/to/project" с ключом "Token1"

	Пусть в таблице "List" я перехожу к строке:
		| 'Наименование'  | 'Код'       | 'Токен'  |
		| 'Наименование1' | '000000001' | 'Token1' |
	И я выбираю пункт контекстного меню с именем 'ListContextMenuSetDeletionMark' на элементе формы с именем "List"
	
	Тогда открылось окно '1С:Предприятие'
	И я нажимаю на кнопку 'Да'

	И в таблице "List" текущая строка помечена на удаление

Сценарий: Отсутствие возможности полного удаления элемента справочника "Обработчики внешних запросов"
	
	Дано Я добавляю обработчик событий "Наименование1" проекта "http://example1.com/path/to/project" с ключом "Token1"

	Пусть в таблице "List" я перехожу к строке:
		| 'Наименование'  | 'Код'       | 'Токен'  |
		| 'Наименование1' | '000000001' | 'Token1' |
	И в таблице "List" я удаляю строку

	Тогда таблица "List" стала равной:
		| 'Наименование'  | 'Код'       | 'URL'                                 | 'Токен'  |
		| 'Наименование1' | '000000001' | 'http://example1.com/path/to/project' | 'Token1' |

Сценарий: Запрет на дублирование элементов справочника
	Дано Я добавляю обработчик событий "Наименование1" проекта "http://example1.com/path/to/project" с ключом "Token1"

	Появление ошибки при дублировании записи по ключевому полю (URL)

		Пусть я нажимаю на кнопку с именем 'FormCreate'
		Тогда открылось окно 'Обработчики внешних запросов (создание)'
		
		И в поле с именем 'Name' я ввожу текст "Наименование2"
		И в поле с именем 'ProjectURL' я ввожу текст "http://example1.com/path/to/project"
		И в поле с именем 'SecretToken' я ввожу текст "Token1"
		И я нажимаю на кнопку 'Записать'

		Тогда появилось предупреждение, содержащее текст 'Не удалось записать: "Обработчики внешних запросов"!'
		И я нажимаю на кнопку 'OK'

	Исправление URL и повторная запись 

		Затем открылось окно 'Обработчики внешних запросов (создание) *'
		И в поле с именем 'ProjectURL' я ввожу текст 'http://example2.com/path/to/project'
		И я нажимаю на кнопку 'Записать и закрыть'
		И я жду закрытия окна 'Наименование2 (Обработчики внешних запросов) *' в течение 2 секунд

		Тогда таблица "List" стала равной:
			| 'Наименование'  | 'Код'       | 'URL'                                  | 'Токен'  |
			| 'Наименование1' | '000000001' | 'http://example1.com/path/to/project'  | 'Token1' |
			| 'Наименование2' | '000000002' | 'http://example2.com/path/to/project'  | 'Token1' |

	Отсутствие ошибки при дублировании URL если дублируемая запись помечена на удаление

		Пусть в таблице "List" я перехожу к строке:
			| 'Наименование'  | 'Код'       | 'URL'                                 |
			| 'Наименование2' | '000000002' | 'http://example2.com/path/to/project' |
		И я выбираю пункт контекстного меню с именем 'ListContextMenuSetDeletionMark' на элементе формы с именем "List"
		Тогда открылось окно '1С:Предприятие'
		И я нажимаю на кнопку 'Да'
		И в таблице "List" текущая строка помечена на удаление

		И Я добавляю обработчик событий "Наименование2" проекта "http://example2.com/path/to/project" с ключом "Token1"

		Тогда таблица "List" стала равной:
			| 'Наименование'  | 'Код'       | 'URL'                                 | 'Токен'  |
			| 'Наименование1' | '000000001' | 'http://example1.com/path/to/project' | 'Token1' |
			| 'Наименование2' | '000000002' | 'http://example2.com/path/to/project' | 'Token1' |
			| 'Наименование2' | '000000003' | 'http://example2.com/path/to/project' | 'Token1' |
