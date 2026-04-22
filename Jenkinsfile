pipeline {
    agent any

    stages {
        stage("build-containers") {
            steps {
                echo "building the containers"
                sh "docker-compose up -d"
            }
        }
    }
}