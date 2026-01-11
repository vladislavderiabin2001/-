#!/bin/bash

echo "Установка пакетов на клиенте..."

export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y \
    curl \
    netcat-openbsd \
    openssh-client \
    iputils-ping \
    iproute2 \
    vim

echo ""
echo "Клиент настроен!"
echo ""
echo "IP клиента:"
ip addr show eth0 | grep "inet "
