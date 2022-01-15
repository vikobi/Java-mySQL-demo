#!/usr/bin/env groovy

pipeline {
    agent any
    environment {
        ECR_REPO_URL = '664574038682.dkr.ecr.eu-west-3.amazonaws.com'
        IMAGE_REPO = "${ECR_REPO_URL}/java-app"
        IMAGE_NAME = "1.0-${BUILD_NUMBER}"
        CLUSTER_NAME = "my-cluster"
        CLUSTER_REGION = "eu-west-3"
        AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
    }
    stages {
        stage('build app') {
            steps {
               script {
                   echo "building the application..."
                   sh './gradlew clean build'
               }
            }
        }
        stage('build image') {
            steps {
                script {
                    echo "building the docker image..."
                    sh "docker build -t ${IMAGE_REPO}:${IMAGE_NAME} ."
                    sh "aws ecr get-login-password --region ${CLUSTER_REGION} | docker login --username AWS --password-stdin ${ECR_REPO_URL}"
                    sh "docker push ${IMAGE_REPO}:${IMAGE_NAME}"
                }
            }
        }
        stage('deploy') {
            environment {
                APP_NAME = 'java-app'
                APP_NAMESPACE = 'my-app'
                DB_USER_SECRET = credentials('db_user')
                DB_PASS_SECRET = credentials('db_pass')
                DB_NAME_SECRET = credentials('db_name')
                DB_ROOT_PASS_SECRET = credentials('db_root_pass')
            }
            steps {
                script {
                    // configure kubeconfig context to access the cluster with kubectl - alternative to copying the kubeconfig file to Jenkins server manually
                    sh "aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${CLUSTER_REGION}"

                    // set variable values for db-secret data, by accessing the secret values, defined in Jenkins credentials as a "secret text" credentials type. We access them using the credentials id
                    
                    DB_USER = sh(script: 'echo -n $DB_USER_SECRET | base64', returnStdout: true).trim()
                    DB_PASS = sh(script: 'echo -n $DB_PASS_SECRET | base64', returnStdout: true).trim()
                    DB_NAME = sh(script: 'echo -n $DB_NAME_SECRET | base64', returnStdout: true).trim()
                    DB_ROOT_PASS = sh(script: 'echo -n $DB_ROOT_PASS_SECRET | base64', returnStdout: true).trim()
                    

                    // Note the correct usage of secret credentials in script: https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#interpolation-of-sensitive-environment-variables
                    // Wrong: script: "echo -n ${DB_PASS_SECRET} | base64"
                    // Correct: script: 'echo -n $DB_PASS_SECRET | base64'
                    
                    echo 'deploying new release to EKS...'
                    sh 'envsubst < k8s-deployment/java-app-cicd.yaml | kubectl apply -f -'
                    sh 'envsubst < k8s-deployment/db-config-cicd.yaml | kubectl apply -f -'
                    sh 'envsubst < k8s-deployment/db-secret-cicd.yaml | kubectl apply -f -'

                    
                }
            }
        }
    }
}
