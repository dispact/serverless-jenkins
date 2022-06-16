REGION=
CONTROLLER_REPO_ENDPOINT=
AGENT_REPO_ENDPOINT=
CONTROLLER_REPO_URL=
AGENT_REPO_URL=
CONTROLLER_IMAGE="jenkins-controller"
AGENT_IMAGE="jenkins-agent"

controller() {
   aws ecr get-login-password --region $REGION | \
   docker login --username AWS --password-stdin $CONTROLLER_REPO_ENDPOINT && \
   docker build -t $CONTROLLER_IMAGE modules/docker/jenkins_controller --platform linux/amd64 && \
   docker tag $CONTROLLER_IMAGE:latest $CONTROLLER_REPO_URL:latest
   docker push $CONTROLLER_REPO_URL:latest
}

agent() {
   aws ecr get-login-password --region $REGION | \
   docker login --username AWS --password-stdin $AGENT_REPO_ENDPOINT && \
   docker build -t $AGENT_IMAGE modules/docker/jenkins_controller --platform linux/amd64 && \
   docker tag $AGENT_IMAGE:latest $AGENT_REPO_URL:latest
   docker push $AGENT_REPO_URL:latest
}

$1 2>&1 | tee -a ./build.log