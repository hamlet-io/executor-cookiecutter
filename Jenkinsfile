#!groovy

pipeline {
    options {
        timestamps()
    }

    agent none

    stages {

        stage('Trigger Docker Build') {
            when {
                branch 'master'
            }

            steps {
                build (
                    job: '../docker-hamlet/master',
                    wait: false
                )
            }
        }
    }
}
