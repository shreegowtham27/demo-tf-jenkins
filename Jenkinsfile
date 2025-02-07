pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        AWS_ACCOUNT_ID = ""
        IMAGE_TAG = $BUILD_NUMBER
        BRANCH_NAME = ""
        DEPLOY_ENV = ""
    }

    stages {
        stage('Determine Environment') {
            steps {
                script {
                    BRANCH_NAME = env.GIT_BRANCH.replace('origin/', '')  // Detect branch name

                    if (BRANCH_NAME == "main") {
                        DEPLOY_ENV = "prod"
                        AWS_ACCOUNT_ID = "prod-123456"  // Replace with your prod AWS Account ID
                    } else if (BRANCH_NAME == "dev") {
                        DEPLOY_ENV = "dev"
                        AWS_ACCOUNT_ID = "dev-123456"  // Replace with your dev AWS Account ID
                    } else {
                        error("Deployment can only be done from 'main' or 'dev' branches!")
                    }

                    echo "✅ Branch: ${BRANCH_NAME}, Environment: ${DEPLOY_ENV}, AWS Account: ${AWS_ACCOUNT_ID}"
                }
            }
        }

        stage('Checkout Code') {
            steps {
                script {
                    git branch: BRANCH_NAME, url: 'https://github.com/shreegowtham27/react-docker-app.git'  // Replace with your repo
                }
            }
        }

         stage('Terraform Init') {
            steps {
                script {
                    sh 'terraform init \
                        -backend-config="bucket=react-test-terraform-backend" \
                        -backend-config="key='${DEPLOY_ENV}'/terraform.tfstate" \
                        -backend-config="region='${AWS_REGION}'" \
                        -backend-config="encrypt=true" \
                        -backend-config="dynamodb_table=terraform-lock"'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    sh "terraform plan -var-file=env-configs/${DEPLOY_ENV}.tfvars"
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    sh "terraform apply -auto-approve -var-file=env-configs/${DEPLOY_ENV}.tfvars"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def repo_url = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/react-docker-app"
                    def docker_image = "${repo_url}:${IMAGE_TAG}"

                    sh "docker build -t $docker_image ."
                    sh "docker tag $docker_image $repo_url:${DEPLOY_ENV}-${IMAGE_TAG}"

                    env.DOCKER_IMAGE = docker_image
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        sh "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
                    }
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                script {
                    sh "docker push $DOCKER_IMAGE"
                }
            }
        }
    }

    post {
        success {
            echo "🚀 Deployment to ${DEPLOY_ENV} successful!"
        }
        failure {
            echo "❌ Deployment failed."
        }
    }
}
