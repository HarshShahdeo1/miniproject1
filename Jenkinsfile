pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }

    stages {
        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    // Initialize and Apply Terraform
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                    
                    // Save the Server IP to a file
                    sh 'terraform output -raw public_ip > inventory.ini'
                }
            }
        }

        stage('Ansible Configuration') {
            steps {
                script {
                    // Read the IP address we just got from Terraform
                    def instanceIP = readFile('inventory.ini').trim()
                    
                    // Create the Ansible Inventory file
                    // This tells Ansible: "Connect to this IP, use user 'ubuntu', and use this key"
                    writeFile file: 'hosts', text: "[web_servers]\n${instanceIP} ansible_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/id_rsa_project"
                }
                
                // Run the Playbooks
                sh 'ansible-playbook -i hosts playbooks/prometheus.yml'
                sh 'ansible-playbook -i hosts playbooks/grafana.yml'
            }
        }
    }
}