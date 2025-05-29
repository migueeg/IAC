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
          }
        }
      """.stripIndent())
      sandbox()
    }
  }
}