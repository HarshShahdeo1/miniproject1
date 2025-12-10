pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {
        stage('Terraform Destroy') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    // Initialize Terraform
                    sh 'terraform init'
                    
                    // DESTROY the infrastructure
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }
}