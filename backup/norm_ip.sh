#!/bin/sh

input="$1"

# 1. Разбираем IP и маску
if echo "$input" | grep -q '/'; then
    ip="${input%%/*}"
    mask="${input#*/}"
else
    ip="$input"
    mask=""
fi

# 2. Проверяем корректность IP
IFS=. read -r o1 o2 o3 o4 <<EOF
$ip
EOF

for o in $o1 $o2 $o3 $o4; do
    case $o in
        ''|*[!0-9]*)
            echo "Invalid IP" >&2
            exit 1
            ;;
    esac
    [ "$o" -ge 0 ] && [ "$o" -le 255 ] || {
        echo "Invalid IP" >&2
        exit 1
    }
done

# 3. Если маска отсутствует — определяем по классу 
if [ -z "$mask" ]; then
    if   [ "$o1" -ge 1 ]   && [ "$o1" -le 126 ]; then mask=8
    elif [ "$o1" -ge 128 ] && [ "$o1" -le 191 ]; then mask=16
    elif [ "$o1" -ge 192 ] && [ "$o1" -le 223 ]; then mask=24
    else
        echo "IP does not belong to class A/B/C" >&2
        exit 1
    fi
fi

# 4. Преобразуем маску в /NN, если она в виде 255.255.255.0
if echo "$mask" | grep -q '\.'; then
    IFS=. read -r m1 m2 m3 m4 <<EOF
$mask
EOF
    binmask=""
    for m in $m1 $m2 $m3 $m4; do
        b=$(printf "%08d" "$(echo "obase=2;$m" | bc)")
        binmask="$binmask$b"
    done
    mask=$(printf "%s" "$binmask" | tr -cd '1' | wc -c)
fi

echo "$ip/$mask"
