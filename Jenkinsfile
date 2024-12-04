pipeline {
    agent any
    environment {
        // Docker image name
        DOCKER_IMAGE = "nginx:latest"
        // Kubernetes deployment name
        K8S_DEPLOYMENT = "nginx-deployment"
    }
    parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "name of the docker build", defaultValue: 'nginx')
        string(name: 'ImageTag', description: "tag of the docker build", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "name of the Application", defaultValue: 'deepthi555')
    }
    stages {
        stage('Checkout') {
            steps {
                // Checkout the latest code from the Git repository
                git branch: 'main', url: 'https://github.com/Deepthi-123456789/case-study.git'
            }
        }
        stage('Docker Image Build') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    sh "docker build -t ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag} ."
                }
            }
        }
        stage('Docker Image Push : DockerHub') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    // Docker login using stored Jenkins credentials
                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    // Docker login using the credentials from Jenkins
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
            
                    // Docker push command
                    sh "docker push ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag}"
                }
            }
        }
}
    

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    try {
                        // Apply Kubernetes deployment configuration using Helm
                        sh """
                            cd nginx
                            helm upgrade --install ${K8S_DEPLOYMENT} . --namespace default
                        """
                    } catch (Exception e) {
                        echo "Helm deployment failed."
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
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
