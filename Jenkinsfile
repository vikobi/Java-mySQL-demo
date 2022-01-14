#!/usr/bin/env groovy

pipeline {
    agent any
    environment {
        ECR_REPO_URL = '664574038682.dkr.ecr.eu-west-3.amazonaws.com'
        IMAGE_REPO = "${ECR_REPO_URL}/java-app"
        IMAGE_NAME = "1.0-${BUILD_NUMBER}"
        CLUSTER_NAME = "my-cluster"
        CLUSTER_REGION = "eu-west-3"
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
                

                }
            }
        }
        stage('deploy') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
                APP_NAME = 'java-app'
                APP_NAMESPACE = 'my-app'
            }
            steps {
                script {
                    sh "aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${CLUSTER_REGION}"

                    // set variable values for db-secret data, by accessing the secret values, defined in Jenkins credentials as a "secret text" credentials type. We access them using the credentials id
                    db_name = credentials('db-user')
                    db_pass = credentials('db-pass')
                    db_name = credentials('db-name')
                    db_root_pass = credentials('db-root-pass')

                    DB_USER = sh(script: 'echo -n $db_user | base64', returnStdout: true, returnStatus: true)
                    DB_PASS = sh(script: 'echo -n $db_pass | base64', returnStdout: true, returnStatus: true)
                    DB_NAME = sh(script: 'echo -n $db_name | base64', returnStdout: true, returnStatus: true)
                    DB_ROOT_PASS = sh(script: 'echo -n $db_root_pass | base64', returnStdout: true, returnStatus: true)
                    
                    echo 'deploying new release to EKS...'
                    sh 'envsubst < java-app-cicd.yaml | kubectl apply -f -'
                    sh 'envsubst < db-config-cicd.yaml | kubectl apply -f -'
                    sh 'envsubst < db-secret-cicd.yaml | kubectl apply -f -'

                    
                }
            }
        }
    }
}
