pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }

    stages {
        stage('Terraform Init & Apply') {
            steps {
                // This 'usernamePassword' method works on ALL Jenkins versions without plugins
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                    sh 'terraform output -raw public_ip > inventory.ini'
                }
            }
        }

        stage('Ansible Configuration') {
            steps {
                script {
                    def instanceIP = readFile('inventory.ini').trim()
                    // Write the inventory file
                    writeFile file: 'hosts', text: "[web_servers]\n${instanceIP} ansible_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/id_rsa_project"
                }
                
                // Run Playbooks
                sh 'ansible-playbook -i hosts playbooks/prometheus.yml'
                sh 'ansible-playbook -i hosts playbooks/grafana.yml'
            }
        }
    }
}