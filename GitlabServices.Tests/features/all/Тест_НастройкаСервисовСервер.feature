# language: ru

@tree
@classname=ModuleExceptionPath

Функционал: Настройка сервисов
	Как Разработчик
	Я Хочу чтобы возвращаемое значение метода совпадало с эталонным
	Чтобы я мог гарантировать работоспособность метода

@OnServer
Сценарий: Тест_НастройкаСервисовСервер (сервер): Тест_ПараметрыСервисаПолучателя
	И я выполняю код встроенного языка на сервере
	| 'Тест_НастройкаСервисовСервер.Тест_ПараметрыСервисаПолучателя(Контекст());' |

@OnServer
Сценарий: Тест_НастройкаСервисовСервер (сервер): Тест_НастройкиСервисовGitLab
	И я выполняю код встроенного языка на сервере
	| 'Тест_НастройкаСервисовСервер.Тест_НастройкиСервисовGitLab(Контекст());' |