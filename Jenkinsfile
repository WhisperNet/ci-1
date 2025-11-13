pipeline {
    agent any
    
    environment {
        APP_NAME = 'demo-app'
        DOCKER_IMAGE = "${APP_NAME}:${BUILD_NUMBER}"
    }
    tools {
        nodejs 'Node-22'
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
                    echo 'Deploying application with Docker Compose...'
                    sh '''
                        docker-compose down || true
                        docker-compose up -d
                    '''
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

