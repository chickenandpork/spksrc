pipeline {
    agent {
        docker {
            image 'synocommunity/spksrc:c5921c2cc934'
        }
    }
    stages {
        stage('Build') {
            environment {
                UPSTREAM_GITREMOTE = 'synocommunity/master'
		/* workaround for jenkins user not in image passwd file.  An alternative option at http://ixday.github.io/post/docker_git_volume/ is to disable the reflog at system level during "docker build":
		 *
		 * FROM alpine:3.2
		 *
		 * RUN apk --update add git
		 * RUN git config --system core.logallrefupdates false
		 */
		GIT_COMMITTER_NAME = 'jenkins'
		GIT_COMMITTER_EMAIL= 'jenkins@chickenandporn.com'
            }
            steps {
                sh 'git remote -v|grep synocommunity && git remote set-url synocommunity https://github.com/SynoCommunity/spksrc.git || git remote add synocommunity https://github.com/SynoCommunity/spksrc.git'
                sh 'git fetch synocommunity master'
                sh 'make all-affected-spks UPSTREAM_GITREMOTE=synocommunity/master'
            }
        }

        stage('SSH transfer') {
          steps {
            script {
              sshPublisher(
                continueOnError: false,
                failOnError: true,
                publishers: [
                  sshPublisherDesc(
                    configName: "spk-chickenandporn-com",
                    verbose: true,
                    transfers: [
                      sshTransfer(
                        sourceFiles: "packages/**/*",
			removePrefix: "packages",
                      )]
                  )]
              )
            }
          }
        }
    }
}
