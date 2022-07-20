pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile.build'
            additionalBuildArgs "--build-arg=branch=${params.CONTAINER_BRANCH}"
        }
    }
    stages {
        stage('Initialization') {
            steps {
                buildDescription "${params.CODENAME} ${params.SRC_BRANCH}"
            }
        }
        stage('Build') {
            steps {
                sh "./endless-key-builder \"${params.CODENAME}\""
            }
        }
    }
}
