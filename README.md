# jenkins-sandbox

Учебный репозиторий для практики с Jenkins: маленький shell-скрипт, тесты на [bats](https://github.com/bats-core/bats-core) и `Jenkinsfile`.

| Файл | Что это |
| :--- | :--- |
| `bin/greet.sh` | `greet.sh [-u] ИМЯ` — приветствие; `-u` — заглавными |
| `test/greet.bats` | тесты скрипта |
| `Jenkinsfile` | пайплайн: shellcheck → bats → запуск |

Локально:

```sh
shellcheck bin/*.sh
bats test/
```

Нужны `shellcheck` и `bats` (Gentoo: `dev-util/shellcheck`, `dev-util/bats`; Debian/Ubuntu и Arch: пакеты `shellcheck`, `bats`).

