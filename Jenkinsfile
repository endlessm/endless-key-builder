pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile.build'
            additionalBuildArgs "--build-arg=branch=${params.CONTAINER_BRANCH}"
        }
    }
    stages {
        stage('Build') {
            steps {
                sh "./endless-key-builder \"${params.CODENAME}\""
            }
        }
    }
}
