# jenkins-sandbox

Учебный репозиторий для практики с Jenkins: маленький shell-скрипт, тесты на [bats](https://github.com/bats-core/bats-core) и `Jenkinsfile`.

| Файл | Что это |
| :--- | :--- |
| `bin/greet.sh` | `greet.sh [-u] ИМЯ` — приветствие; `-u` — заглавными |
| `test/greet.bats` | тесты скрипта |
| `Jenkinsfile` | матрица: shellcheck и bats (отчёт JUnit) параллельно на Gentoo (агент) и Debian 13, Ubuntu 24.04 и 26.04 (одноразовая ВМ из `/srv/virt`, нужен агент с метками `linux` и `kvm`) → архив `greet-N.tar.gz` |

Локально:

```sh
shellcheck bin/*.sh
bats test/
```

Нужны `shellcheck` и `bats` (Gentoo: `dev-util/shellcheck`, `dev-util/bats`; Debian/Ubuntu и Arch: пакеты `shellcheck`, `bats`).

