pipeline {
  agent any

  environment {
    ECR_REPO = 'your-account-id.dkr.ecr.us-west-1.amazonaws.com/java-app'
    IMAGE_TAG = "v${BUILD_NUMBER}"
  }

  stages {
    stage('Clone') {
      steps {
        git 'https://github.com/your-org/java-app.git'
      }
    }

    stage('Build with Maven') {
      steps {
        sh 'mvn clean package'
      }
    }

    stage('Run Tests') {
      steps {
        sh 'mvn test'
      }
    }

    stage('Code Coverage (Jacoco)') {
      steps {
        sh 'mvn jacoco:report'
      }
    }

    stage('SonarQube Scan') {
      steps {
        withSonarQubeEnv('SonarQube') {
          sh 'mvn sonar:sonar'
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t $ECR_REPO:$IMAGE_TAG ."
      }
    }

    stage('Push Image to ECR') {
      steps {
        sh """
        aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin $ECR_REPO
        docker push $ECR_REPO:$IMAGE_TAG
        """
      }
    }

    stage('Deploy to EKS') {
      steps {
        sh """
        sed 's|REPLACE_IMAGE|$ECR_REPO:$IMAGE_TAG|' k8s/deployment.yaml | kubectl apply -f -
        """
      }
    }
  }

  post {
    always {
      junit '**/target/surefire-reports/*.xml'
    }
  }
}
