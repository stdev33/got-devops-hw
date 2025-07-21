pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins/label: jenkins-kaniko
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      imagePullPolicy: Always
      command:
        - sleep
      args:
        - 99d
      env:
        - name: GITHUB_PAT
          valueFrom:
            secretKeyRef:
              name: github-pat-secret
              key: GITHUB_PAT
    - name: jnlp
      image: jenkins/inbound-agent:latest
      env:
        - name: GITHUB_PAT
          valueFrom:
            secretKeyRef:
              name: github-pat-secret
              key: GITHUB_PAT
"""
    }
  }
  environment {
    ECR_REGISTRY = "121905340549.dkr.ecr.us-west-2.amazonaws.com/final-project-ecr"
    IMAGE_NAME   = "app"
  }
  stages {
    stage('Compute IMAGE_TAG') {
      steps {
        script {
          def gitHash = sh(
            script: 'git rev-parse --short HEAD',
            returnStdout: true
          ).trim()
          env.IMAGE_TAG="${env.BUILD_NUMBER}-${gitHash}"
        }
      }
    }
    stage('Build & Push Docker Image') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --context `pwd` \
              --dockerfile `pwd`/Dockerfile \
              --destination=$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG \
              --cache=true \
              --insecure \
              --skip-tls-verify
          '''
        }
      }
    }
    stage('Update Helm Chart and Push') {
      steps {
        container('jnlp') {
          sh '''
            git config user.name "Jenkins CI"
            git config user.email "ci@example.com"
            WORKING_BRANCH="main"
            # Ensure we are on ${WORKING_BRANCH} branch
            git checkout ${WORKING_BRANCH}
            # Pull latest changes
            git pull origin ${WORKING_BRANCH}
            # Update the image tag in values.yaml
            sed -i "s/^ *tag:.*$/  tag: \\\"${IMAGE_TAG}\\\"/" lesson-5/charts/django-app/values.yaml
            # Commit and push
            git add lesson-5/charts/django-app/values.yaml
            git commit -m "ci: bump image tag to ${IMAGE_TAG}"
            # Use stored credentials to push
            git push https://${GITHUB_PAT}@github.com/stdev33/got-devops-hw.git ${WORKING_BRANCH}
          '''
        }
      }
    }
  }
}