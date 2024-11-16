pipeline {
    agent { label 'built-in' }
    environment {
        KUBECONFIG = credentials('KUBECONFIG')
    }
    stages {
        stage('Install kubectl') { 
            steps { 
                script { 
                    sh 'curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"'
                    sh 'chmod +x kubectl'
                    sh 'mv kubectl /usr/local/bin/'
                }
            }
        }
        stage('Configure Kubernetes CLI') {
            steps {
                script {
                    sh '''
                    echo "$KUBECONFIG"'
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
