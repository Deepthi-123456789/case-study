pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1' // Replace with your AWS region
        KUBECONFIG = 'kubeconfig' // Path to kubeconfig (generated dynamically)
    }
    parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create/destroy')
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
        stage('Init') {
            when { expression { params.action == 'create' } }
            steps {
                sh """
                    cd case-study/k8-eksctl
                    terraform init -reconfigure
                """
            }
        }
        stage('Plan') {
            when { expression { params.action == 'create' } }
            steps {
                sh """
                    cd case-study/terraform
                    terraform plan
                """
            }
        }
        stage('Apply') {
            when { expression { params.action == 'create' } }
            steps {
                sh """
                    cd case-study/ekscl
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
                dir('case-study/terraform-directory') { // Replace with the path to your Terraform files
                    sh '''
                        terraform init
                        terraform apply -auto-approve
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
