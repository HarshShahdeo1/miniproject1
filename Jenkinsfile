pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {
        stage('Terraform Destroy') {
            steps {
                // Use the generic usernamePassword method we fixed earlier
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    // Initialize Terraform so it finds the local state file
                    sh 'terraform init'
                    
                    // DESTROY the infrastructure
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }
}