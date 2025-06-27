## EKS Jenkins Java CI/CD Pipeline

This project provisions an Amazon EKS cluster using Terraform, deploys Jenkins via Helm, and runs a sample Java application through a complete CI/CD pipeline using Jenkinsfile.

### 🔧 Tools Used
- Terraform
- AWS EKS
- Helm
- Jenkins (via Helm chart)
- Docker
- Java (Maven-based app)

### 🏗️ Project Components

#### 1. Infrastructure Provisioning
- **EKS Cluster**: Created using Terraform `terraform-aws-eks` module.
- **VPC**: Built using `terraform-aws-vpc` module.
- **Security Groups**: Custom rules for EKS worker nodes.

#### 2. Jenkins Deployment
- Uses Helm to install Jenkins in the EKS cluster.
- Configured via `jenkins-values.yaml`.

#### 3. CI/CD Pipeline
- Pipeline defined in `jenkins/Jenkinsfile`:
  - Pulls Java code
  - Builds using Maven
  - Builds Docker image
  - Pushes to ECR
  - Deploys to EKS

### 🚀 Getting Started

#### Prerequisites
- AWS CLI
- kubectl
- Terraform >= 1.3
- Helm >= 3.x

#### Steps
```bash
# Step 1: Initialize Terraform
terraform init

# Step 2: Review plan
terraform plan

# Step 3: Apply infrastructure
terraform apply -auto-approve

# Step 4: Update kubeconfig
aws eks update-kubeconfig --name <cluster_name> --region <region>

# Step 5: Install Jenkins using Helm
helm repo add jenkins https://charts.jenkins.io
helm install jenkins jenkins/jenkins --namespace jenkins  --values helm/jenkins-values.yaml --create-namespace
```

### 📂 Java App Path
`jenkins/java-app/` contains a sample Maven-based Java app. Customize it as needed.

### 🧪 Sample Jenkinsfile Stages
```groovy
pipeline {
  agent any
  stages {
    stage('Build') {
      steps { sh 'mvn clean package' }
    }
    stage('Docker Build') {
      steps { sh 'docker build -t <ECR_URI>:latest .' }
    }
    stage('Push to ECR') {
      steps { sh 'docker push <ECR_URI>:latest' }
    }
    stage('Deploy to EKS') {
      steps { sh 'kubectl apply -f k8s/deployment.yaml' }
    }
  }
}
```

### 📄 Outputs
- EKS Cluster ID
- Cluster Endpoint
- OIDC Provider ARN

### 📬 Author
Tushar Dashpute  
Feel free to fork or contribute.
