pipeline {
    environment {
        KUBECONFIG = credentials('KUBECONFIG')
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    agent {
        kubernetes {
            yaml """
                kind: Pod
                apiVersion: v1
                spec:
                  containers:
                  - name: buildah
                    image: quay.io/buildah/stable
                    command:
                    - cat
                    tty: true
                    securityContext:
                      privileged: true
                  - name: golang
                    image: golang:1.23-alpine
                    command:
                    - cat
                    tty: true
                  - name: tester
                    image: ubuntu:22.04
                    command:
                    - cat
                    tty: true
                  - name: sonarqube
                    image: sonarqube:9.9-community
                    ports:
                    - containerPort: 9000
                  - name: sonar
                    image: sonarsource/sonar-scanner-cli:5.0
                    command:
                    - cat
                    tty: true
                """
        }   
    }
    stages {
        stage('App building') {
            steps {
                container('golang') {
                    sh '''
                    mkdir -p word-cloud-generator
                    cd word-cloud-generator
                    apk add --no-cache git make
                    git clone https://github.com/Fenikks/word-cloud-generator.git .
                    make
                    cp artifacts/linux/word-cloud-generator .
                    '''
                }
            }
        }
        stage('Unit test') {
            steps {
                container('tester') {
                    sh '''
                    apt update
                    apt install -y curl
                    ./word-cloud-generator/word-cloud-generator &
	                sleep 5
                    curl -H "Content-Type: application/json" -d '{"text":"ths is a really really really important thing this is"}' http://localhost:8888/api
                    '''
                }
            }
        }
        stage('Manual Trigger') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    script {
                        def userInput = input(
                            message: 'Approve to proceed?',
                            ok: 'Yes, go ahead!',
                            submitterParameter: 'APPROVER',
                            parameters: []
                        )
                    }
                }
            }
        }
        stage('Build Docker Image with Buildah') {
            steps {
                container('buildah') {
                    sh '''
                    buildah bud -t wordcloudgen:1.0 -f https://raw.githubusercontent.com/shall-it/rsschool-devops-course-tasks-helm-jenkins/task_6/Dockerfile .
                    buildah tag localhost/wordcloudgen:1.0 035511759406.dkr.ecr.us-east-1.amazonaws.com/wordcloudgen:1.0
                    buildah images
                    dnf install -y curl unzip
                    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip awscliv2.zip
                    ./aws/install
                    aws --version
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    aws ecr get-login-password --region us-east-1 | buildah login --username AWS --password-stdin 035511759406.dkr.ecr.us-east-1.amazonaws.com
                    buildah push 035511759406.dkr.ecr.us-east-1.amazonaws.com/wordcloudgen:1.0
                    buildah rmi localhost/wordcloudgen:1.0 035511759406.dkr.ecr.us-east-1.amazonaws.com/wordcloudgen:1.0 docker.io/library/golang:1.23-alpine
                    '''
                }
            }
            post {
                failure {
                    error 'Build Docker Image stage failed, Deployment to K8s cluster with Helm cannot be executed until fixing'
                }
            }
        }
        stage('Deployment to K8s cluster with Helm') {
            steps {
                container('buildah') {
                    withCredentials([file(credentialsId: 'KUBECONFIG', variable: 'KUBECONFIG')]) {
                        sh '''
                        dnf install -y helm kubectl git
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        aws ecr get-login-password --region us-east-1 | buildah login --username AWS --password-stdin 035511759406.dkr.ecr.us-east-1.amazonaws.com
                        rm -rf ~/.kube/*
                        mkdir -p ~/.kube
                        cat $KUBECONFIG > ~/.kube/config
                        kubectl get nodes
                        git clone https://github.com/shall-it/rsschool-devops-course-tasks-helm-jenkins.git
                        cd rsschool-devops-course-tasks-helm-jenkins
                        git checkout task_6
                        helm install wordcloudgen ./Chart --namespace default
                        helm list --namespace default
                    '''}
                }
            }
        }
    }    
}
