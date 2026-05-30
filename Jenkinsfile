pipeline {
    agent any

    tools {
        jdk 'Java 21'
        maven 'Maven 3'
    }

    environment {
        BACKEND_HOST = '192.168.56.12'
        BACKEND_USER = 'vagrant'
        APP_NAME = 'spring-petclinic-rest'
        APP_PORT = '9966'
        SPRING_PROFILES_ACTIVE = 'mysql,spring-data-jpa'
        MYSQL_URL = credentials('petclinic-mysql-url')
        MYSQL_USER = credentials('petclinic-mysql-user')
        MYSQL_PASS = credentials('petclinic-mysql-pass')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Backend') {
            steps {
                sh 'scripts/build_backend.sh'
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                junit testResults: 'target/surefire-reports/*.xml', allowEmptyResults: true
            }
        }

        stage('Deploy Backend') {
            steps {
                sh 'scripts/deploy_backend.sh'
            }
        }

        stage('Smoke Test Backend') {
            steps {
                sh 'scripts/smoke_backend.sh'
            }
        }
    }
}
