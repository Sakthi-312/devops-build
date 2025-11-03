pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        DOCKER_USER = 'sakthi312'
    }

    triggers {
        githubPush()
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
