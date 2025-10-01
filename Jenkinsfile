pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['create', 'destroy'],
            description: 'Select Terraform action to perform'
        )
    }

    environment {
        SLACK_CHANNEL = '#all-na' 
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'ap-southeast-1'
        TERRAFORM_VERSION     = '1.9.5'
    }

    stages {
        stage('Install Terraform') {
            steps {
                sh '''
                    curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip
                    unzip -o terraform.zip
                    chmod +x terraform
                    ./terraform version
                '''
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh './terraform init'
            }
        }

        stage('Terraform Plan') {
            when {
                expression { params.ACTION == 'create' }
            }
            steps {
                sh './terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'create' }
            }
            steps {
                input message: 'Approve to create EC2 instance?'
                sh './terraform apply -auto-approve tfplan'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                input message: 'Approve to destroy EC2 instance?'
                sh './terraform destroy -auto-approve'
            }
        }
    }

    post {
        success {
            slackSend(
                channel: "${SLACK_CHANNEL}",
                message: "*SUCCESS:* Job `${env.JOB_NAME}` Build #${env.BUILD_NUMBER} completed with action `${params.ACTION}`",
                tokenCredentialId: 'slack-token'
            )
        }

        failure {
            slackSend (
                channel: "${SLACK_CHANNEL}",
                message: "*FAILURE:* Job `${env.JOB_NAME}` Build #${env.BUILD_NUMBER} failed with action `${params.ACTION}`",
                tokenCredentialId: 'slack-token'
            )
        }

        always {
            echo "Notified on Slack"
        }
    }
}
