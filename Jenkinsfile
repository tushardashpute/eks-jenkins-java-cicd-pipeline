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

  - name: helm
    image: alpine/helm:3.14.3
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

  - name: trivy
    image: aquasec/trivy:latest
    command: ['cat']
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
          sh '''
            mvn clean package -DskipTests
          '''
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

    stage('Scan Docker Image with Trivy') {
      steps {
        container('trivy') {
          sh '''
            trivy image --exit-code 1 --severity CRITICAL $ECR_REPO:$IMAGE_TAG || echo "⚠️ Vulnerabilities found. Review required."
          '''
        }
      }
    }

    stage('Helm Deploy to EKS') {
      steps {
        container('helm') {
          dir("${env.WORKSPACE}") {
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
  }
}
