# NodeApp

The NodeApp is a test npm app. The main functionality for this is to verify functioning of proper CICD pipeline

The pipeline is automated and stored in a Jenkinsfile, written as Pipeline as a code
Within your Jenkins server, create a pipeline and use "Pipeline Script from SCM"

Prerequisites:

This requires you to have "AWS CLI" configured on the node where the pipeline would execute.
Within Jenkins, you also need to add your AWS credentials in the credentials manager and also as variables within Jenkins
You also need to replace the organization ID with your own AWS organization ID in taskdef.json file
The Jenkins file also has the region hardcoded for docker.withRegistory() as is the format for the provider specific credential in the context of private repository.
The deployment is on docker container and build image is stored in ECR (you need to have these setup)[refer to the "saquibm6/terraform" repo for IAC files for terraform]
Even though it is present by default, make sure you have "sed, jq, and tr" package installed
This also requires for some Jenkins plugins to be already installed: CloudBees Credentials Plugin	|	Amazon ECR plugin | CloudBees Docker Build and Publish plugin |	Docker plugin | Email Extension Plugin | docker-build-step
