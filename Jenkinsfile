pipeline {
    agent any

    stages {
        stage("build-containers") {
            steps {
                echo "building the containers"
                withCredentials([file(credentialsId: 'env-config', variable: 'ENV_FILE')]) {
                    sh '''
                        set -e
                        docker compose down || echo "No existing containers"
                        cp $ENV_FILE .env
                        docker compose up -d
                        rm -f .env
                    '''
                }
            }
        }
    }
}