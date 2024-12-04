pipeline {
    agent any
    environment {
        // Docker image name
        DOCKER_IMAGE = "deepthi999/nginx:latest"
        // Kubernetes deployment name
        K8S_DEPLOYMENT = "nginx-deployment"
    }
    stages {
        stage('Checkout') {
            steps {
                // Checkout the latest code from the Git repository
                git branch: 'main', url: 'https://github.com/Deepthi-123456789/case-study.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image using the Dockerfile
                    echo "Building Docker image..."
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }
        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    // Log in to Docker Hub and push the image to the repository
                    echo "Pushing Docker image to Docker Hub..."
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Apply Kubernetes deployment configuration
                    echo "Deploying to Kubernetes..."
                    sh """
                        cd nginx
                        helm install nginx .
                    """
                }
            }
        }
    }
    post {
        always {
            // Clean up or any post-action after the pipeline execution
            echo "Pipeline execution complete!"
        }
        success {
            echo "CI/CD Pipeline succeeded!"
        }
        failure {
            echo "CI/CD Pipeline failed."
        }
    }
}
