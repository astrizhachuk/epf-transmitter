# Разворачивание сервиса

Для разворачивания сервиса в продуктивной среде используется docker-compose и CI/CD GitLab.

В процессе разработки и для доставки кода применяется [семантическое версионирование](https://semver.org) и [Gitlab Flow](https://docs.gitlab.com/ee/topics/gitlab_flow.html).

Управление процессом доставки осуществляется через [Environments](https://docs.gitlab.com/ee/ci/environments/index.html), а запускает процесс доставки установка в репозитории соответствующего тега. Кроме продуктивной среды поддерживается [Review App](https://docs.gitlab.com/ee/ci/review_apps/).

Сервис устанавливается на сервер, на котором установлен docker-compose и gitlab-runner (shell), подключенный к репозиторию проекта.

Описание парамеров и режимов запуска разворачиваемого сервиса можно найти в файле [.gitlab-ci.yml](../.gitlab-ci.yml), а также в [настройках конфигурации](../production.yml) самого сервиса.

## Production

Для запуска разворачивания сервиса необходимо установить тег с номером релиза, который должен предваряться символом `v`, например, `v1.0.0`.

Если сервис публикуется впервые, то будет произведена инициализации нового сервиса, иначе - только обновление кода. Данное поведение можно изменить, присвоив переменной окружения `CHECK_NEW_INSTANCE` значение `"false"`. Данный параметр включает/отключает автоматическое определение наличия ранее развернутого сервиса.

Через переменную `FLAG_USE_ONLY_IBCMD` можно управлять способом обновления: пакетный режим запуска (по умолчанию) или через автономный сервер (`FLAG_USE_ONLY_IBCMD: "true"`).

После установки сервис будет доступен по адресу (по умолчанию): `http://127.0.0.1:8090/api/hs/gitlab/services`

## Review App

При установке тега, начинающегося с `review-`, будет запущено создание сервиса для ревью. Доступ к сервису осуществляется на порту, указанному в переменной окружения `REVIEW_PORT`. Для ревью всегда создается новый сервис, который после ревью удаляется.

Одномоментно поддерживается только одно ревью.

Сервис для ревью будет доступен по адресу (по умолчанию): `http://127.0.0.1:8091/api/hs/gitlab/services`