pipeline {
    agent {
        label 'ubuntu'
    }

    stages {
        stage('Terraform Build') {
            steps {
                sh 'terraform init'
                sh 'terraform apply -auto-approve'
                sleep 30
            }
        }

        stage('Ansible Build') {
            steps {
                sh 'echo "[ec2]" > inventory.ini'
                sh 'echo "$(terraform output -raw instance_ip) ansible_user=ec2-user ansible_ssh_private_key_file=vockey.pem" >> inventory.ini'
                sh 'ansible-playbook -i inventory.ini setup.yml'
            }
        }
    }
}
