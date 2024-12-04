pipeline {
    agent any
    tools {
        git 'Git'  
    }
    
    parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "Name of the Docker image", defaultValue: 'nginx')
        string(name: 'ImageTag', description: "Tag of the Docker image", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "Docker Hub Username", defaultValue: 'deepthi555')
    }
    environment {
        ACCESS_KEY = credentials('AWS_ACCESS_KEY_ID')
        SECRET_KEY = credentials('AWS_SECRET_KEY_ID')
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
                    echo "Building Docker image ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag}"
                    sh "docker build -t ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag} ."
                }
            }
        }
        stage('Docker Image Push : DockerHub') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        echo "Logging into Docker Hub..."
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                        echo "Pushing Docker image ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag}"
                        sh "docker push ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag}"
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    try {
                        echo "Deploying to Kubernetes using Helm..."
                        sh """
                        export AWS_ACCESS_KEY_ID=$ACCESS_KEY
                        export AWS_SECRET_ACCESS_KEY=$SECRET_KEY
                        cd nginx
                        helm upgrade --install nginx-deployment . --namespace default
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
