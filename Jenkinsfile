properties([pipelineTriggers([githubPush()])])
pipeline {
   agent any
   stages {
      stage('Preparation') {
         steps {
            cleanWs()
            git credentialsId: 'GitHub', url: "https://github.com/${ORGANIZATION_NAME}/${REPOSITORY_NAME}"
         }
      }
	  stage('Create ConfigMap for Fluentd') {
          steps {
                    sh 'envsubst < ${WORKSPACE}/elk/configmaps/fluentd-config.yaml | kubectl apply -f -'
          }
      }
	  stage('Deploy Fluentd') {
          steps {
                    sh 'envsubst < ${WORKSPACE}/elk/fluentd/fluentd.yaml | kubectl apply -f -'
          }
      }
	  stage('Deploy Elasticsearch') {
          steps {
                    sh 'envsubst < ${WORKSPACE}/elk/elasticsearch/elasticsearch.yaml | kubectl apply -f -'
          }
      }
	     stage('Deploy Kibana') {
          steps {
                    sh 'envsubst < ${WORKSPACE}/elk/kibana/kibana.yaml | kubectl apply -f -'
          }
      }
      
   }
}
