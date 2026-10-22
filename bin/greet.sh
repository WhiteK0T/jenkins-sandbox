#!/bin/sh
# Учебный скрипт для Jenkins: приветствует по имени.
#   greet.sh [-u] ИМЯ   -u — заглавными буквами
# Коды выхода: 0 — успех, 2 — неверные аргументы.
set -eu

usage() {
    echo "использование: $0 [-u] ИМЯ" >&2
    exit 2
}

upper=0
while getopts u opt; do
    case "$opt" in
        u) upper=1 ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

[ $# -eq 1 ] || usage
name=$1
[ -n "$name" ] || usage

msg="Привет, $name!"
if [ "$upper" -eq 1 ]; then
    # awk, а не tr: tr в glibc не меняет регистр кириллицы в UTF-8
    msg=$(printf '%s\n' "$msg" | awk '{ print toupper($0) }')
fi
printf '%s\n' "$msg"
