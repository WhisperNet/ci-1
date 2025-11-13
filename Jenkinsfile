pipeline {
    agent any
    
    environment {
        APP_NAME = 'demo-app'
        DOCKER_IMAGE = "${APP_NAME}:${BUILD_NUMBER}"
    }
    tools {
        nodejs 'node-22'
    }
    stages {
        stage('Build') {
            steps {
                script {
                    echo 'Building application...'
                    sh '''
                        cd app
                        npm install --include=dev
                    '''
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo 'Running unit tests...'
                    sh '''
                        cd app
                        npm test
                    '''
                }
            }
        }
        
        stage('Package') {
            steps {
                script {
                    echo 'Building Docker image...'
                    sh """
                        docker build -t ${DOCKER_IMAGE} .
                        docker tag ${DOCKER_IMAGE} ${APP_NAME}:latest
                    """
                }
            }
        }
        
       stage('Deploy') {
    steps {
        script {
            echo 'Deploying application with Docker...'
            sh """
                docker stop ${APP_NAME} || true
                docker rm ${APP_NAME} || true
                docker run -d --name ${APP_NAME} -p 3000:3000 --health-cmd='node -e \"require(\\\"http\\\").get(\\\"http://localhost:3000/health\\\", (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})\"' --health-interval=30s --health-timeout=3s --health-retries=3 --health-start-period=5s ${DOCKER_IMAGE}
            """
        }
    }
}
        
        stage('Health Check') {
            steps {
                script {
                    echo 'Verifying container health...'
                    sh '''
                        sleep 10
                        ./healthcheck.sh
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            echo 'Cleaning up...'
        }
    }
}

