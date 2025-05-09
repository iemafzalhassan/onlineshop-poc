pipeline {
    agent any
    stages {
        stage('Cleanup workspace') {
            steps {
                echo 'Cleaning up workspace...'
                cleanWs()
            }
        }
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }
        stage('Build') {
            steps {
                echo 'Building image...'
                sh 'docker build -f Dockerfile.prod -t online_shop:latest .'
            }
        }
    }
        stage('Docker push') {
            steps {
                echo 'Pushing Docker image...'
                sh 'docker push online_shop:latest'
            }
        }
        stage('trivy scan') {
            steps {
                echo 'Running Trivy scan...'
                sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --exit-code 1 --severity HIGH,CRITICAL online_shop:latest --format table --output trivy-report.txt  || true'
            }
        }
        stage('Deployment') {
            steps {
                echo 'Deploying application...'
                sh 'docker run -d -p 8080:8080 online_shop:latest'
            }
        }
    }