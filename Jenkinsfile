pipeline {
    agent any
    environment {
        DOCKER_PWD = credentials('dockerhub-pass')
    }
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
                sh 'docker tag online_shop:latest iemafzal/online_shop:latest'
                sh 'echo $DOCKER_PWD | docker login -u iemafzal --password-stdin'
                sh 'docker push iemafzal/online_shop:latest'
            }
        }
        stage('trivy scan') {
            steps {
                echo 'Running Trivy scan...'
                sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --exit-code 1 --severity HIGH,CRITICAL iemafzal/online_shop:latest --format table --output trivy-report.txt  || true'
            }
        }
        stage('Deployment') {
            steps {
                echo 'Deploying application...'
                sh 'docker run -d -p 8080:8080 iemafzal/online_shop:latest'
            }
        }
    }