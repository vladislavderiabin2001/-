#!/bin/bash

echo "Генерация активности процессов..."
echo "Запуск в течение 5 минут с интервалом 10 секунд"

for round in {1..30}; do
    echo "Раунд $round/30"
    
    # Различные способы создания процессов
    # 1. Обычные команды (fork + exec)
    ls -la / > /dev/null
    ps aux > /dev/null
    cat /proc/cpuinfo > /dev/null
    
    # 2. Команды в фоне (fork + exec в фоне)
    sleep 0.1 &
    date > /dev/null &
    
    # 3. Subshell (fork)
    (echo "subshell test" > /dev/null)
    
    # 4. Pipeline (несколько fork)
    echo "test" | grep "test" | wc -l > /dev/null
    
    # 5. Command substitution (fork + exec)
    result=$(echo "command substitution")
    
    # 6. Цикл с командами
    for i in {1..10}; do
        echo $i > /dev/null
    done
    sleep 10
done

wait
echo "Генерация завершена!"
