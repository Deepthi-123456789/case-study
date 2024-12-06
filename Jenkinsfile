pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1' // Replace with your AWS region
        KUBECONFIG = 'kubeconfig' // Path to kubeconfig (generated dynamically)
    }
     parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create/Destroy')
    }
     stage('Checkout SCM') {
            when { expression { params.action == 'create' } }
            steps {
                sh '''
                    rm -rf case-study1
                    git clone https://github.com/Deepthi-123456789/case-study.git
                '''
            }
        }
        stage('Init')
         {
            when { expression { params.action == 'create' } }
            steps {
                sh """
                    cd k8-eksctl
                    terraform init -reconfigure
                """
            }
        }

        stage('Plan') 
        {
             when { expression { params.action == 'create' } }
            steps {
                sh """
                    cd terraform
                    terraform plan 
                """
            }
        }

        stage('Apply') 
        {
            when { expression { params.action == 'create' } }
            steps {
                sh """
                    cd ekscl
                    terraform apply -auto-approve
                """
            }
        }
        stage('Destroy') 
        {  
            when { expression { params.action == 'destroy' } }
            steps {
                sh """
                    cd k8-eksctl
                    terraform destroy -auto-approve
                """
            }
        }
        
    }
        stage('Provision EKS Cluster') {
            steps {
                dir('terraform-directory') { // Replace with the path to your Terraform files
                    sh '''
                    terraform init
                    terraform apply -auto-approve
                    '''
                }
            }
        }
        stage('Configure Kubectl and Helm') {
            steps {
                sh '''
                # Configure kubectl for EKS
                aws eks update-kubeconfig --region $AWS_REGION --name <eks-cluster-name>

                # Verify kubectl installation
                kubectl version --client

                # Verify Helm installation
                helm version
                '''
            }
        }
        stage('Deploy Application using Helm') {
            steps {
                dir('web') { // Replace with the path to your Helm chart folder
                    sh '''
                    helm upgrade --install my-web-app . \
                    --namespace web-namespace --create-namespace
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
