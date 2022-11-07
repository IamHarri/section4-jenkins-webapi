pipeline {
    agent {
        label 'master' // choose slave to build
    }
    environment{
        WORKPLACE_DIR="/var/lib/jenkins/workspace/webapi"
        TEST_DIR="/var/lib/jenkins/workspace/webapi/unittest"
        DOCKER_IMAGE="longlc3/devops01-nginx"
        ANSIBLE_PATH="/var/lib/jenkins/workspace/webapi/ansible"
        WEDAPI_DIR="/var/lib/jenkins/workspace/webapi/webapi"
        sqScannerMsBuildHome = tool "sonar-scanner" // Need this plugin and define this tool in global tools or configure system
    }
    stages {
        stage("Build Stage"){
            steps{
                
                sh 'docker-compose build'
                withCredentials([usernamePassword(credentialsId: 'docker-credential', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin'
                    sh "docker push $DOCKER_IMAGE"
                }

            }
        }
        stage("Security Stage"){
            parallel {
                stage("Test Stage"){
                    tools {
                        allure 'allure2.2' // Need this plugin and define it in global tools or configure system
                    }
                    agent {
                        label "slave1ch"
                    }
                    steps{
                        dir("$TEST_DIR"){
                            sh 'dotnet test -o target'
                            script{
                                allure ([
                                    includeProperties: false,
                                    jdk:'',
                                    properties: [],
                                    reportBuildPolicy: 'ALWAYS',
                                    results: [[path: 'target/allure-results']]
                                ])
                            }
                        }
                    }
                }

                stage("Scan Security"){
                    agent {
                        label "master"
                    }
                    steps{
                        dir("$WEDAPI_DIR"){
                            // Need to define 'sonar-server' in configure system
                            withSonarQubeEnv('sonar-server') {
                                sh "dotnet ${sqScannerMsBuildHome}/SonarScanner.MSBuild.dll begin /k:\"sonar-project\""
                                sh "dotnet build"
                                sh "dotnet ${sqScannerMsBuildHome}/SonarScanner.MSBuild.dll end"
                            }

                            
                        }
                    }
                }
            }
        }
        stage("Deploy Stage"){
            options {
                timeout(time: 10, unit: 'MINUTES')
            }
            steps {
                dir("$ANSIBLE_PATH"){
                    withCredentials([usernamePassword(credentialsId: 'docker-credential', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        ansiblePlaybook(
                            credentialsId: 'ssh-key',
                            playbook: 'playbook.yml',
                            inventory: 'inventory.ini',
                            become: 'yes',
                            extraVars: [
                                DOCKER_USERNAME: "$DOCKER_USERNAME",  
                                DOCKER_PASSWORD: "$DOCKER_PASSWORD",
                                WORKPLACE_DIR: "$WORKPLACE_DIR",
                                IMAGE_NAME: "$DOCKER_IMAGE"
                            ]
                        )
                    }
                    
                }
                
            }
        }

    }
    post { 
        always { 
            echo "Pipeline is finish with status !"
        }
        success {
            echo "SUCCEED"
        }
        failure {
            echo "FAIL"
        }
    }
}