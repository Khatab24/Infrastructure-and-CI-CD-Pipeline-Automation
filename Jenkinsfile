pipeline {
    agent any

    environment {
    	KUBECONFIG = credentials('kubeconfig-eks')
        DOCKER_CREDENTIALS = credentials('DOCKERHUB')
    }

    stages {
         stage('DockerHub Login') {
            steps {
                script {
                    sh '''
                        echo $DOCKER_CREDENTIALS_PSW | docker login -u $DOCKER_CREDENTIALS_USR --password-stdin
                    '''
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t khatab24/simpleweb .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                    docker push khatab24/simpleweb
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                        echo "Deploying to Dev namespace..."
                        sh 'aws eks update-kubeconfig --name my-eks-cluster --region us-east-2'
                        sh 'kubectl apply -f k8s/dev/dev-namespace.yml'
                        sh 'kubectl apply -f k8s/dev/deployment.yml -n dev'
                        sh 'kubectl apply -f k8s/dev/service.yml -n dev' 
                }
            
        }
    }

    post {
        success {
            echo "Deployment to successful!"
        }
        failure {
            echo "Deployment to failed!"
        }
    }
}
