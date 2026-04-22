pipeline {
    agent any

    stages {
        stage("build-containers") {
            steps {
                echo "building the containers"
                withCredentials([file(credentialsId: 'env-config', variable: 'ENV_FILE')]) {
                    sh '''
                        cp $ENV_FILE .env
                        docker compose up -d
                    '''
                }
            }
        }
    }
}