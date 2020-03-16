# Тестовые данные

Настроить веб-хук, например http://git.a/a.strizhachuk/testepf/-/settings/integrations:

* `URL` к веб-сервису ИБ-распределителя;
* `Secret token` для авторизации запроса;

```txt
Project Hooks (1)
http://spbcoit58.stdp.ru/api/hs/gitlab/update-XXXXXXXXXXXXXXXXXXXXXXXXX
Push Events SSL Verification: disabled
```

Репозитории для `git push -ff`:

* `./test/repo/init` - инициализированный репозиторий с настроенным upstream;
* `./test/repo/first` - первый commit с изменением обработки (файл xml сохранен средствами 1С);
