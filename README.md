---```md
# 🚀 EKS Jenkins Java CI/CD Pipeline

This project provisions an Amazon EKS cluster using Terraform, installs Jenkins and SonarQube via Helm, and automates CI/CD for a Java (Spring Boot) application using Jenkins, Docker (via Kaniko), ECR, and Helm.

---

## 🔧 Tools Used

- **Terraform** – Infrastructure as Code
- **AWS EKS** – Kubernetes cluster
- **Helm** – Deploying Jenkins, SonarQube, and application charts
- **Jenkins** – CI/CD automation
- **Kaniko** – Docker builds in Kubernetes without Docker daemon
- **AWS ECR** – Image repository
- **SonarQube** – Static code analysis
- **Maven** – Java project build tool

---

## 🏗️ Project Structure

```

.
├── helm/                          # Helm charts for app and Jenkins
│   ├── jenkins-values.yaml
│   └── templates/
├── jenkins/Jenkinsfile           # CI/CD pipeline
├── terraform/                    # Terraform modules for EKS, ECR, IAM
├── variables.tf                  # Input variables
├── terraform.tfvars              # Values for input variables
└── README.md

````

---

## 📦 Components

### 1. 🔨 Infrastructure Provisioning (Terraform)

- VPC with public & private subnets
- EKS Cluster (with OIDC enabled)
- Node group (EC2 workers)
- IRSA role for Jenkins
- ECR repo with lifecycle policy

### 2. ☸️ Jenkins Deployment

- Installed via Helm in `jenkins` namespace
- IRSA-enabled Jenkins service account
- RBAC configured for multi-namespace deployment

### 3. 🚢 CI/CD Pipeline

- **Maven Build** of Java Spring Boot project
- **Docker Build + Push** via Kaniko to ECR
- **Deploy** using Helm into the EKS cluster
- **SonarQube Scan** included in pipeline

---

## 📁 Java App Location

[Spring Boot App GitHub Repository](https://github.com/tushardashpute/springboot.git)  
(Uses `main` branch)

---

## 🚀 Getting Started

### ✅ Prerequisites

- AWS CLI
- Terraform ≥ 1.3
- kubectl
- Helm ≥ 3.x
- Git
- Java + Maven

---

### 🧪 Provision Infrastructure

```bash
# Optional: Create s3 bucket for state locking if not having existing
## 🌐 Terraform Setup with Native S3 Locking (No DynamoDB Required)

resource "aws_s3_bucket" "backend" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Enabled"
  }
}
# 1. Initialize Terraform
terraform -chdir=terraform init

# 2. View plan
terraform -chdir=terraform plan

# 3. Apply infrastructure
terraform -chdir=terraform apply -auto-approve

# 4. Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name toolchain-eks-cluster
````

---

### ☸️ Install Jenkins with Helm

```bash
helm repo add jenkins https://charts.jenkins.io
helm repo update

helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --create-namespace \
  --values helm/jenkins-values.yaml

# Apply RBAC for Jenkins to deploy across namespaces
kubectl apply -f helm/jenkins-deploy-role.yaml
```

---

### 🧠 Install SonarQube on EKS

```bash
helm repo add oteemocharts https://oteemo.github.io/charts
helm repo update

helm install sonarqube oteemocharts/sonarqube \
  --namespace sonarqube \
  --create-namespace \
  --set postgresql.enabled=true \
  --set ingress.enabled=false \
  --set service.type=LoadBalancer

# Wait for external IP
kubectl get svc -n sonarqube
```

> Access SonarQube at: `http://<sonarqube-LB-URL>:9000`
> Default creds: `admin / admin`

---

### 🔐 Configure SonarQube in Jenkins

* Go to **Jenkins > Manage Jenkins > Configure System**
* Under **SonarQube Servers**, add:

  * **Name**: `SonarQube`
  * **Server URL**: `http://<sonarqube-LB-URL>:9000`
  * **Token**: Generate from SonarQube → Your Account → Security

---

## 🧪 Jenkinsfile Overview

```groovy
pipeline {
  agent {
    kubernetes {
      label 'kaniko-agent'
      yaml """<Pod spec YAML with maven, helm, kubectl, kaniko>"""
    }
  }

  environment {
    ECR_REPO = '980889732995.dkr.ecr.us-east-1.amazonaws.com/springboot-app'
    IMAGE_TAG = "v${BUILD_NUMBER}"
    RELEASE_NAME = "springboot"
    NAMESPACE = "springboot"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/tushardashpute/springboot.git'
      }
    }

    stage('Build with Maven') {
      steps {
        container('maven') {
          sh 'mvn clean package -DskipTests'
        }
      }
    }

    stage('SonarQube Analysis') {
      steps {
        container('maven') {
          withSonarQubeEnv('SonarQube') {
            sh 'mvn sonar:sonar -Dsonar.projectKey=springboot-app -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_AUTH_TOKEN'
          }
        }
      }
    }

    stage('Build & Push Docker Image (Kaniko)') {
      steps {
        container('kaniko') {
          sh '''
          /kaniko/executor \
            --context `pwd` \
            --dockerfile `pwd`/Dockerfile \
            --destination=$ECR_REPO:$IMAGE_TAG \
            --verbosity=info
          '''
        }
      }
    }

    stage('Helm Deploy to EKS') {
      steps {
        container('helm') {
          sh '''
          helm upgrade --install $RELEASE_NAME helm/ \
            --namespace $NAMESPACE --create-namespace \
            --set image.repository=$ECR_REPO \
            --set image.tag=$IMAGE_TAG
          '''
        }
      }
    }
  }

  post {
    always {
      junit '**/target/surefire-reports/*.xml'
    }
  }
}
```

---

## 🛡️ RBAC: `jenkins-deploy-role.yaml`

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins-deploy-role
rules:
- apiGroups: ["", "apps", "batch", "extensions", "networking.k8s.io", "rbac.authorization.k8s.io", "autoscaling", "policy", "apiextensions.k8s.io"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins-deploy-binding
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: jenkins
roleRef:
  kind: ClusterRole
  name: jenkins-deploy-role
  apiGroup: rbac.authorization.k8s.io
```

---

## 🗂️ Terraform Outputs

* EKS Cluster Endpoint
* OIDC Provider URL
* IRSA role ARN
* ECR Repo Name
* VPC/Subnet IDs

---

## 📄 Terraform Outputs

* EKS Cluster Endpoint
* IAM OIDC Provider URL
* IRSA role ARN for Jenkins
* ECR repository for Docker images
