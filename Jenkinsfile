pipeline {
    agent any

    environment {
        IMAGE_NAME = "restaurant-ops-app"
        REGISTRY = "aashishspit25"
        IMAGE_TAG = "${env.GIT_COMMIT.take(7)}"
        FULL_IMAGE = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        LATEST_IMAGE = "${REGISTRY}/${IMAGE_NAME}:latest"
    }

    stages {

        stage("1. Run Unit Tests") {
            steps {
                echo "Running unit tests"
            }
        }

        stage("2. Build Image") {
            steps {
                echo "Building Docker image"
                sh """
                    docker build -t ${FULL_IMAGE} .
                    docker tag ${FULL_IMAGE} ${LATEST_IMAGE}
                """
            }
        }

        stage("3. Security Scan") {
            steps {
                echo "Scanning image with Trivy"

                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh """
                        trivy image --severity CRITICAL --exit-code 1 ${FULL_IMAGE}
                    """
                }
            }
        }

        stage("4. Push Image") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${FULL_IMAGE}
                        docker push ${LATEST_IMAGE}
                    """
                }
            }
        }

        stage("5. Deploy") {
            steps {
                echo "Deploying new container safely"

                withCredentials([file(credentialsId: 'env-config', variable: 'ENV_FILE')]) {
                    sh '''
                        set -e
                        export FULL_IMAGE='"${FULL_IMAGE}"'

                        trap 'rm -f .env' EXIT

                        cp "$ENV_FILE" .env

                        docker pull "$FULL_IMAGE"

                        docker compose up -d

                        timeout 60 bash -c "
                        until curl -f http://localhost:3000/health; do
                            sleep 2
                        done
                        "

                        echo "App is healthy"
                    '''
                }
            }
        }
    }

    post {
        failure {
            echo "Pipeline failed. Investigate immediately."
        }
        success {
            echo "Deployment successful: ${FULL_IMAGE}"
        }
    }
}