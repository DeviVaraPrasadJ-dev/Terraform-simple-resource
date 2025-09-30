pipeline {
        agent {
        docker {
            image 'hashicorp/terraform:1.9.5'
            args '-u root:root' // optional, ensures workspace is writable
        }
    }

    environment {
        // Jenkins credentials: create an entry called "aws-creds"
        SLACK_CHANNEL = '#all-na' 
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'ap-southeast-1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Approve to create EC2 instance?'
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

  //post-build actions
        post {
        success {
       slackSend(
                channel: "${SLACK_CHANNEL}",
                message: "*SUCCESS:* Job `${env.JOB_NAME}` Build #${env.BUILD_NUMBER} passed ",
                tokenCredentialId: 'slack-token'
                )
        }

        failure {
            slackSend (
                channel: "${SLACK_CHANNEL}",
                message: "*FAILURE:* Job `${env.JOB_NAME}` Build #${env.BUILD_NUMBER} passed ",
                tokenCredentialId: 'slack-token'
                )
        }

        always {
            echo " Notified on Slack"
        }
    }
}
