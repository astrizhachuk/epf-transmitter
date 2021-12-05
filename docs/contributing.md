# Участие в разработке

## Инструменты разработки

* [EDT](https://releases.1c.ru/project/DevelopmentTools10) не ниже 2020.4.0+425.

* Платформа 1С не ниже 8.3.17.1549.

* Проект создан на основе [bootstrap-1c](https://github.com/astrizhachuk/bootstrap-1c).

* Модульные тесты написаны с помощью [1CUnits](https://github.com/DoublesunRUS/ru.capralow.dt.unit.launcher) не ниже 0.4.0. См. расширение конфигурации EDT [Transmitter.Tests](https://github.com/astrizhachuk/epf-transmitter/tree/master/Transmitter.Tests).

* В качестве мок-сервера используется [MockServer](https://www.mock-server.com/#what-is-mockserver).

* Среда для `develop` и `production` разворачивается посредством [docker-compose](https://docs.docker.com/compose/).

## Процесс разработки

Предполагается следующий цикл при работе над проектом:

1. Получение последних изменений проекта из репозитория.

2. Разработка.

3. Тестирование в `develop` среде (модальные тесты, функциональные и интеграционные тесты)[^1].

4. Запрос на добавление изменений в репозиторий.

## Окружение

### Конфигурация проекта

Соберите базовые образы для работы с 1С:Предприятие 8. Проект создан с помощью образов https://github.com/astrizhachuk/onec-docker.

Переменные окружения для конфигурации проекта:

```text
DOCKER_USERNAME - учетная запись на [Docker Hub](https://hub.docker.com) или в корпоративном registry

ONEC_VERSION - версия платформы 1С:Предприятие 8, для которой собирается проект
```

Настройте подключение к серверу лицензий в файле `nethasp.ini`.

Настройте в системном hosts resolve имен сервисов из файла [docker-compose.yml](./docker-compose.yml).


``` bash
# srv - сервер 1С;
# mockserver - mock-сервер (требуется для установки заглушек веб-сервисов);
# gitlab - сервер gitlab (требуется для интеграционных тестов);
# transmitter - веб-сервер для API и веб-клиента сервиса gitlab;
# endpoint:[port] - веб-сервера получателей внешних обработок;
127.0.0.1 localhost mockserver gitlab transmitter endpoint
172.28.189.202 srv  #ult 172.28.189.202 - ip docker-демона
```


Местоположение hosts:

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

// todo переработать

```Runtime``` копирование файла в контейнер с толстым клиентом:

```bash
docker cp ./test/empty.dt gitlab-services_client_1:/tmp/empty.dt
```

```Runtime``` удаление всех данных (в т. ч. пользователей) в информационной базе через пакетный режим запуска:

```bash
docker exec gitlab-services_client_1 bash -c "/opt/1C/v8.3/x86_64/1cv8 DESIGNER /S 'srv\transmitter' /N'Администратор' /EraseData /DisableStartupDialogs"
```

```Runtime``` загрузка в ранее очищенную базу dt-файла эталонной тестовой базы через пакетный режим запуска:

```bash
# вариант для загрузки dt-файла, переданного в контейнер при его создании
docker exec gitlab-services_client_1 bash -c "/opt/1C/v8.3/x86_64/1cv8 DESIGNER /S 'srv\transmitter' /RestoreIB /home/usr1cv8/empty.dt /DisableStartupDialogs"

# вариант для загрузки dt-файла, ранее переданного в runtime
docker exec gitlab-services_client_1 bash -c "/opt/1C/v8.3/x86_64/1cv8 DESIGNER /S 'srv\transmitter' /RestoreIB /tmp/empty.dt /DisableStartupDialogs"
```

```Runtime``` загрузка в "испорченную" базу dt-файла эталонной тестовой базы через пакетный режим запуска:

```bash
# вариант для загрузки dt-файла, переданного в контейнер при его создании
docker exec gitlab-services_client_1 bash -c "/opt/1C/v8.3/x86_64/1cv8 DESIGNER /S 'srv\transmitter' /N'Администратор' /RestoreIB /home/usr1cv8/empty.dt /DisableStartupDialogs"

# вариант для загрузки dt-файла, ранее переданного в runtime
docker exec gitlab-services_client_1 bash -c "/opt/1C/v8.3/x86_64/1cv8 DESIGNER /S 'srv\transmitter' /N'Администратор' /RestoreIB /tmp/empty.dt /DisableStartupDialogs"
```

!!! warning "Внимание"
    EDT может блокировать монопольный доступ к базе когда запущен агент, что препятствует загрузке dt-файла. Перед загрузкой dt-файлов необходимо либо закрывать EDT, либо удалять блокирующие процессы на клиенте.

#### Endpoint

Запуск нескольких получающих внешние обработки информационных баз с веб-сервером, веб-клиентом и инициализацией этих баз из эталона:

``` bash
# api для база_1 - endpoint:8081/api/hs/infobase
# client для база_1 - endpoint:8081/client
# api для база_2 - endpoint:8082/api/hs/infobase
# client для база_2 - endpoint:8082/client
# и т.д.

docker-compose up --scale endpoint=2 --build endpoint
```

!!! example "Пример"
    
    Определение IP серверов с тестовыми информационными базами (custom_settings.json):

    ``` bash
    docker inspect \
        --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" \
        gitlab-services_endpoint_1 gitlab-services_endpoint_2
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

#### VA

Пример, как сложное сделать простым:

(тестирование в ```vanessa-automation```  в среде ```linux``` на ```windows``` при наличии ```WSL2``` подключившись "сбоку" еще одним контейнером)


=== "windows"

    ``` cmd
    docker run --rm ^
        -it -p 5901:5900/tcp ^
        --env-file=.env.docker ^
        --network=gitlab-services_back_net ^
        -v gitlab-services_client_data:/home/usr1cv8/.1cv8 ^
        -v $PWD/nethasp.ini:/opt/1C/v8.3/x86_64/conf/nethasp.ini ^
        -v $PWD/tools/VAParams.json:/home/usr1cv8/VAParams.json ^
        -v $PWD/:/home/usr1cv8/project ^
        %DOCKER_USERNAME%/client-vnc-va:%ONEC_VERSION%
    ```

=== "linux"

    ``` bash
    docker run --rm \
        -it -p 5901:5900/tcp \
        --env-file=.env.docker \
        --network=gitlab-services_back_net \
        -v gitlab-services_client_data:/home/usr1cv8/.1cv8 \
        -v $PWD/nethasp.ini:/opt/1C/v8.3/x86_64/conf/nethasp.ini \
        -v $PWD/tools/VAParams.json:/home/usr1cv8/VAParams.json \
        -v $PWD/:/home/usr1cv8/project \
        ${DOCKER_USERNAME}/client-vnc-va:${ONEC_VERSION}
    ```

В файле [.env.docker](./.env.docker) указываются параметры запуска толстого клиента в контейнере.

!!! hint "Подсказка"
    В файлах `linux` перевод строки - `LF`, а в `windows` - `CRLF`.

### Лаунчеры EDT

[Набор лаунчеров EDT](./tools/edt/) для запуска и тестирования под разными локализациями и в разрезе тегов.

[^1]: Приветствуются PR/MR на тестирование через CI
