pipeline {
    agent any
    stages {
        stage("1. Build Images") {
            steps {
                echo "building the images"
                sh "docker compose build"
            }
        }

        stage("2. Scan Images") {
            steps {
                echo "scanning the images"
                sh "trivy image --severity HIGH,CRITICAL --exit-code 0 restaurant-ops-app:latest"
            }
        }

        stage("3. Run Unit Tests") {
            steps {
                echo "unit-tests will be triggered once added"
            }
        }

        stage("4. Build Containers") {
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