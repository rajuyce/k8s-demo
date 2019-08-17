properties([pipelineTriggers([githubPush()])])
pipeline {
   agent any
   environment {
     // You must set the following environment variables
     // ORGANIZATION_NAME
     // DOCKERHUB_USERNAME  (it doesn't matter if you don't have one)
     // REPOSITORY_NAME
     REPOSITORY_TAG="${ORGANIZATION_NAME}/${REPOSITORY_NAME}:${BUILD_ID}"
     registry = "${ORGANIZATION_NAME}/${REPOSITORY_NAME}"
     registryCredential = 'dockerhub'
     dockerImage = ''
   }

   stages {
      stage('Preparation') {
         steps {
            cleanWs()
            git credentialsId: 'GitHub', url: "https://github.com/${ORGANIZATION_NAME}/${REPOSITORY_NAME}"
         }
      }
	  stage('Create ConfigMap for Fluentd') {
          steps {
                    sh 'envsubst < ${WORKSPACE}/fluentd-config/fluentd-config.yaml | kubectl apply -f -'
          }
      }
	  stage('Create StorageClass for ElasticSearch') {
          steps {
                    sh 'envsubst < ${WORKSPACE}/elastic-stack/storageclass-aws.yml | kubectl apply -f -'
          }
      }
	  stage('Deploy ELK Components') {
          steps {
                    sh 'envsubst < ${WORKSPACE}/elastic-stack/elastic-stack.yaml | kubectl apply -f -'
          }
      }
      
   }
}
