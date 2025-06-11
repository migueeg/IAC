pipelineJob('deploy-iac-govench') {
  definition {
    cps {
      script("""
        pipeline {
          agent any
          environment {
            AWS_ACCESS_KEY_ID = credentials('aws-access-key')
            AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
            AWS_SESSION_TOKEN = credentials('aws-session-token')
          }
          stages {
            stage('Clonar Repositorio') {
              steps {
                git branch: 'develop', url: 'https://github.com/migueeg/IAC.git'
              }
            }
            stage('Terraform Init') {
              steps {
                sh 'cd iac && terraform init'
              }
            }
            stage('Terraform Plan') {
              steps {
                sh 'cd iac && terraform plan'
              }
            }
            stage('Terraform Apply') {
              steps {
                sh 'cd iac && terraform apply -auto-approve'
              }
            }

            stage('Esperar 5 minutos') {
              steps {
                echo 'Esperando 5 minutos antes de destruir los recursos...'
                sleep time: 5, unit: 'MINUTES'
              }
            }
            stage('Terraform Destroy') {
              steps {
                sh 'cd iac && terraform destroy -auto-approve'
              }
            }

          }
        }
      """.stripIndent())
      sandbox()
    }
  }
}
