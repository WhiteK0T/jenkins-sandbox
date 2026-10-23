// Пайплайн учебного репозитория (этап 8 — матрица): одни и те же проверки параллельно
// на нескольких системах. gentoo — прямо на агенте; остальные — одноразовые ВМ из /srv/virt.
// Новая система = образ в /srv/virt/base + строка в vms.conf + значение в оси PLATFORM.

// Выполнить команду «на платформе»: на агенте или по SSH внутри ВМ.
// Команда идёт через переменную окружения — без экранирования кавычек.
def onPlatform(String platform, String cmd, boolean returnStatus = false) {
    def rc
    withEnv(["CMD=${cmd}", "TARGET=${platform}"]) {
        if (platform == 'gentoo') {
            rc = sh(script: 'sh -c "$CMD"', returnStatus: returnStatus)
        } else {
            rc = sh(script: '"$VIRT/bin/vm-ssh" "$TARGET" "$CMD"', returnStatus: returnStatus)
        }
    }
    return rc
}

pipeline {
    agent none
    parameters {
        choice(name: 'ONLY', choices: ['все', 'gentoo', 'debian-13'],
               description: 'Прогнать на всех системах или только на одной')
    }
    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '5'))
    }
    triggers {
        // вебхуки до Jenkins на localhost не дойдут — опрашиваем Git раз в ~5 минут;
        // триггер регистрируется после первой сборки
        pollSCM('H/5 * * * *')
    }
    stages {
        stage('Системы') {
            matrix {
                axes {
                    axis {
                        name 'PLATFORM'
                        values 'gentoo', 'debian-13'
                    }
                }
                when {
                    // первая сборка идёт без параметров (params.ONLY == null) — тогда все системы
                    expression { params.ONLY == null || params.ONLY == 'все' || params.ONLY == env.PLATFORM }
                }
                agent { label 'linux && kvm' }
                environment {
                    // служба агента стартует без LANG (локаль C) — кириллица в тестах сломается
                    LC_ALL = 'C.UTF-8'
                    VIRT   = '/srv/virt'
                    VM_ID  = "b${env.BUILD_NUMBER}-${currentBuild.startTimeInMillis}"
                }
                stages {
                    stage('Прогон') {
                        options {
                            // SSH-порт ВМ фиксированный — одна машина каждого типа за раз.
                            // lock именно здесь: в options самой матрицы значение оси ещё не известно (было бы vm-null)
                            lock(resource: "vm-${env.PLATFORM}")
                        }
                        stages {
                            stage('ВМ: запуск') {
                                when { expression { env.PLATFORM != 'gentoo' } }
                                steps {
                                    sh '"$VIRT/bin/vm-up" "$PLATFORM" "$VM_ID"'
                                    sh '"$VIRT/bin/vm-ssh" "$PLATFORM" --scp bin vm:bin'
                                    sh '"$VIRT/bin/vm-ssh" "$PLATFORM" --scp test vm:test'
                                }
                            }
                            stage('Окружение') {
                                steps {
                                    script { onPlatform(env.PLATFORM, 'uname -sr; grep PRETTY_NAME /etc/os-release; bats --version') }
                                }
                            }
                            stage('shellcheck') {
                                steps {
                                    script { onPlatform(env.PLATFORM, 'shellcheck bin/*.sh') }
                                }
                            }
                            stage('Тесты') {
                                steps {
                                    // код выхода bats сборку не роняет — упавшие тесты разберёт junit (→ UNSTABLE)
                                    script {
                                        onPlatform(env.PLATFORM, 'rm -rf reports && mkdir reports && ' +
                                            'bats --print-output-on-failure --report-formatter junit --output reports test/', true)
                                    }
                                    script {
                                        if (env.PLATFORM != 'gentoo') {
                                            sh 'rm -rf reports && mkdir reports && "$VIRT/bin/vm-ssh" "$PLATFORM" --scp vm:reports/report.xml reports/'
                                        }
                                    }
                                }
                                post {
                                    // отчёта нет (bats не запустился) — junit упадёт, и сборка станет FAILURE
                                    always { junit 'reports/*.xml' }
                                }
                            }
                        }
                        post {
                            // ВМ гасим при любом исходе — иначе она займёт порт и память до перезагрузки хоста
                            always {
                                script {
                                    if (env.PLATFORM != 'gentoo') {
                                        sh '"$VIRT/bin/vm-down" "$PLATFORM" "$VM_ID"'
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        stage('Упаковка') {
            agent { label 'linux' }
            steps {
                // workspace не очищается между сборками: без rm -rf в архив попали бы и старые greet-N
                sh 'rm -rf dist && mkdir dist && tar czf "dist/greet-${BUILD_NUMBER}.tar.gz" bin/ README.md'
                archiveArtifacts artifacts: 'dist/*.tar.gz', fingerprint: true
            }
        }
    }
    post {
        always   { echo "итог: ${currentBuild.currentResult}" }
        unstable { echo 'собралось, но есть упавшие тесты — см. Test Result (по системам)' }
        failure  { echo 'упало — смотрим, на какой системе и в какой стадии' }
    }
}
