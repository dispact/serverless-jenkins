![Serverless Jenkins](https://custom-images-for-articles.s3.us-east-2.amazonaws.com/ServerlessJenkins.png)

# Serverless Jenkins
The serverless Jenkins environment created through this project will be provisioned on AWS. In the Jenkins environment, there are two components: the Jenkins controller and the Jenkins agents. The Jenkins controller is going to be your typically Jenkins server. The Jenkins agents are going to be containers that are spun up to process a job and then tear down after the job is complete. 

Terraform will be used to:
- Provision the entire AWS infrastructure needed for the serverless Jenkins environment
- Build and push the Jenkins controller and Jenkins agents images to their respective repos on ECR
   - In the Jenkins controller image, we are using a plugin called "Configuration as Code" to configure our entire Jenkins server through code and seed an example pipeline that will spin up ECS Fargate containers to run the pipeline and tear down once the pipeline is finished

<p>&nbsp;</p>

## Architecture Diagram
![Architecture Diagram](https://custom-images-for-articles.s3.us-east-2.amazonaws.com/ServerlessJenkinsArchitecture.png)

<p>&nbsp;</p>

## Jenkins Plugins
Here are a list of the Jenkins plugins that are used in this project

| Plugin | Docs |
| ------ | ------ |
| Configuration as Code | https://plugins.jenkins.io/configuration-as-code/ |
| Amazon ECS | https://plugins.jenkins.io/amazon-ecs/ |
| Job DSL | https://plugins.jenkins.io/job-dsl/ |
| Workflow Aggregator | https://plugins.jenkins.io/workflow-aggregator/ |

<p>&nbsp;</p>

## Installation
This project will require the following:
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and configured
- [Terraform](https://medium.com/r/?url=https%3A%2F%2Fwww.terraform.io%2Fdownloads) installed
- [Docker](https://docs.docker.com/get-docker/) installed

<p>&nbsp;</p>

After the requirements have been installed, you can update the variables. Open up **variables.auto.tfvars** and make sure that the AWS profile and region matches your setup. Once done, initialize the Terraform project

```sh
terraform init
```

<p>&nbsp;</p>

To make sure everything looks good, go ahead and run the terraform plan command

```sh
terraform plan
```

<p>&nbsp;</p>

If all looks good, go ahead and build the infrastructure.

```sh
terraform apply -auto-approve
```
> Note: `-auto-approve` skips the interactive prompt. This flag is optional 

<p>&nbsp;</p>

When Terraform is done running, the **jenkins_alb_dns** output is going to be the endpoint of your Jenkins server. You will get a 503 error if you try accessing it right away. It will take ~5-10 minutes for the container to come up. Once it is up, you can log into the Jenkins server with the following credentials

| Username | Password |
| ------ | ------ |
| admin | password |

<p>&nbsp;</p>

After logging in, you will see that there is an example pipeline. Before this can be ran, you will need to approve the groovy script. To do so, either append /scriptApproval/ to the URL or go to Manage Jenkins > In-process Script Approval. Once on this page, hit Approve above the groovy script.
> URL example: http://jenkins-server.com/scriptApproval/

After the groovy script has been approved, you will be able to run the example pipeline. When running this pipeline, Jenkins will spin up an ECS Fargate container to run the job and once the job is complete, the container will be terminated.

<p>&nbsp;</p>
If you need to tear down the AWS infrastructure, you can run the follow command:

```sh
terraform destroy -auto-approve
```
> Note: `-auto-approve` skips the interactive prompt. This flag is optional 
