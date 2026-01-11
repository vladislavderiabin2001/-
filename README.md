# Инструкция по запуску скриптов

## 1. Скрипт для преобразования IP и маски сети `norm_ip.sh`

**Описание:**  
Принимает IP адрес и, опционально, маску сети в любой форме (например, `192.168.0.1`, `192.168.0.1/24` или `192.168.0.1/255.255.255.0`) и выводит IP с маской в форме `/NN`.

**Пример запуска:**

```bash
chmod +x ip_mask.sh
./ip_mask.sh 192.168.0.1
./ip_mask.sh 10.0.0.1/8
./ip_mask.sh 172.16.0.1/255.255.0.0
```

## 2. Скрипт резервного копирования каталога `backup.sh`

**Описание:**  
Создаёт архив каталога каждые 5 минут с именем dir-YYYY-MM-DD-HH-MM-SS.tgz в /tmp/backups.

**Пример запуска:**

```bash
chmod +x backup_dir.sh
./backup_dir.sh /полный/путь/к/каталогу
```

## 3. Автоматизация резервного копирования через cron `cron_backup.sh`

- Создать скрипт
- Добавить в crontab: `crontab -e` и вставить строку: `*/5 * * * * /путь/к/cron_backup.sh /полный/путь/к/каталогу`



# Инструкция по запуску двухконтейнерного стенда с firewall

## 1. Сборка и запуск контейнеров

Находясь в каталоге с `docker-compose.yml` и папкой `scripts/`:

```bash
docker compose up -d
```

Это создаст два контейнера:
	•	firewall-server с двумя сетевыми интерфейсами: внешняя (172.18.0.10) и внутренняя (172.19.0.10).
	•	firewall-client в внутренней сети (172.19.0.20).

## 2. Настройка сервера

```bash
docker compose exec server bash
/opt/scripts/setup_server.sh
/opt/scripts/firewall.sh
```

```bash
iptables -L -n -v
iptables -t nat -L PREROUTING -n -v
```

	•	На внешнем интерфейсе разрешён HTTP (80) и DNS (53), SSH (22) блокирован.
	•	На внутреннем интерфейсе разрешён SSH и весь трафик.
	•	Проброс UDP 10000 → 20000 работает.


## 3. Настройка клиента

Выполнить внутри контейнера клиента:

```bash
docker compose exec client bash
/opt/scripts/setup_client.sh
```

```bash
ip addr show eth0
```

## 4. Тестирование соединения

### HTTP с клиента на сервер:

```bash
docker compose exec client curl http://172.18.0.10
```

### SSH с клиента на сервер:

```bash
docker compose exec client ssh root@172.19.0.10
# пароль: password123
```

### UDP проброс:

	1.	На сервере слушаем:
```bash
docker compose exec server nc -ul 20000
```
    2.	На клиенте отправляем:

```bash
docker compose exec client echo "Hello" | nc -u 172.19.0.10 10000
```

    3. Должно появиться сообщение Hello на сервере.


# Сбор статистики процессов с помощью eBPF

## 1. Сборка Docker-образа

Находясь в каталоге с `Dockerfile` и папкой `scripts/`:

```bash
docker build -t bcc-monitor .
```

Образ включает:
	•	Python3 + BCC/eBPF инструменты
	•	Скрипт генерации процессов generate_activity.sh
	•	Скрипт сбора статистики process_stats.py
    
## 2. Запуск контейнера
```bash
docker run --rm -it --privileged --pid=host --net=host \
    -v /lib/modules:/lib/modules \
    -v /usr/src:/usr/src \
    -v /sys/kernel/debug:/sys/kernel/debug \
    -v $(pwd)/scripts:/opt/scripts \
    bcc-monitor
```

В контейнере будут доступны оба скрипта.

## 3. Запуск мониторинга процессов

```bash
python3 /opt/scripts/process_stats.py
```

	•	Скрипт автоматически запускает генерацию активности процессов на 10 минут.
	•	eBPF собирает количество запусков процессов и потоков

