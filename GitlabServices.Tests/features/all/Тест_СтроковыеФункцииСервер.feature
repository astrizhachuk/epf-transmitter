# language: ru

@tree
@classname=ModuleExceptionPath

Функционал: GitLabServices.Tests.Тест_СтроковыеФункцииСервер
	Как Разработчик
	Я Хочу чтобы возвращаемое значение метода совпадало с эталонным
	Чтобы я мог гарантировать работоспособность метода

@OnServer
Сценарий: ПерекодироватьСтроку
	И я выполняю код встроенного языка на сервере
	| 'Тест_СтроковыеФункцииСервер.ПерекодироватьСтроку(Контекст());' |