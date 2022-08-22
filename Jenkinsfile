pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile.build'
            additionalBuildArgs "--build-arg=packages=\"awscli\" --build-arg=branch=${params.CONTAINER_BRANCH}"
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
                /* The "endless-key" project prefix is reserved for Endless OS Foundation.
                 * Please choose a different prefix if you are a 3rd-party.
                 */
                sh "./endless-key-builder --project-prefix=\"endless-key\" \"${params.CODENAME}\""
            }
        }
        stage('Publish') {
            steps {
                script { env.BUILD_VER = sh(script: "ls build/out", returnStdout: true).trim() }
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'iam-user-jenkins-jobs']]) {
                    sh "aws s3 cp --cache-control max-age=300 --recursive build/out/${BUILD_VER} s3://endless-key/builds/nightly/${params.CODENAME}/${BUILD_VER}"
                }
            }
        }
        stage('Cleanup') {
            steps {
                sh "rm -rfv build"
            }
        }
    }
}
