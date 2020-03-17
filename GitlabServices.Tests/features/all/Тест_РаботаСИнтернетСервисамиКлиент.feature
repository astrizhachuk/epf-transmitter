# language: ru

@tree
@classname=ModuleExceptionPath

Функционал: Тест работа с интернет сервисами клиент
	Как Разработчик
	Я Хочу чтобы возвращаемое значение метода совпадало с эталонным
	Чтобы я мог гарантировать работоспособность метода

Сценарий: Тест_РаботаСИнтернетСервисамиКлиент (клиент): Тест_МетодПолученияОписанияВебСервисаПоАдресуСуществует
	И я выполняю код встроенного языка
	| 'Тест_РаботаСИнтернетСервисамиКлиент.Тест_МетодПолученияОписанияВебСервисаПоАдресуСуществует(Контекст());' |

Сценарий: Тест_РаботаСИнтернетСервисамиКлиент (клиент): Тест_МетодПолученияОписанияВебСервисаПоАдресуДолженВозвращатьНеопределеноЕслиПараметрФэйл
	И я выполняю код встроенного языка
	| 'Тест_РаботаСИнтернетСервисамиКлиент.Тест_МетодПолученияОписанияВебСервисаПоАдресуДолженВозвращатьНеопределеноЕслиПараметрФэйл(Контекст());' |

Сценарий: Тест_РаботаСИнтернетСервисамиКлиент (клиент): Тест_ОткликВебСервиса
	И я выполняю код встроенного языка
	| 'Тест_РаботаСИнтернетСервисамиКлиент.Тест_ОткликВебСервиса(Контекст());' |

Сценарий: Тест_РаботаСИнтернетСервисамиКлиент (клиент): Тест_МетодПолученияОписанияВебСервисаПоАдресуВозвращаетКорректнуюСтруктуруДанных
	И я выполняю код встроенного языка
	| 'Тест_РаботаСИнтернетСервисамиКлиент.Тест_МетодПолученияОписанияВебСервисаПоАдресуВозвращаетКорректнуюСтруктуруДанных(Контекст());' |

Сценарий: Тест_РаботаСИнтернетСервисамиКлиент (клиент): Тест_МетодПолученияОписанияВебСервисПоАдресуПроверкаНаСвойствоEnabled
	И я выполняю код встроенного языка
	| 'Тест_РаботаСИнтернетСервисамиКлиент.Тест_МетодПолученияОписанияВебСервисПоАдресуПроверкаНаСвойствоEnabled(Контекст());' |

Сценарий: Тест_РаботаСИнтернетСервисамиКлиент (клиент): Тест_КоллекцияОписаниеСервисаСоответствуетЭталону
	И я выполняю код встроенного языка
	| 'Тест_РаботаСИнтернетСервисамиКлиент.Тест_КоллекцияОписаниеСервисаСоответствуетЭталону(Контекст());' |