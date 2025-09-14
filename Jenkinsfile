pipeline {
  agent any
  environment {
    REPO = 'https://github.com/phovv/jenkins-workshop2.git'
    PROJECT_NAME = 'phovv-workshop2'
    FIREBASE_TOKEN_CRED = 'firebase-token' // id credential in Jenkins
    FIREBASE_ADC_CRED = 'firebase-adc' // secret file id if used
    SSH_DEPLOY_KEY = 'ssh-deploy-key'
    SLACK_TOKEN = 'slack-token-ventura'
    REMOTE_HOST_PUBLIC = '10.1.1.195'
    REMOTE_HOST_SSH = '118.69.34.46'
    REMOTE_PORT = '3334'
    REMOTE_USER = 'newbie'
    REMOTE_BASE = '/usr/share/nginx/html/jenkins/phovv/template2'
  }

  options {
    // Dùng checkout scm trong stage thay vì auto checkout đầu pipeline
    skipDefaultCheckout(true)
  }

  triggers {
    // Webhook từ GitHub
    githubPush()
    // Dự phòng: quét mỗi phút nếu webhook chưa hoạt động
    pollSCM('H/1 * * * *')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Collect metadata') {
      steps {
        script {
          env.GIT_AUTHOR = sh(script: "git log -1 --pretty=format:%an", returnStdout: true).trim()
          env.GIT_COMMIT_MSG = sh(script: "git log -1 --pretty=format:%s", returnStdout: true).trim()
          env.DEPLOY_TIME = sh(script: 'date "+%Y-%m-%d %H:%M:%S %Z"', returnStdout: true).trim()
          env.FIREBASE_URL = "https://${env.PROJECT_NAME}.web.app"
        }
      }
    }

    stage('Build') {
      steps {
        dir('web-performance-project1-initial') {
          sh 'npm ci || npm install'
        }
      }
    }

    stage('Lint & Test') {
      steps {
        // Nếu muốn bypass lint để test deploy, có thể comment code trong source như đề
        dir('web-performance-project1-initial') {
          sh 'npm run test:ci'
        }
      }
    }

    stage('Prepare artifacts') {
      steps {
        // Nếu project build step (ví dụ npm run build)
        // sh 'npm run build'
        // Giả sử build ra thư mục ./dist hoặc root project
        sh 'mkdir -p build_for_deploy'
        sh "cp web-performance-project1-initial/index.html web-performance-project1-initial/404.html -t build_for_deploy || true"
        sh "cp -r web-performance-project1-initial/css web-performance-project1-initial/js web-performance-project1-initial/images build_for_deploy || true"
      }
    }

    stage('Deploy - Firebase (token)') {
      steps {
        withCredentials([string(credentialsId: env.FIREBASE_TOKEN_CRED, variable: 'FIREBASE_TOKEN')]) {
          // Debug Firebase setup
          sh 'echo "Firebase CLI version:" && firebase --version'
          sh 'echo "Project name: ${PROJECT_NAME}"'
          sh 'echo "Token length: ${#FIREBASE_TOKEN}"'
          
          // Initialize Firebase project if needed
          sh 'firebase use ${PROJECT_NAME} --token "${FIREBASE_TOKEN}" || echo "Project not found, will create during deploy"'
          
          dir('build_for_deploy') {
            // Create firebase.json if not exists
            sh 'echo "{\\"hosting\\": {\\"public\\": \\".\\", \\"ignore\\": [\\"firebase.json\\", \\"**/.*\\", \\"**/node_modules/**\\"]}}" > firebase.json'
            
            // Deploy with verbose output
            sh "timeout 300 firebase deploy --token \"${FIREBASE_TOKEN}\" --only hosting --project=${PROJECT_NAME} --force --debug"
          }
        }
      }
    }

    // stage('Deploy - Firebase (ADC alternative)') {
    //   // when {
    //   //   branch 'main'
    //   // }
    //   steps {
    //     // Nếu muốn deploy bằng ADC: inject secret file và set GOOGLE_APPLICATION_CREDENTIALS
    //     withCredentials([file(credentialsId: env.FIREBASE_ADC_CRED, variable: 'ADC_FILE')]) {
    //       sh 'npm install -g firebase-tools || true'
    //       sh 'export GOOGLE_APPLICATION_CREDENTIALS=$ADC_FILE'
    //       dir('build_for_deploy') {
    //         sh "firebase deploy --only hosting --project=${PROJECT_NAME}"
    //       }
    //     }
    //   }
    // }


    stage('Deploy - Remote Server (rsync/ssh)') {
      // when { branch 'main' }
      steps {
        // Sử dụng biến Jenkins credentials
        withCredentials([sshUserPrivateKey(credentialsId: env.SSH_DEPLOY_KEY, keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
          sh 'mkdir -p ~/.ssh'
          sh 'chmod 700 ~/.ssh'
          
          // Copy key từ biến Jenkins
          sh 'cp ${SSH_KEY} ~/.ssh/id_rsa'
          sh 'chmod 600 ~/.ssh/id_rsa'
          
          // Debug info
          sh 'echo "SSH User: ${SSH_USER}"'
          sh 'echo "Remote Host: 118.69.34.46"'
          sh 'echo "Remote Port: 3334"'
          sh 'echo "Remote Base: /usr/share/nginx/html/jenkins/phovv/template2"'
          sh 'ls -la ~/.ssh/id_rsa'
          sh 'head -1 ~/.ssh/id_rsa'
          sh 'tail -1 ~/.ssh/id_rsa'

          // Test SSH connection
          sh 'ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p 3334 -i ~/.ssh/id_rsa ${SSH_USER}@118.69.34.46 "echo SSH connection successful"'

          sh "chmod +x deploy/deploy_remote.sh || true"
          sh "deploy/deploy_remote.sh ${SSH_USER} 118.69.34.46 3334 /usr/share/nginx/html/jenkins/phovv/template2 ${pwd()}/build_for_deploy"
        }
      }
    }
  }

  post {
    success {
      echo 'Pipeline succeeded!'
      echo "✅ Deployment Successful!"
      echo "Author: ${GIT_AUTHOR}"
      echo "Commit: ${GIT_COMMIT_MSG}"
      echo "Job: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
      echo "Time: ${DEPLOY_TIME}"
      echo "Firebase: ${FIREBASE_URL}"
      echo "Build Logs: ${env.BUILD_URL}"

      slackSend(
        channel: '#lnd-2025-workshop',
        color: 'good',
        tokenCredentialId: 'SLACK_TOKEN',
        iconEmoji: ':rocket:',
        message: """*✅ Deployment Successful!*
*Author:* ${GIT_AUTHOR}
*Commit:* ${GIT_COMMIT_MSG}
*Time:* ${DEPLOY_TIME}

*Links:*
• Firebase: ${FIREBASE_URL}
• Remote: http://${REMOTE_HOST_PUBLIC}/jenkins/phovv/template2/deploy/current/"""
      )
    }
    failure {
      echo 'Pipeline failed!'
      echo "❌ Deployment Failed!"
      echo "Author: ${GIT_AUTHOR}"
      echo "Commit: ${GIT_COMMIT_MSG}"
      echo "Job: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
      echo "Time: ${DEPLOY_TIME}"
      echo "Check Logs: ${env.BUILD_URL}"

      slackSend(
        channel: '#lnd-2025-workshop',
        color: 'danger',
        tokenCredentialId: 'SLACK_TOKEN',
        iconEmoji: ':x:',
        message: """*❌ Deployment Failed!*
*Author:* ${GIT_AUTHOR}
*Commit:* ${GIT_COMMIT_MSG}
*Time:* ${DEPLOY_TIME}
*Check Logs:* ${env.BUILD_URL}

• Remote: http://${REMOTE_HOST_PUBLIC}/jenkins/phovv/template2/deploy/current/"""
      )
    }
    always {
      echo 'Pipeline completed!'
    }
  }
}
