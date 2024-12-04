pipeline {
    agent any

    parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "Name of the Docker image to build", defaultValue: 'nginx')
        string(name: 'ImageTag', description: "Tag for the Docker image", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "DockerHub username", defaultValue: 'deepthi555')
    }

    environment {
        ACCESS_KEY = credentials('AWS_ACCESS_KEY_ID')  // AWS access key stored in Jenkins credentials
        SECRET_KEY = credentials('AWS_SECRET_KEY_ID')  // AWS secret key stored in Jenkins credentials
    }

    stages {
        stage('Checkout') {
            steps {
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
                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                        sh "docker push ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag}"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    try {
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
