pipeline {
    agent any
    environment {
        REGISTRY = 'your-dockerhub-username'
        APP_NAME = 'nodejs-sample-app'
        KUBE_CONFIG_PATH = credentials('kubeconfig-credentials-id')
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo/nodejs-sample-app.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $REGISTRY/$APP_NAME:${BUILD_NUMBER} .
                docker login -u your-dockerhub-username -p your-password
                docker push $REGISTRY/$APP_NAME:${BUILD_NUMBER}
                '''
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl set image deployment/$APP_NAME $APP_NAME=$REGISTRY/$APP_NAME:${BUILD_NUMBER} --kubeconfig=$KUBE_CONFIG_PATH
                '''
            }
        }
    }
    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
