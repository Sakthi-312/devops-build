DevOps CI/CD Pipeline — React App Deployment on AWS

📘 Project Overview:

This project demonstrates a complete CI/CD pipeline for deploying a React application on AWS using modern DevOps tools such as Docker, Jenkins, GitHub, DockerHub, and Uptime Kuma for monitoring.

🏗️ Tech Stack

-> AWS EC2 — Infrastructure host

-> Docker & Docker Compose — Containerization

-> Jenkins — Continuous Integration and Deployment

-> GitHub — Version control and Webhook integration

-> DockerHub — Container Image Registry

-> Uptime Kuma — Monitoring and Uptime Tracking

⚙️ Pipeline Flow:

    🔁 Branch Workflow
        Branch	                    Action                              DockerHub Repo
        dev	      Builds and pushes image to DockerHub (Development)	  sakthi312/dev:latest
        main	    Builds and pushes image to DockerHub (Production)	    sakthi312/prod:latest

🧩 Steps to Reproduce
  1️⃣ Launch AWS EC2 Instance

      -> OS: Ubuntu 22.04
      -> Instance Type: t2.micro
      -> Security Group Rules:
        | Port | Purpose     | Source    |
        | ---- | ----------- | --------- |
        | 22   | SSH         | My IP     |
        | 8080 | Jenkins     | 0.0.0.0/0 |
        | 3001 | Uptime Kuma | 0.0.0.0/0 |
        | 3000 | React App   | 0.0.0.0/0 |

      
2️⃣ Install Required Tools

    <img width="839" height="250" alt="image" src="https://github.com/user-attachments/assets/6066da41-6f7f-4363-9da9-3d374ec157b1" />
    
        -> Access Jenkins → http://<EC2-Public-IP>:8080

3️⃣ Clone Repository

    git clone https://github.com/sriram-R-krishnan/devops-build
    cd devops-build

  Set your remote URL:
    git remote set-url origin https://Sakthi-312:<your_token>@github.com/Sakthi-312/devops-build.git
    <img width="1176" height="370" alt="image" src="https://github.com/user-attachments/assets/5f913860-c0ae-416b-bcc2-e16ed3fa46d4" />
    <img width="1806" height="284" alt="image" src="https://github.com/user-attachments/assets/7bdd68ee-e915-41dc-a6ca-51ec9ab02e08" />


4️⃣ Create Dev Branch & Add CI/CD Files
  git checkout -b dev

  Add the following files:

    Dockerfile
    docker-compose.yaml
    build.sh
    deploy.sh
    Jenkinsfile
    .gitignore
    .dockerignore
    
  Push changes:

  git add .
  git commit -m "Give a Message"
  git push origin dev
  
  <img width="1080" height="997" alt="image" src="https://github.com/user-attachments/assets/e5ea1d67-e6ad-4e16-83c4-70866822302e" />


5️⃣ Configure Jenkins

  Install Plugins:
    . Git Plugin
    . Docker Plugin
    . Docker Pipeline
    . Pipeline: Stage View
    . GitHub Integration Plugin

Add Credentials:

<img width="1916" height="339" alt="image" src="https://github.com/user-attachments/assets/1443ba40-11fd-4de3-97fa-2ee182947c6a" />

  Create Multibranch Pipeline:
      . Repo URL: https://github.com/Sakthi-312/devops-build.git
      . Jenkins auto-discovers dev and main branches.

6️⃣ Set Up GitHub Webhook

In your GitHub Repo → Settings → Webhooks → Add Webhook:
    
    Payload URL: http://<EC2-IP>:8080/github-webhook/
    Content type: application/json
    Trigger: Just the push event

    <img width="910" height="496" alt="image" src="https://github.com/user-attachments/assets/c073e4d7-2bdf-4faa-a3d8-98289173ef58" />
    
    <img width="1001" height="550" alt="image" src="https://github.com/user-attachments/assets/d81ede10-3568-4554-9f72-5ca3d6d60fe8" />

    Login Page:
    
    <img width="1914" height="551" alt="image" src="https://github.com/user-attachments/assets/c0dd90da-e3a9-4fac-853e-19a5cebfa4f7" />


✅ Every new commit triggers Jenkins automatically.

7️⃣ DockerHub
    Create two repositories:
    1. sakthi312/dev
    2. sakthi312/prod
    
    <img width="1986" height="639" alt="image" src="https://github.com/user-attachments/assets/b56733d8-f583-46f6-a663-71e1038ae6d8" />


8️⃣ Run and Verify Jenkins Build

Push code to dev → Jenkins builds & pushes image to sakthi312/dev:latest

Merge dev → main → Jenkins builds & pushes image to sakthi312/prod:latest

9️⃣ Monitoring (Uptime Kuma)

Deploy monitoring container:

sudo docker run -d \
  --restart=always \
  -p 3001:3001 \
  -v uptime-kuma-data:/app/data \
  louislam/uptime-kuma:1


Access → http://<EC2-Public-IP>:3001

Add Monitors for:

Jenkins → http://<EC2-IP>:8080

App (React) → http://<EC2-IP>:3000

📊 Jenkinsfile Overview
      pipeline {
          agent any
      
          environment {
              DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
              DOCKER_USER = 'sakthi312'
          }
      
          stages {
              stage('Build') {
                  steps {
                      sh 'chmod +x build.sh'
                      sh './build.sh'
                  }
              }
      
              stage('Push to DockerHub') {
                  steps {
                      script {
                          def branch = env.BRANCH_NAME ?: 'unknown'
                          echo "Detected branch: ${branch}"
      
                          docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
                              if (branch == 'dev') {
                                  echo "Pushing to public dev repository..."
                                  sh '''
                                  docker tag react-app sakthi312/dev:latest
                                  docker push sakthi312/dev:latest
                                  '''
                              } else if (branch == 'main') {
                                  echo "Pushing to private prod repository..."
                                  sh '''
                                  docker tag react-app sakthi312/prod:latest
                                  docker push sakthi312/prod:latest
                                  '''
                              } else {
                                  echo "Skipping push for branch ${branch}"
                              }
                          }
                      }
                  }
              }
      
              stage('Deploy') {
                  when {
                      anyOf {
                          branch 'dev'
                          branch 'main'
                      }
                  }
                  steps {
                      sh 'chmod +x deploy.sh'
                      sh './deploy.sh'
                  }
              }
          }
      }

🧠 Troubleshooting Guide:

| Issue                                    | Fix                                                                 |
| ---------------------------------------- | ------------------------------------------------------------------- |
| `permission denied /var/run/docker.sock` | `sudo usermod -aG docker jenkins && sudo systemctl restart jenkins` |
| Build not triggered                      | Check GitHub webhook delivery status (should return **200**)        |
| Docker push failed                       | Verify `dockerhub-creds` in Jenkins credentials                     |

🏁 Outcome

✅ Fully Automated CI/CD Pipeline

✅ React App Containerized & Deployed

✅ Multi-branch Docker Image Handling

✅ Monitoring via Uptime Kuma

✅ Infrastructure as Code using Terraform

✅ Cloud-Native, Production-ready Deployment
