#!/usr/bin/env bats
# Тесты bin/greet.sh. Запуск: bats test/

setup() {
    GREET="$BATS_TEST_DIRNAME/../bin/greet.sh"
}

@test "приветствует по имени" {
    run "$GREET" мир
    [ "$status" -eq 0 ]
    [ "$output" = "Привет, мир!" ]
}

@test "имя с пробелами — одним аргументом" {
    run "$GREET" "Вася Пупкин"
    [ "$status" -eq 0 ]
    [ "$output" = "Привет, Вася Пупкин!" ]
}

@test "-u — заглавными буквами" {
    run "$GREET" -u мир
    [ "$status" -eq 0 ]
    [ "$output" = "ПРИВЕТ, МИР!" ]
}

@test "без имени — код 2 и подсказка" {
    run "$GREET"
    [ "$status" -eq 2 ]
    [[ "$output" == *"использование"* ]]
}

@test "пустое имя — код 2" {
    run "$GREET" ""
    [ "$status" -eq 2 ]
}

@test "неизвестный ключ — код 2" {
    run "$GREET" -x мир
    [ "$status" -eq 2 ]
}
