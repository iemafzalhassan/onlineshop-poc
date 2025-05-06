# Online Shop CI/CD POC 🚀

[![Stars](https://img.shields.io/github/stars/iemafzalhassan/online_shop)](https://github.com/iemafzalhassan/online_shop)
![Forks](https://img.shields.io/github/forks/iemafzalhassan/online_shop)
![GitHub last commit](https://img.shields.io/github/last-commit/iemafzalhassan/online_shop?color=red)
[![GitHub Profile](https://img.shields.io/badge/GitHub-iemafzalhassan-blue?logo=github&style=flat)](https://github.com/iemafzalhassan)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Overview

This repository is a personal proof-of-concept (POC) project demonstrating a complete, industry-standard CI/CD pipeline using Jenkins for automated build, test, security scan, containerization, and deployment of a Dockerized online shop application. The project is fully containerized, leverages AWS EC2 for hosting, and follows DevOps best practices.

---

## Architecture

- **Jenkins Server (EC2):** For CI/CD pipeline orchestration.
- **Docker Host (EC2):** For building, scanning, and running containers.
- **GitHub:** Source code repository and webhook triggers.
- **Docker Hub:** Container image registry.
- **Trivy:** Container image vulnerability scanning.

<!-- Add diagram if available -->

---

## Prerequisites

- AWS account with permissions to launch EC2 instances
- Docker Hub account
- GitHub account
- Basic knowledge of Linux, Docker, and Jenkins

---

## Project Structure

- `Dockerfile.dev` — For development builds with hot reload
- `Dockerfile.prod` — For optimized production builds (Nginx static serving)
- `docker-compose.yml` — For multi-container orchestration (optional)
- `jenkins/` — Jenkins shared library and pipeline scripts
- `nginx.conf` — Custom Nginx configuration for static file serving

---

## Setup Guide

### 1. Launch EC2 Instances

- **Jenkins Server:** Ubuntu 22.04, t2.medium or better, open ports 8080 (Jenkins), 22 (SSH)
- **Docker Host:** Ubuntu 22.04, t2.medium or better, open ports 80/443 (web), 22 (SSH)

### 2. Install Jenkins (on Jenkins EC2)

```sh
sudo apt update
sudo apt install -y openjdk-11-jdk
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
```
- Access Jenkins at `http://<JENKINS_EC2_PUBLIC_IP>:8080`

### 3. Install Docker (on Docker Host EC2)

```sh
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins
newgrp docker
```

### 4. Jenkins Setup

- Install recommended plugins (Git, Docker, Blue Ocean, Pipeline, Credentials Binding, etc.)
- Configure Jenkins global credentials:
  - **GitHub Personal Access Token**
  - **Docker Hub Username/Password**
  - **SSH Key** for connecting to Docker Host (for remote build/deploy)
- Set up Jenkins Shared Library (optional, for reusable pipeline code)

### 5. Project Setup

- Fork/clone this repo
- Update `nginx.conf` as needed for your frontend
- Update `docker-compose.yml` if using multi-container setup

---

## Build & Run Commands

### Development (Dockerfile.dev)
```sh
docker build -f Dockerfile.dev -t online_shop:dev .
docker run -d -p 3000:3000 --name online_shop_dev online_shop:dev
```

### Production (Dockerfile.prod)
```sh
docker build -f Dockerfile.prod -t online_shop:prod .
docker run -d -p 8080:80 --name online_shop_prod online_shop:prod
```

---

## Jenkins CI/CD Pipeline

### Pipeline Stages

1. **Clone Repository:** Pull code from GitHub.
2. **Build Docker Image:** Build image using `Dockerfile.prod`.
3. **Scan Image:** Use Trivy to scan for vulnerabilities.
   ```sh
   trivy image online_shop:prod
   ```
4. **Push Image:** Push to Docker Hub with a versioned tag.
   ```sh
   docker tag online_shop:prod <dockerhub-username>/online_shop:prod
   docker push <dockerhub-username>/online_shop:prod
   ```
5. **Update Docker Compose:** Update `docker-compose.yml` with the new image tag (can be done via script).
6. **Deploy with Docker Compose:** Remotely SSH into Docker Host and run:
   ```sh
   docker compose pull
   docker compose up -d
   ```

### Example Jenkinsfile (Declarative)

```groovy
pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        GITHUB_TOKEN = credentials('github-token')
    }
    stages {
        stage('Clone') {
            steps { git 'https://github.com/iemafzalhassan/online_shop.git' }
        }
        stage('Build') {
            steps { sh 'docker build -f Dockerfile.prod -t online_shop:prod .' }
        }
        stage('Scan') {
            steps { sh 'trivy image online_shop:prod' }
        }
        stage('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker tag online_shop:prod $DOCKER_USER/online_shop:prod'
                    sh 'docker push $DOCKER_USER/online_shop:prod'
                }
            }
        }
        stage('Deploy') {
            steps {
                // SSH steps to update and restart Docker Compose on the remote host
                sh 'ssh -o StrictHostKeyChecking=no ubuntu@<DOCKER_HOST_IP> "cd /path/to/project && docker compose pull && docker compose up -d"'
            }
        }
    }
}
```

---

## Best Practices

- Use Jenkins credentials for all secrets (never hardcode passwords or tokens).
- Use multi-stage Docker builds for minimal images.
- Scan all images before pushing to production.
- Use a Jenkins shared library for reusable pipeline logic.
- Keep infrastructure as code (e.g., scripts for EC2 provisioning, Docker install).

---

## Troubleshooting

- Ensure security groups allow required ports (Jenkins: 8080, App: 80/8080, SSH: 22).
- If Jenkins cannot SSH to Docker Host, check key permissions and user setup.
- If builds fail, check Docker daemon status and Jenkins logs.

---

## Author

[iemafzalhassan](https://github.com/iemafzalhassan)

---

**This project is for personal learning and demonstration purposes. Feel free to fork and adapt for your own CI/CD experiments!**
