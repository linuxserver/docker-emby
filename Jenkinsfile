pipeline {
    agent any
    stages {
        stage('ReleaseInfo') {
            steps {
                sh '''curl -s https://api.github.com/repos/MediaBrowser/Emby/releases | jq -r '.[] | .tag_name' | head -10 > releases.txt'''
            }
        }
        stage('Build') {
            steps {
                echo 'Building last 10 releases of Emby'
                sh '''for version in $(cat releases.txt); do 
                        docker build --no-cache -t linuxserver/emby:$version --build-arg EMBY_VER=$version . 
                      done'''
            }
        }
        stage('Test') {
            steps {
                echo 'CI Tests for future use'
            }
        }
        stage('Push') {
            steps {
                echo 'First push the latest tag'
                sh 'docker tag linuxserver/emby:$(cat releases.txt |head -1) linuxserver/emby:latest'
                sh 'docker push linuxserver/emby:latest'
                echo 'Now pushing the last 10 release tags for the remote project'
                sh '''for version in $(cat releases.txt); do 
                        docker push linuxserver/emby:$version
                      done'''
            }
        }
    }
}
