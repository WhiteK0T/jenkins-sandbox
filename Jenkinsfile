// Пайплайн учебного репозитория: проверка shellcheck и тесты bats.
// Jenkins берёт этот файл из Git (задача «Pipeline script from SCM» или Multibranch).
pipeline {
    agent { label 'linux' }
    options {
        timestamps()
        timeout(time: 10, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '20'))
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
                sh 'bats test/'
            }
        }
        stage('Запуск') {
            steps {
                sh 'bin/greet.sh "$(git log -1 --format=%an)"'
            }
        }
    }
    post {
        always  { echo "итог: ${currentBuild.currentResult}, коммит ${env.GIT_COMMIT?.take(8)}" }
        failure { echo 'упало — смотрим, какая стадия' }
    }
}
