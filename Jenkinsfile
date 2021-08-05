node {
    checkout scm
    def baseImage = docker.build("workspace:${env.BUILD_ID}","-f base-image/Dockerfile .")
    baseImage.push()

    baseImage.push('latest')
}