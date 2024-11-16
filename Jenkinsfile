pipeline {
    agent { label 'built-in' }
    environment {
        KUBECONFIG = credentials('KUBECONFIG')
    }
    stages {
        stage('Install kubectl') { 
            steps { 
                script { 
                    sh '''
                    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                    chmod +x kubectl'
                    mv kubectl /usr/local/bin/
                    '''
                }
            }
        }
        stage('Install docker') { 
            steps { 
                script { 
                    sh '''
                    apt-get update
                    apt-get install ca-certificates curl
                    install -m 0755 -d /etc/apt/keyrings
                    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
                    chmod a+r /etc/apt/keyrings/docker.asc
                    echo \
                        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                    apt-get update
                    '''
                }
            }
        }
        stage('Configure Kubernetes CLI') {
            steps {
                script {
                    sh '''
                    rm -rf /root/.kube/*'
                    mkdir -p /root/.kube'
                    echo "$KUBECONFIG" > /root/.kube/config'
                    kubectl get nodes
                    docker pull 035511759406.dkr.ecr.us-east-1.amazonaws.com/wordcloudgen:1.0
                    '''
                }
            }
        }
    }
}
