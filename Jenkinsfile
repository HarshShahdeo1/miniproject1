pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        TF_IN_AUTOMATION = 'true'
    }

    stages {
        stage('Terraform Init & Apply') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                    sh 'terraform output -raw public_ip > inventory.ini'
                }
            }
        }

        stage('Ansible Deployment') {
            steps {
                script {
                    def instanceIP = readFile('inventory.ini').trim()
                    
                    // 1. Create the Inventory File
                    writeFile file: 'hosts', text: "[web_servers]\n${instanceIP} ansible_user=ubuntu ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/id_rsa_project"
                    
                    // 2. THE TEACHER'S SMART CHECK: Wait for SSH to be ready
                    echo "Waiting for Server (${instanceIP}) to be ready..."
                    sh """
                        count=0
                        while ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i /var/lib/jenkins/.ssh/id_rsa_project ubuntu@${instanceIP} exit 2>/dev/null; do
                            echo "Server not ready yet... waiting 5s"
                            sleep 5
                            count=\$((count+1))
                            if [ \$count -ge 24 ]; then echo "Timeout waiting for SSH"; exit 1; fi
                        done
                        echo "Server is Ready!"
                    """
                }
                
                // 3. Run Ansible Playbooks
                sh 'ansible-playbook -i hosts playbooks/prometheus.yml'
                sh 'ansible-playbook -i hosts playbooks/grafana.yml'
            }
        }
    }
}