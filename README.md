# Infraestructura para Aplicación Web con Terraform

Este proyecto define y despliega la infraestructura de una aplicación web moderna usando AWS y Terraform. Incluye servicios como S3, CloudFront y la preparación para integrar funciones Lambda, todo automatizado con código.

---

## Autores

- *Aroni Muñoz, Francisco*
- *Cruz Leon, Gustavo*
- *Escobar Gómez, Miguel Ángel*
- *Grados Araujo,Samil*
- *Limay Capristan, Jesus*

---

## Tabla de Contenido

- [Arquitectura General](#arquitectura-general)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Servicios Usados](#servicios-usados)
- [Requisitos Previos](#requisitos-previos)
- [Despliegue y Comandos Útiles](#despliegueycomandos-útiles)

---

## Arquitectura General

- *Frontend Angular* desplegado en *S3 como sitio web estático*
- *CloudFront* como CDN para mejorar la distribución global
- Configuración separada en archivos .tf (seguimiento de buenas prácticas)
- Modularización para facilitar futuras integraciones (como funciones Lambda)

---

## Estructura del Proyecto


---

📁 raíz del proyecto  
├── 📁 createEvent              
│   └── 📄 index.js              
├── 📁 frontend                  
│
├── 📁 loginUser               
│   └── 📄 index.js             
├── 📁 iac                      
│   ├── 📁 .terraform         
│   ├── 📁 bin            
│   ├── 📄 alb.tf               
│   ├── 📄 apigateway.tf        
│   ├── 📄 cloudfront.tf       
│   ├── 📄 frontend.tf          
│   ├── 📄 iam-lambda.tf         
│   ├── 📄 lambda-createEvent.tf  
│   ├── 📄 lambda-loginUser.tf  
│   ├── 📄 main.tf              
│   ├── 📄 outputs.tf          
│   ├── 📄 s3.tf                 
│   ├── 📄 vpc.tf              
│   └── 📄 terraform.tfstate   
│   └── 📄 terraform.tfstate.backup  
├── 📄 .gitignore       
├── 📄 README.md           

---

## Servicios Usados

- *Amazon S3*: Almacenamiento de archivos estáticos del frontend
- *Amazon CloudFront*: Distribución de contenido vía CDN
- *AWS IAM*: Políticas para acceso público al bucket
- *Terraform*: Infraestructura como código

---

## Requisitos Previos

- Terraform instalado (>= 1.5)
- Cuenta de AWS con credenciales configuradas
- Node.js y Angular CLI si deseas compilar el frontend localmente

---

## Despliegue y Comandos Útiles

```bash
# Inicializar Terraform
terraform init

# Verificar plan de ejecución
terraform plan

# Aplicar cambios
terraform apply
