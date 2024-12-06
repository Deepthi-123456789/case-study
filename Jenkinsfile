pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1' // Replace with your AWS region
        KUBECONFIG = 'kubeconfig' // Path to kubeconfig (generated dynamically)
    }
    parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create/destroy')
        string(name: 'ImageName', description: "Name of the Docker build", defaultValue: 'web')
        string(name: 'ImageTag', description: "Tag of the Docker build", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "DockerHub Username", defaultValue: 'deepthi555')
    }
    stages {
        stage('Checkout SCM') {
            when { expression { params.action == 'create' } }
            steps {
                sh '''
                    rm -rf case-study
                    git clone https://github.com/Deepthi-123456789/case-study.git
                '''
            }
        }
        
        // Docker Image Build Stage
        stage('Docker Image Build') {
            when { expression { params.action == 'create' } }
            steps {
                sh """
                    docker build -t ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag} .
                """
            }
        }

        // Docker Image Push Stage
        stage('Docker Image Push') {
            when { expression { params.action == 'create' } }
            steps {
                echo "Starting Docker Image Push Stage"
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                        sh "docker push ${params.DockerHubUser}/${params.ImageName}:${params.ImageTag}"
                    }
                }
                echo "Docker Image Push completed"
            }
        }

        stage('Init') {
            when { expression { params.action == 'create' } }
            steps {
                sh """
                    cd case-study/k8-eksctl
                    terraform init -reconfigure
                """
            }
        }
        stage('Verify Terraform Files') 
        {
            steps {
                script {
                    sh '''
                    echo "Checking contents of case-study/k8-eksctl directory..."
                    cd case-study/k8-eksctl
                    ls -al
                    '''
                }
            }
        }
        stage('Plan') {
            when { expression { params.action == 'create' } }
            steps {
                sh """
                    cd case-study/k8-eksctl
                    terraform plan
                """
            }
        }
        stage('Apply') {
            when { expression { params.action == 'create' } }
            steps {
                sh """
                    cd case-study/k8-ekscl
                    terraform apply -auto-approve
                """
            }
        }
        stage('Destroy') {
            when { expression { params.action == 'delete' } }
            steps {
                sh """
                    cd case-study/k8-eksctl
                    terraform destroy -auto-approve
                """
            }
        }
        stage('Provision EKS Cluster') {
            when { expression { params.action == 'create' } }
            steps {
                dir('case-study/k8-eksctl') {
                    sh '''
                        # Provision the EKS cluster using eksctl
                        eksctl create cluster -f eks.yaml --region $AWS_REGION
                    '''
                }
            }
        }
        stage('Deploy Application using Helm') {
            when { expression { params.action == 'create' } }
            steps {
                dir('case-study/web') { // Replace with the actual path to your Helm chart folder
                    sh '''
                        helm upgrade --install web -n roboshop --create-namespace .
                    '''
                }
            }
        }
    }
    post {
        always {
            echo 'Pipeline completed.'
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
