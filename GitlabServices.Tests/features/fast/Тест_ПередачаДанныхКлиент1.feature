# language: ru

@tree
@classname=ModuleExceptionPath

Функционал: GitLabServices.Tests.Тест_ПередачаДанныхКлиент1
	Как Разработчик
	Я Хочу чтобы возвращаемое значение метода совпадало с эталонным
	Чтобы я мог гарантировать работоспособность метода

Сценарий: Тест_СервисПолучателяДоступен
	И я выполняю код встроенного языка
	| 'Тест_ПередачаДанныхКлиент1.Тест_СервисПолучателяДоступен(Контекст());' |

Сценарий: Тест_ПередачаДвоичныхДанных
	И я выполняю код встроенного языка
	| 'Тест_ПередачаДанныхКлиент1.Тест_ПередачаДвоичныхДанных(Контекст());' |