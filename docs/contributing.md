# Участие в разработке

## Инструменты разработки

* [EDT](https://releases.1c.ru/project/DevelopmentTools10) не ниже 2024.2.6

* Платформа 1С не ниже 8.3.17.1549

* [YAxUnit](https://github.com/bia-technologies/yaxunit) не ниже [25.04](https://github.com/bia-technologies/yaxunit/releases/tag/25.04) (см. [Transmitter.Tests](https://github.com/astrizhachuk/epf-transmitter/tree/master/Transmitter.Tests))

* [MockServer client for 1C:Enterprise Platform](https://github.com/astrizhachuk/mockserver-client-1c) (интеграционные тесты)

* [Docker-compose](https://docs.docker.com/compose)

!!! info "Информация"
    Структура проекта создана на основе [bootstrap-1c](https://github.com/astrizhachuk/bootstrap-1c).

## Процесс разработки

Предполагается следующий цикл при работе над проектом:

### 1. Подготовка к разработке

- **Получение последних изменений** проекта из репозитория
- **Настройка окружения разработки** - сборка контейнеров для разработки
- **Проверка работоспособности** всех сервисов

### 2. Разработка

- **Разработка функциональности** в локальной среде
- **Локальное тестирование** изменений

### 3. Тестирование и интеграция

- **Тестирование в `develop` среде** (юнит-тесты, функциональные и интеграционные тесты)[^1]
- **Запрос на добавление изменений** в репозиторий

!!! note "Автоматизация vs ручная настройка"

    Настройка переменных окружения, hosts и docker-образов предназначена для автоматизированной настройки среды разработки. Если предпочитаете ручную настройку, можете развернуть компоненты вручную: создать базу данных, настроить сервисы, сконфигурировать сеть и т.д.

## Настройка окружения разработки

### Конфигурация проекта

#### Обязательные переменные окружения

???+ note "Обязательные переменные окружения при конфигурации проекта"

    `DOCKER_USERNAME`

    : учетная запись [Docker Hub](https://hub.docker.com) или путь к репозиторию в локальном хранилище (см. [pull from a different registry](https://docs.docker.com/engine/reference/commandline/pull/#pull-from-a-different-registry))

    `ONEC_VERSION`

    : версия платформы "1С:Предприятие 8"

    `NETHASP_PATH`

    : путь к файлу `nethasp.ini` для получения лицензий "1С:Предприятие 8" в контейнерах

    `IB_NAME`

    : имя информационной базы на сервере "1С:Предприятие 8"

    `DB_NAME`

    : имя базы данных на сервере SQL

    `WS_USER`

    : пользователь для строки подключения веб-сервисов к информационной базе при публикации сервиса, значение по умолчанию - `сайт` (`-connstr "Srvr=srv;Ref=transmitter;usr=$WS_USER;pwd=$WS_PASSWORD"`)

    `WS_PASSWORD`

    : пароль для строки подключения веб-сервисов к информационной базе при публикации сервиса (`-connstr "Srvr=srv;Ref=transmitter;usr=$WS_USER;pwd=$WS_PASSWORD"`)

    `WS_LOCALE`

    : локализация веб-сервиса, добавляющая дополнительный путь к конечным точкам API, значение по умолчанию - `ru`

#### Создание и настройка окружения

**Шаг 1:** Создать файл `nethasp.ini` для получения лицензий "1С:Предприятие 8" в контейнерах.

**Шаг 2:** Настроить обязательные переменные окружения (см. `env.example`).

**Шаг 3:** Проверить переменные окружения (см. [Инициализация информационной базы](#инициализация)):

???+ note "Как проверить переменные окружения"

    Перед запуском контейнеров проверьте обязательные переменные окружения.

    === "windows"

        ``` cmd
        scripts\check-env.bat
        ```

        Тихий режим:

        ``` cmd
        scripts\check-env.bat --quiet
        ```

        Запуск под WSL с пробросом текущих переменных Windows:

        ``` cmd
        wsl bash -lc "DOCKER_USERNAME=\"%DOCKER_USERNAME%\" ONEC_VERSION=\"%ONEC_VERSION%\" NETHASP_PATH=\"%NETHASP_PATH%\" WS_PASSWORD=\"%WS_PASSWORD%\" ./scripts/check-env.sh"
        ```

    === "WSL/Linux/macOS"

        ``` bash
        ./scripts/check-env.sh
        ```

        Тихий режим:

        ``` bash
        ./scripts/check-env.sh --quiet
        ```

    !!! hint "Что делает флаг --quiet"

        Режим `--quiet` подавляет информационные сообщения и прогресс, оставляя только сообщения об ошибках. Коды возврата не меняются: `0` при успехе, `1` при отсутствии обязательных переменных или ошибке конфигурации.

    Скрипты возвращают код 0 при успехе и 1 при отсутствии обязательных переменных либо ошибке конфигурации `docker-compose.yml`.

    Пример шаблона переменных: `env.example` (скопируйте в `.env` и заполните значения).

**Шаг 4:** Собрать [docker-образы](https://github.com/astrizhachuk/onec-docker) для работы с 1С:Предприятие 8 (база данных, сервер 1С:Предприятие, веб-сервисы, различные сервисы для тестирования).

**Шаг 5:** Добавить в файл `hosts` необходимые для разработки/тестирования сервисы из [конфигурационного файла](https://github.com/astrizhachuk/epf-transmitter/tree/master/docker-compose.yml) проекта.

``` powershell title="hosts"
# ...
172.28.189.202 srv # сервер "1С:Предприятие 8"
127.0.0.1 transmitter # веб-сервер для API и веб-клиента разрабатываемого сервиса
127.0.0.1 endpoint # веб-сервер получателя внешних обработок (интеграционные тесты)
127.0.0.1 mockserver # mock-сервер (модульное тестирование)
127.0.0.1 gitlab # Omnibus GitLab (интеграционные тесты)
# ...
```

???+ hint "Местоположение файла"

    Файл hosts находится в разных местах в зависимости от операционной системы.

    === "windows"

        ``` cmd
        C:\Windows\System32\drivers\etc\hosts
        ```
    === "linux"

        ``` bash
        /etc/hosts
        ```

#### Transmitter

##### Инициализация информационной базы <a name="инициализация"></a>

С помощью следующей команды можно полностью автоматически собрать и развернуть среду для разработки с инициализацией информационной базы. Это делается один раз, когда нужно создать окружение "с чистого листа". Предварительно необходимо настроить переменные окружения в файле `.env` (см. `env.example`):

=== "windows"

    ``` cmd
    build.bat
    ```
=== "linux"

    ``` bash
    ./build.sh
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
    {% raw %}
    ``` bash
    docker inspect ^
        --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" ^
        epf-transmitter_endpoint_1 epf-transmitter_endpoint_2
    ```
    {% endraw %}
=== "linux"
    {% raw %}
    ``` bash
    docker inspect \
        --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" \
        epf-transmitter_endpoint_1 epf-transmitter_endpoint_2
    ```
    {% endraw %}
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
