// Пайплайн учебного репозитория: проверка shellcheck, тесты bats с отчётом JUnit, архив.
// Jenkins берёт этот файл из Git (задача «Pipeline script from SCM» или Multibranch).
pipeline {
    agent { label 'linux' }
    options {
        timestamps()
        timeout(time: 10, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '5'))
    }
    environment {
        // служба агента стартует без LANG (локаль C) — кириллица в тестах сломается
        LC_ALL = 'C.UTF-8'
    }
    triggers {
        // вебхуки до Jenkins на localhost не дойдут — опрашиваем Git раз в ~5 минут;
        // триггер регистрируется после первой сборки
        pollSCM('H/5 * * * *')
    }
    stages {
        stage('Проверка') {
            steps {
                sh 'shellcheck bin/*.sh'
            }
        }
        stage('Тесты') {
            steps {
                sh 'rm -rf reports && mkdir reports'
                // код выхода bats не роняет сборку: упавшие тесты разберёт шаг junit
                // и пометит сборку UNSTABLE (жёлтой), а не FAILURE
                sh script: 'bats --timing --print-output-on-failure --report-formatter junit --output reports test/',
                   returnStatus: true
            }
            post {
                // отчёта нет (bats не запустился) — junit упадёт, и сборка станет FAILURE
                always { junit 'reports/*.xml' }
            }
        }
        stage('Упаковка') {
            steps {
                sh 'tar czf "greet-${BUILD_NUMBER}.tar.gz" bin/ README.md'
                archiveArtifacts artifacts: 'greet-*.tar.gz', fingerprint: true
            }
        }
        stage('Запуск') {
            steps {
                sh 'bin/greet.sh "$(git log -1 --format=%an)"'
            }
        }
    }
    post {
        always   { echo "итог: ${currentBuild.currentResult}, коммит ${env.GIT_COMMIT?.take(8)}" }
        unstable { echo 'собралось, но есть упавшие тесты — см. Test Result' }
        failure  { echo 'упало — смотрим, какая стадия' }
    }
}
