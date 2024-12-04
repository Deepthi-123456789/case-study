pipeline {
    agent any
    environment {
        // Docker image name
        DOCKER_IMAGE = "nginx:latest"
        // Kubernetes deployment name
        K8S_DEPLOYMENT = "nginx-deployment"
    }
    parameters{

        choice(name: 'action', choices: 'create\ndelete', description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "name of the docker build", defaultValue: 'nginx')
        string(name: 'ImageTag', description: "tag of the docker build", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "name of the Application", defaultValue: 'deepthi999')
    }
    stages {
        stage('Checkout') {
            steps {
                // Checkout the latest code from the Git repository
                git branch: 'main', url: 'https://github.com/Deepthi-123456789/case-study.git'
            }
        }
         stage('Docker Image Build'){
         when { expression {  params.action == 'create' } }
            steps{
               script{
                   
                   dockerBuild("${params.ImageName}","${params.ImageTag}","${params.DockerHubUser}")
               }
            }
        }
        stage('Docker Image Push : DockerHub '){
         when { expression {  params.action == 'create' } }
            steps{
               script{
                   
                   dockerImagePush("${params.ImageName}","${params.ImageTag}","${params.DockerHubUser}")
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
