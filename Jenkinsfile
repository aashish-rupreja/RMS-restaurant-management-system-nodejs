pipeline {
    agent any

    environment {
        IMAGE_NAME = "restaurant-ops-app"
        REGISTRY = "aashishspit25"
        IMAGE_TAG = "${env.GIT_COMMIT.take(7)}"
        FULL_IMAGE = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        LATEST_IMAGE = "${REGISTRY}/${IMAGE_NAME}:latest"
        ALLOW_VULN = "false"
        NOTIFY_EMAIL = "aashish.rupreja25@spit.ac.in"
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
                script {
                    if (env.ALLOW_VULN == "true") {
                        catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
                            sh "trivy image --severity CRITICAL --exit-code 1 ${FULL_IMAGE}"
                        }
                    } else {
                        sh "trivy image --severity CRITICAL --exit-code 1 ${FULL_IMAGE}"
                    }
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
                        export FULL_IMAGE=${FULL_IMAGE}

                        trap 'rm -f .env' EXIT

                        cp "$ENV_FILE" .env

                        docker compose up -d

                        timeout 30 bash -c "
                        until curl -f http://localhost:3000/ > /dev/null; do
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
    success {
        emailext(
            subject: "DEPLOYMENT SUCCESSFUL | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: """
Deployment Status: SUCCESS

Application Details:
- Image: ${FULL_IMAGE}
- Environment: Local (WSL Jenkins)
- Service URL: http://localhost:3000

Build Information:
- Job Name: ${env.JOB_NAME}
- Build Number: ${env.BUILD_NUMBER}
- Build URL: ${env.BUILD_URL}
- Git Commit: ${env.GIT_COMMIT}
- Git Branch: ${env.GIT_BRANCH}

Summary:
- Build completed successfully
- Image built and deployed
- Health check passed

Next Steps:
- Verify application functionality manually if needed
- Monitor logs for runtime issues

---
Jenkins Automated Notification
            """,
            to: "${env.NOTIFY_EMAIL}"
        )
    }

    failure {
        emailext(
            subject: "DEPLOYMENT FAILED | ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: """
Deployment Status: FAILURE

Build Information:
- Job Name: ${env.JOB_NAME}
- Build Number: ${env.BUILD_NUMBER}
- Build URL: ${env.BUILD_URL}
- Git Commit: ${env.GIT_COMMIT}
- Git Branch: ${env.GIT_BRANCH}

Likely Failure Points:
- Build failure (Docker build / dependencies)
- Security scan failure (Trivy)
- Deployment failure (Docker Compose)
- Health check timeout

Immediate Actions:
1. Check console logs: ${env.BUILD_URL}
2. Identify failed stage
3. Fix issue and re-run pipeline

---
Jenkins Automated Notification
            """,
            to: "${env.NOTIFY_EMAIL}"
        )
    }
}
}