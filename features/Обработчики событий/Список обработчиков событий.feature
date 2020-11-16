﻿#language: ru

Функционал: Управление элементами справочника Обработчики событий

Как Пользователь
Я хочу иметь возможность регистрировать, модифицировать и удалять элементы справочника
Чтобы управлять сервисами и анализировать результаты их работы

Контекст:
	Дано Я подключаю TestClient "Этот клиент" логин "Пользователь" пароль ""
	И Я устанавливаю в константу "HandleRequests" значение "Истина"
	И я удаляю все элементы Справочника "Webhooks"
	И я удаляю все записи РегистрСведений "QueryData"
	И я удаляю все записи РегистрСведений "RemoteFiles"
	И я закрыл все окна клиентского приложения
	Пусть В командном интерфейсе я выбираю 'Интеграция с GitLab' 'Обработчики событий'
	Тогда открылось окно 'Обработчики событий'
	И Я очищаю фильтр на форме списка
	#И я нажимаю на кнопку с именем "FormDynamicListStandardSettings"

Сценарий: Добавление элемента справочника "Обработчики событий"
	Когда Я добавляю новый обработчик событий "Наименование1" с ключом "Секретный ключ1"
	Тогда таблица "List" стала равной:
		| 'Наименование'  | 'Код'       | 'Секретный ключ'  |
		| 'Наименование1' | '000000001' | 'Секретный ключ1' |

Сценарий: Редактирование элемента справочника "Обработчики событий"
	Дано Я добавляю новый обработчик событий "Наименование1" с ключом "Секретный ключ1"

	Пусть в таблице "List" я перехожу к строке:
		| 'Наименование'  | 'Код'       | 'Секретный ключ'  |
		| 'Наименование1' | '000000001' | 'Секретный ключ1' |
	И я выбираю пункт контекстного меню с именем 'ListContextMenuChange' на элементе формы с именем "List"
	Тогда открылось окно 'Наименование1 (Обработчики событий)'
	И в поле 'Наименование' я ввожу текст 'Наименование2'
	И я нажимаю на кнопку 'Записать'
	Тогда открылось окно 'Наименование2 (Обработчики событий)'
	И в поле 'Секретный ключ' я ввожу текст 'Секретный ключ2'
	И я нажимаю на кнопку 'Записать и закрыть'
	И я жду закрытия окна 'Наименование2 (Обработчики событий) *' в течение 2 секунд

	Тогда таблица "List" стала равной:
		| 'Наименование'  | 'Код'       | 'Секретный ключ'  |
		| 'Наименование2' | '000000001' | 'Секретный ключ2' |

Сценарий: Перезапись элемента справочника "Обработчики событий"
	Дано Я добавляю новый обработчик событий "Наименование1" с ключом "Секретный ключ1"
	И Я добавляю новый обработчик событий "Наименование2" с ключом "Секретный ключ2"
	
	Пусть в таблице "List" я перехожу к строке:
		| 'Наименование'  | 'Код'       | 'Секретный ключ'  |
		| 'Наименование2' | '000000002' | 'Секретный ключ2' |
	И я выбираю пункт контекстного меню с именем 'ListContextMenuChange' на элементе формы с именем "List"
	Тогда открылось окно 'Наименование2 (Обработчики событий)'
	И я нажимаю на кнопку 'Записать и закрыть'
	И я жду закрытия окна 'Наименование2 (Обработчики событий) *' в течение 2 секунд

	Тогда таблица "List" стала равной:
		| 'Наименование'  | 'Код'       | 'Секретный ключ'  |
		| 'Наименование1' | '000000001' | 'Секретный ключ1' |
		| 'Наименование2' | '000000002' | 'Секретный ключ2' |

Сценарий: Пометка удаления элемента справочника "Обработчики событий"
	Дано Я добавляю новый обработчик событий "Наименование1" с ключом "Секретный ключ1"

	Пусть в таблице "List" я перехожу к строке:
		| 'Наименование'  | 'Код'       | 'Секретный ключ'  |
		| 'Наименование1' | '000000001' | 'Секретный ключ1' |
	И я выбираю пункт контекстного меню с именем 'ListContextMenuSetDeletionMark' на элементе формы с именем "List"
	Тогда открылось окно '1С:Предприятие'
	И я нажимаю на кнопку 'Да'

	И в таблице "List" текущая строка помечена на удаление

Сценарий: Полное удаление элемента справочника "Обработчики событий"
	Дано Я добавляю новый обработчик событий "Наименование1" с ключом "Секретный ключ1"

	Пусть в таблице "List" я перехожу к строке:
		| 'Наименование'  | 'Код'       | 'Секретный ключ'  |
		| 'Наименование1' | '000000001' | 'Секретный ключ1' |
	И в таблице "List" я удаляю строку

	Тогда таблица "List" стала равной:
		| 'Наименование'  | 'Код'       | 'Секретный ключ'  |
		| 'Наименование1' | '000000001' | 'Секретный ключ1' |

Сценарий: Дублирование элементов справочника "Обработчики событий" в разрезе секретного ключа
	Дано Я добавляю новый обработчик событий "Наименование1" с ключом "Секретный ключ1"

	Пусть я нажимаю на кнопку с именем 'FormCreate'
	Тогда открылось окно 'Обработчики событий (создание)'
	И в поле 'Наименование' я ввожу текст "Наименование2"
	И в поле 'Секретный ключ' я ввожу текст "Секретный ключ1"
	И я нажимаю на кнопку 'Записать'
	Когда открылось окно '1С:Предприятие'
	И элемент формы с именем "ErrorInfo" стал равен 'Не удалось записать: "Обработчики событий"!'
	И я нажимаю на кнопку 'OK'
	Тогда открылось окно 'Обработчики событий (создание) *'
	И в поле 'Секретный ключ' я ввожу текст 'Секретный ключ2'
	И я нажимаю на кнопку 'Записать и закрыть'
	И я жду закрытия окна 'Наименование2 (Обработчики событий) *' в течение 2 секунд

	Тогда таблица "List" стала равной:
		| 'Наименование'  | 'Код'       | 'Секретный ключ'  |
		| 'Наименование1' | '000000001' | 'Секретный ключ1' |
		| 'Наименование2' | '000000002' | 'Секретный ключ2' |

Сценарий: Дублирование при снятии пометки на удаление элементов справочника "Обработчики событий" в разрезе секретного ключа
	Дано Я добавляю новый обработчик событий "Наименование1" с ключом "Секретный ключ1"
	И Я добавляю новый обработчик событий "Наименование2" с ключом "Секретный ключ2"
	И в таблице "List" я перехожу к строке:
		| 'Наименование'  | 'Код'       | 'Секретный ключ'  |
		| 'Наименование2' | '000000002' | 'Секретный ключ2' |
	И я выбираю пункт контекстного меню с именем 'ListContextMenuSetDeletionMark' на элементе формы с именем "List"
	Тогда открылось окно '1С:Предприятие'
	И я нажимаю на кнопку 'Да'
	И в таблице "List" текущая строка помечена на удаление

	Пусть Я добавляю новый обработчик событий "Наименование2" с ключом "Секретный ключ2"
	И в таблице "List" я перехожу к строке:
		| 'Наименование'  | 'Код'       | 'Секретный ключ'  |
		| 'Наименование2' | '000000002' | 'Секретный ключ2' |
	И я выбираю пункт контекстного меню с именем 'ListContextMenuSetDeletionMark' на элементе формы с именем "List"
	Тогда открылось окно '1С:Предприятие'
	И я нажимаю на кнопку 'Да'
	
	Когда открылось окно '1С:Предприятие'
	И элемент формы с именем "ErrorInfo" стал равен 'Не удалось записать "Наименование2 (Обработчики событий)"!'
	И я нажимаю на кнопку 'OK'

