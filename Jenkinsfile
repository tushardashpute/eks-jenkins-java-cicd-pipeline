pipeline {
  agent {
    kubernetes {
      label 'kaniko-agent'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9.6-eclipse-temurin-17
    command: ['cat']
    tty: true

  - name: kubectl
    image: bitnami/kubectl:latest
    command: ['cat']
    tty: true

  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ["/busybox/cat"]
    tty: true
    env:
      - name: AWS_REGION
        value: "us-east-1"
    volumeMounts:
      - name: workspace-volume
        mountPath: /workspace
    workingDir: /workspace
    tty: true

  volumes:
  - name: workspace-volume
    emptyDir: {}
  serviceAccountName: jenkins
  restartPolicy: Never
"""
    }
  }

  environment {
    ECR_REPO = '980889732995.dkr.ecr.us-east-1.amazonaws.com/springboot-app'
    IMAGE_TAG = "v${BUILD_NUMBER}"
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
      sh '''
        mvn clean package -DskipTests
        echo "Sleeping for 5 minutes for debugging or inspection..."
        ## sleep 3
      '''
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

    stage('Deploy to EKS') {
      steps {
        container('kubectl') {
          dir("${env.WORKSPACE}") {
            sh '''
            sed "s|REPLACE_IMAGE|$ECR_REPO:$IMAGE_TAG|" springboot-deployment.yaml | kubectl apply -f -
            '''
          }
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
