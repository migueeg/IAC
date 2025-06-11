FROM jenkins/jenkins:lts

USER root

# Instalar herramientas y Terraform
RUN apt-get update && \
    apt-get install -y curl unzip openssh-client && \
    curl -fsSL https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip && \
    terraform -version

# Instalar plugins necesarios para pipelines y JCasC
RUN jenkins-plugin-cli --plugins \
    configuration-as-code \
    workflow-aggregator \
    git \
    job-dsl \
    credentials \
    ssh-slaves

# Copiar configuración JCasC (si usas)
COPY casc_configs /var/jenkins_home/casc_configs
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc_configs/jenkins.yaml

USER jenkins