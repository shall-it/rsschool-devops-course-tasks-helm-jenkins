# rsschool-devops-course-tasks-helm-jenkins

## Task 6
https://github.com/rolling-scopes-school/tasks/blob/master/devops/modules/3_ci-configuration/task_6.md

My application is based on https://github.com/wickett/word-cloud-generator web-application
To deploy it locally:
1. Ensure docker is up and running
2. In root of current repository run `docker build -t wordcloudgen:1.0 .` command
3. After successful building of image `wordcloudgen:1.0` run `docker run -p 80:8888 wordcloudgen:1.0`
4. Check app is working by `curl -H "Content-Type: application/json" -d '{"text":"ths is a really really really important thing this is"}' http://localhost/api` command

To push it to AWS ECR:
1. Ensure docker is up and running
2. Change repository and tag for image by `docker tag wordcloudgen:1.0 035511759406.dkr.ecr.us-east-1.amazonaws.com/wordcloudgen:1.0` command
3. Log in to AWS ECR by `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 035511759406.dkr.ecr.us-east-1.amazonaws.com` command
4. Push respective image to AWS ECR repository by `docker push 035511759406.dkr.ecr.us-east-1.amazonaws.com/wordcloudgen:1.0` command
5. In case you need to pull uploaded image to local from AWS ECR repository use `docker pull 035511759406.dkr.ecr.us-east-1.amazonaws.com/wordcloudgen:1.0` command

All these steps are automated with Jenkins pipeline and allow you to deploy WordCloudGen application to K8s cluster by Helm with execution of all required steps before.
Important notice! Please do not forget to setup Jenkins credentials which used in main job as environment variables