#!/bin/bash

EXT_IF="eth1"  # Первая сетевая карта - 172.18.0.10
INT_IF="eth0"  # Вторая сетевая карта - 172.19.0.10

EXT_IP=$(ip -4 addr show $EXT_IF | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
INT_IP=$(ip -4 addr show $INT_IF | grep -oP '(?<=inet\s)\d+(\.\d+){3}')


# Очистка всех правил
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Политика по умолчанию - DROP (блокируем всё по умолчанию)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Разрешить loopback
iptables -A INPUT -i lo -j ACCEPT

# Разрешить established и related соединения
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 1. Разрешить ТОЛЬКО TCP порт 80 (HTTP)
iptables -A INPUT -i $EXT_IF -p tcp --dport 80 -j ACCEPT

# 2. Разрешить ТОЛЬКО UDP порт 53 (DNS)
iptables -A INPUT -i $EXT_IF -p udp --dport 53 -j ACCEPT
echo "✓ UDP порт 53 (DNS) разрешен"

# 3. Явно блокировать SSH (порт 22) на первой карте
iptables -A INPUT -i $EXT_IF -p tcp --dport 22 -j DROP

# 4. Всё остальное на первой карте блокируется политикой DROP
# 5. Разрешить SSH ТОЛЬКО со второй сетевой карты
iptables -A INPUT -i $INT_IF -p tcp --dport 22 -j ACCEPT

# 6. Разрешить весь остальной трафик на второй карте (опционально)
iptables -A INPUT -i $INT_IF -j ACCEPT
echo "✓ Весь трафик разрешен на внутреннем интерфейсе"

# Входящие пакеты на UDP 10000 второго адаптера -> UDP 20000 первого адаптера
iptables -t nat -A PREROUTING -i $INT_IF -p udp --dport 10000 \
    -j DNAT --to-destination $EXT_IP:20000
    
iptables -A FORWARD -i $INT_IF -o $EXT_IF -p udp --dport 20000 -j ACCEPT

# Разрешаем прием на порт 20000
iptables -A INPUT -i $EXT_IF -p udp --dport 20000 -j ACCEPT
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1

#Для проверки правил:
#iptables -L INPUT -n -v"
#iptables -t nat -L PREROUTING -n -v"
