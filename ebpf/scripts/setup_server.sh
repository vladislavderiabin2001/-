#!/bin/bash

echo "Установка пакетов..."

export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y \
    apache2 \
    iptables \
    netcat-openbsd \
    openssh-server \
    iproute2 \
    iputils-ping \
    curl \
    vim \
    tcpdump \
    net-tools

echo ""
echo "Настройка Apache..."
service apache2 start
systemctl enable apache2 2>/dev/null || true

cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head><title>Firewall Test Server</title></head>
<body>
<h1>Firewall Test Server</h1>
<p>Server is running with two network interfaces</p>
<ul>
<li>Interface eth0 (external): HTTP allowed, SSH blocked</li>
<li>Interface eth1 (internal): SSH allowed</li>
</ul>
</body>
</html>
HTML

echo ""
echo "Настройка SSH..."
mkdir -p /run/sshd
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
echo "root:password123" | chpasswd
service ssh start

echo ""
echo "Проверка интерфейсов..."
ip addr show eth0
ip addr show eth1

echo "Теперь запустите: /opt/scripts/firewall.sh"
