pipeline {
    agent any

    environment {
        REGISTRY = 'your-docker-registry-url'
        IMAGE_NAME = 'your-image-name'
        KUBECONFIG = '/path/to/kubeconfig' // Set this to the Kubeconfig file's path
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo.git'
            }
        }
        stage('Build Artifact') {
            steps {
                script {
                    sh 'docker build -t ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} .'
                }
            }
        }
        stage('Push to Registry') {
            steps {
                script {
                    sh """
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                    docker push ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}
                    """
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    kubectl --kubeconfig=$KUBECONFIG set image deployment/your-deployment ${IMAGE_NAME}=${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Build and Deployment successful!"
        }
        failure {
            echo "Build or Deployment failed!"
        }
    }
}
