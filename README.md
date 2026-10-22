# jenkins-sandbox

Учебный репозиторий для практики с Jenkins: маленький shell-скрипт, тесты на [bats](https://github.com/bats-core/bats-core) и `Jenkinsfile`.

| Файл | Что это |
| :--- | :--- |
| `bin/greet.sh` | `greet.sh [-u] ИМЯ` — приветствие; `-u` — заглавными |
| `test/greet.bats` | тесты скрипта |
| `Jenkinsfile` | пайплайн: shellcheck → bats (отчёт JUnit) → архив `greet-N.tar.gz` → запуск |
| `Jenkinsfile.vm` | те же проверки внутри одноразовой ВМ Debian 13 (нужен агент с меткой `kvm` и `/srv/virt` на его хосте) |

Локально:

```sh
shellcheck bin/*.sh
bats test/
```

Нужны `shellcheck` и `bats` (Gentoo: `dev-util/shellcheck`, `dev-util/bats`; Debian/Ubuntu и Arch: пакеты `shellcheck`, `bats`).

