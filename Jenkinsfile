pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDS = credentials('dockerhub-creds')
        DOCKER_USER = "${env.DOCKER_HUB_CREDS_USR}"
        DOCKER_PASSWORD = "${env.DOCKER_HUB_CREDS_PSW}"
    }

    stages {
        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Git Clone') {
            steps {
                checkout scm
            }
        }
        stage('Build Image') {
            steps {
                sh 'docker build -t onelineshop:latest .'
            }
        }
        stage('Push Image') {
            steps {
                sh 'docker tag onelineshop:latest iemafzal/onelineshop:latest'
                sh 'echo ${dockerpassword} | docker login -u ${dockerUser} --password-stdin'
                sh 'docker push iemafzal/onelineshop:latest'
            }
        }
        stage('Trivy') {
            steps {
                sh """
                docker run --rm \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    aquasec/trivy:latest image --exit-code 1 --severity HIGH, CRITICAL --format table --output trivy-report.txt
                """
            }
            
        }
        stage('Deploy') {
            steps {
                sh 'docker run -d -p 3000:80 iemafzal/onelineshop:latest'
            }
        }
    }
}