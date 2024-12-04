pipeline {
    agent any

    parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create/Destroy')
        string(name: 'ImageName', description: "name of the docker build", defaultValue: 'nginx')
        string(name: 'ImageTag', description: "tag of the docker build", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "name of the Application", defaultValue: 'deepthi555')
    }
    environment 
    {
        ACCESS_KEY = credentials('AWS_ACCESS_KEY_ID')  // AWS access key stored in Jenkins credentials
        SECRET_KEY = credentials('AWS_SECRET_KEY_ID')  // AWS secret key stored in Jenkins credentials
    }
    stages 
    {
        stage('Git Checkout'){
                    when { expression {  params.action == 'create' } }
            steps{
            gitCheckout(
                branch: "main",
                url: "https://github.com/Deepthi-123456789/case-study.git"
            )
            }
        }
        stage('Docker Image Build') 
        {
            when { expression { params.action == 'create' } }
            steps {
                echo "Starting Docker Image Build Stage"
                script {
                    sh "docker build -t ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag} ."
                }
                echo "Docker Image Build completed"
            }
        }
        stage('Docker Image Push : DockerHub')
        {
            when { expression { params.action == 'create' } }
            steps {
                echo "Starting Docker Image Push Stage"
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) 
                    {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                        sh "docker push ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag}"
                    }
                }
                echo "Docker Image Push completed"
            }
        }
        stage('Deploy to Kubernetes') 
        {
            when { expression { params.action == 'create' } }
            steps {
                echo "Starting Deploy to Kubernetes Stage"
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
                echo "Deploy to Kubernetes completed"
            }
        }
    }
    post 
    {
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
