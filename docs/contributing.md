# Участие в разработке

## Инструменты разработки

* [EDT](https://releases.1c.ru/project/DevelopmentTools10) не ниже 2020.4.0+425

* Платформа 1С не ниже 8.3.17.1549

* [1CUnits](https://github.com/DoublesunRUS/ru.capralow.dt.unit.launcher) не ниже 0.4.0 (см. [Transmitter.Tests](https://github.com/astrizhachuk/epf-transmitter/tree/master/Transmitter.Tests))

* [MockServer client for 1C:Enterprise Platform](https://github.com/astrizhachuk/mockserver-client-1c)

* [Docker-compose](https://docs.docker.com/compose)

!!! info "Информация"
    Структура проекта создана на основе [bootstrap-1c](https://github.com/astrizhachuk/bootstrap-1c).

## Процесс разработки

Предполагается следующий цикл при работе над проектом:

1. Получение последних изменений проекта из репозитория.

2. Разработка.

3. Тестирование в `develop` среде (модальные тесты, функциональные и интеграционные тесты)[^1].

4. Запрос на добавление изменений в репозиторий.

## Окружение

### Конфигурация проекта

1. Собрать [docker-образы](https://github.com/astrizhachuk/onec-docker) для работы с 1С:Предприятие 8.

    ???+ note "Обязательные переменные окружения при конфигурации проекта"

        `DOCKER_USERNAME`

        : учетная запись [Docker Hub](https://hub.docker.com) или путь к репозиторию в локальном хранилище (см. [pull from a different registry](https://docs.docker.com/engine/reference/commandline/pull/#pull-from-a-different-registry))

        `ONEC_VERSION`
        
        : версия платформы "1С:Предприятие 8"

2. Сконфигурировать `nethasp.ini` для получение лицензий "1С:Предприятие 8" в контейнерах.

3. Добавить в файл `hosts` необходимые для разработки/тестирования сервисы из [конфигурационного файла](https://github.com/astrizhachuk/epf-transmitter/tree/master/docker-compose.yml) проекта.

    ``` powershell title="hosts"
    # ...
    172.28.189.202 srv # сервер "1С:Предприятие 8"
    127.0.0.1 transmitter # веб-сервер для API и веб-клиента разрабатываемого сервиса
    127.0.0.1 endpoint # веб-сервер получателя внешних обработок (интеграционные тесты)
    127.0.0.1 mockserver # mock-сервер (модульное тестирование)
    127.0.0.1 gitlab # Omnibus GitLab (интеграционные тесты)
    # ...
    ```

    ??? hint "Местоположение файла"

        === "windows"

            ``` cmd
            C:\Windows\System32\drivers\etc\hosts
            ```

        === "linux"

            ``` bash
            /etc/hosts
            ```

### Операции с окружением

#### Transmitter

##### Инициализация информационной базы

``` bash
docker-compose up --build -d init
docker-compose rm -fs init ras
```

Строка подключения к информационной базе - `Srvr=srv;Ref=transmitter;`.

##### Запуск сервиса

``` bash
docker-compose up -d transmitter
```

##### Остановка сервиса

```bash
docker-compose stop transmitter
```

#### Endpoint

Запуск нескольких получающих внешние обработки информационных баз с веб-сервером, веб-клиентом и инициализацией этих баз из эталона:

``` bash
docker-compose up --scale endpoint=2 --build endpoint
```

!!! example "Результат"

    === "Приемник 1"

        http://endpoint:8081/api/hs/infobase

        http://endpoint:8081/client

    === "Приемник 2"

        http://endpoint:8082/api/hs/infobase

        http://endpoint:8082/client

!!! bug "Ошибка"

    В последних версиях `docker-compose` "что-то пошло не так" с распределением заданного в конфигурационном файле диапазона портов. Запускается только один контейнер. Проблема требует анализа.

Определение внутренних IP адресов:

=== "windows"

    ``` bash
    docker inspect ^
        --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" ^
        epf-transmitter_endpoint_1 epf-transmitter_endpoint_2
    ```

=== "linux"

    ``` bash
    docker inspect \
        --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" \
        epf-transmitter_endpoint_1 epf-transmitter_endpoint_2
    ```

#### GitLab

##### Создание архива

``` bash
docker-compose exec gitlab /backup.sh
```

##### Восстановление из архива

``` bash
docker-compose exec gitlab /restore.sh
```

### EDT

* [Лаунчеры](https://github.com/astrizhachuk/epf-transmitter/tree/master/tools/edt/) для тестирования и запуска приложения

[^1]: Было бы неплохо автоматизировать тестирование...
