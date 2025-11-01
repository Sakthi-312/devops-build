pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        DOCKER_USER = 'sakthi312'
    }

    triggers {
        // Automatically trigger Jenkins when code is pushed to GitHub
        githubPush()
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Checking out the source code..."
                git branch: "${env.BRANCH_NAME ?: 'main'}", url: 'https://github.com/Sakthi-312/devops-build.git'
            }
        }

        stage('Build App') {
            steps {
                echo "Running build script..."
                sh 'chmod +x build.sh'
                sh './build.sh'
            }
        }

        stage('Docker Build') {
            steps {
                echo "Building Docker image..."
                sh 'docker build -t react-app .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    echo "Logging into DockerHub..."
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {

                        // Detect the current branch
                        def branch = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                        echo "Detected branch: ${branch}"

                        if (branch == 'dev') {
                            echo "Pushing to DEV repo on DockerHub..."
                            sh '''
                                docker tag react-app ${DOCKER_USER}/dev:latest
                                docker push ${DOCKER_USER}/dev:latest
                            '''
                        } else if (branch == 'main') {
                            echo "Pushing to PROD repo on DockerHub..."
                            sh '''
                                docker tag react-app ${DOCKER_USER}/prod:latest
                                docker push ${DOCKER_USER}/prod:latest
                            '''
                        } else {
                            echo "⚠️ Branch ${branch} is not configured for push."
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo "Running deployment script..."
                sh 'chmod +x deploy.sh'
                sh './deploy.sh'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully for branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "❌ Pipeline failed! Please check the logs."
        }
    }
}
