#!/bin/bash

set -e

echo "[SCRIPT] Начинаем инициализацию PostgreSQL информационной базы..."

# Ждем готовности сервера кластера
echo "[SCRIPT] Ожидание готовности сервера кластера..."
for i in {1..15}; do
    if /opt/1cv8/current/rac cluster list ras >/dev/null 2>&1; then
        echo "[SCRIPT] Сервер кластера готов"
        break
    fi
    echo "[SCRIPT] Попытка $i/15 - сервер кластера еще не готов"
    sleep 2
done

# Получаем ID кластера
echo "[SCRIPT] Получение ID кластера..."
CLUSTER_LIST_OUTPUT=$(/opt/1cv8/current/rac cluster list ras)
echo "[SCRIPT] Вывод команды rac cluster list:"
echo "$CLUSTER_LIST_OUTPUT"
CLUSTER_ID=$(echo "$CLUSTER_LIST_OUTPUT" | grep cluster | awk '{print $3}')
if [ -z "$CLUSTER_ID" ]; then
    echo "[SCRIPT] Не удалось получить ID кластера"
    echo "[SCRIPT] Проверьте, что сервер кластера запущен и доступен"
    exit 1
fi
echo "[SCRIPT] ID кластера: $CLUSTER_ID"

# Проверяем, существует ли уже информационная база в кластере
echo "[SCRIPT] Проверка существования информационной базы в кластере..."
RAC_LIST_OUTPUT=$(/opt/1cv8/current/rac infobase summary list --cluster="$CLUSTER_ID" ras 2>&1)
if [ -n "$RAC_LIST_OUTPUT" ]; then
    echo "[SCRIPT] Вывод команды rac infobase summary list:"
    echo "$RAC_LIST_OUTPUT"
else
    echo "[SCRIPT] Список информационных баз пуст"
fi

if [ -n "$RAC_LIST_OUTPUT" ] && echo "$RAC_LIST_OUTPUT" | grep -q "transmitter"; then
    echo "[SCRIPT] Информационная база уже зарегистрирована в кластере"
    echo "[SCRIPT] Пропускаем создание информационной базы"
else
    echo "[SCRIPT] Информационная база не найдена в кластере, создаем новую..."
    
    # Создаем информационную базу в кластере с автоматическим созданием базы данных
    echo "[SCRIPT] Создание информационной базы в кластере с автоматическим созданием базы данных..."
    RAC_CREATE_OUTPUT=$(/opt/1cv8/current/rac infobase \
        --cluster="$CLUSTER_ID" \
        create \
        --name=transmitter \
        --dbms=PostgreSQL \
        --db-server=db \
        --db-name=transmitter \
        --locale=ru \
        --db-user=postgres \
        --license-distribution=allow \
        --create-database \
        ras 2>&1)
    
    echo "[SCRIPT] Вывод команды rac infobase create:"
    echo "$RAC_CREATE_OUTPUT"
    
    if echo "$RAC_CREATE_OUTPUT" | grep -q "infobase.*:"; then
        echo "[SCRIPT] Информационная база создана и зарегистрирована в кластере"
        
        # Пробуем восстановить данные после создания
        echo "[SCRIPT] Проверка файла данных..."
        if [ -f "/tmp/data.dt" ]; then
            echo "[SCRIPT] Файл данных найден: /tmp/data.dt"
            echo "[SCRIPT] Размер файла: $(ls -lh /tmp/data.dt | awk '{print $5}')"
            echo "[SCRIPT] Попытка восстановления данных..."
            if /opt/1cv8/current/ibcmd infobase restore \
                --db-server=db \
                --dbms=PostgreSQL \
                --db-name=transmitter \
                --db-user=postgres \
                /tmp/data.dt; then
                echo "[SCRIPT] Данные восстановлены успешно"
            else
                echo "[SCRIPT] Не удалось восстановить данные, но база создана"
                echo "[SCRIPT] Код возврата: $?"
            fi
        else
            echo "[SCRIPT] Файл данных /tmp/data.dt не найден, пропускаем восстановление"
        fi
    else
        echo "[SCRIPT] Ошибка создания информационной базы в кластере"
        echo "[SCRIPT] Код возврата: $?"
        # Проверяем, может быть база уже зарегистрирована
        echo "[SCRIPT] Проверяем, может быть база уже зарегистрирована..."
        RAC_CHECK_OUTPUT=$(/opt/1cv8/current/rac infobase summary list --cluster="$CLUSTER_ID" ras 2>&1)
        if echo "$RAC_CHECK_OUTPUT" | grep -q "transmitter"; then
            echo "[SCRIPT] Информационная база уже зарегистрирована в кластере"
        else
            echo "[SCRIPT] Критическая ошибка - база не зарегистрирована"
            exit 1
        fi
    fi
fi

echo "[SCRIPT] Инициализация завершена успешно"
echo "[SCRIPT] Информационная база готова к использованию"
echo "[SCRIPT] Строка подключения: Srvr=srv;Ref=transmitter;"
