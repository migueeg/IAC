FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y curl unzip openssh-client && \
    curl -fsSL https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip && \
    terraform -version

USER jenkins