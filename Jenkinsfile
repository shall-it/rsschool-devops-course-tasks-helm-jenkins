pipeline {
    environment {
        KUBECONFIG = credentials('KUBECONFIG')
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
        stage('Build Docker Image with Buildah') {
            steps {
                container('buildah') {
                    sh '''
                    echo 'FROM alpine:latest\nRUN apk add --no-cache curl\nCMD ["curl", "--version"]' > Dockerfile
                    buildah bud -t myapp:latest .
                    buildah images
                    '''
                }
            }
        }
        // stage('Local SonarQube Scan') {
        //     steps {
        //         container('sonar') {
        //             sh '''
        //             sleep 60
        //             sonar-scanner \
        //               -Dsonar.projectKey=wordcloudgen \
        //               -Dsonar.sources=./word-cloud-generator \
        //               -Dsonar.host.url=http://sonarqube:9000 \
        //               -Dsonar.login=admin \
        //               -Dsonar.password=admin \
        //               -Dsonar.inclusions="**/*.go,**/*.html,**/*.css,**/*.sh,**/*.mk,**/Dockerfile" \
        //               -Dsonar.exclusions="**/*.min.css,**/*test*" \
        //               -Dsonar.go.coverage.reportPaths="coverage.out" \
        //               -Dsonar.sourceEncoding=UTF-8
        //             '''
        //         }
        //     }
        // }
        // stage('Check OS') { 
        //     steps { 
        //         script { 
        //             sh '''
        //             cat /etc/os-release
        //             apt update
        //             apt install -y unzip
        //             curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        //             unzip awscliv2.zip
        //             ./aws/install
        //             aws --version
        //             // aws sts get-caller-identity
        //             '''
        //         }
        //     }
        // }
        // stage('Push to ECR') {
        //     steps {
        //         container('buildah') { 
        //             sh '''
        //             dnf install -y curl unzip
        //             curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        //             unzip awscliv2.zip
        //             ./aws/install
        //             aws --version
        //             // aws sts get-caller-identity
        //             buildah images
        //             '''
        //         }
        //     }
        // }
    }    
}


// pipeline {
//     agent { label 'built-in' }
//     environment {
//         KUBECONFIG = credentials('KUBECONFIG')
//     }
//     stages {
//         stage('Install kubectl') { 
//             steps { 
//                 script { 
//                     sh '''
//                     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
//                     chmod +x kubectl
//                     mv kubectl /usr/local/bin/
//                     '''
//                 }
//             }
//         }
//         stage('Install docker') { 
//             steps { 
//                 script { 
//                     sh '''
//                     apt-get update
//                     apt-get install -y ca-certificates curl
//                     install -m 0755 -d /etc/apt/keyrings
//                     curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
//                     chmod a+r /etc/apt/keyrings/docker.asc
//                     echo \
//                         "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu bullseye stable" | \
//                         tee /etc/apt/sources.list.d/docker.list
//                     apt-get update
//                     apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
//                     '''
//                 }
//             }
//         }
//         stage('Configure Kubernetes CLI') {
//             steps {
//                 script {
//                     sh '''
//                     rm -rf /root/.kube/*'
//                     mkdir -p /root/.kube'
//                     echo "$KUBECONFIG" > /root/.kube/config'
//                     kubectl get nodes
//                     docker pull 035511759406.dkr.ecr.us-east-1.amazonaws.com/wordcloudgen:1.0
//                     '''
//                 }
//             }
//         }
//     }
// }
