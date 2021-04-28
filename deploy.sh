#!/bin/bash
set -x
#Constants

PATH=$PATH:-/usr/local/bin; export PATH
REGION=us-east-2
REPOSITORY_NAME=hello-world
CLUSTER=fargate
FAMILY=`sed -n 's/.*"family": "\(.*\)",/\1/p' taskdef.json`
NAME=`sed -n 's/.*"name": "\(.*\)",/\1/p' taskdef.json`
SERVICE_NAME=${NAME}-service
env
aws configure list
echo $HOME

#Store the repositoryUri as a variable
REPOSITORY_URI=`aws ecr describe-repositories --repository-names ${REPOSITORY_NAME} --region ${REGION} | jq .repositories[].repositoryUri | tr -d '"'`

#Replace the build number and respository URI placeholders with the constants above
sed -e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" -e "s;%REPOSITORY_URI%;${REPOSITORY_URI};g" taskdef.json > ${NAME}-v_${BUILD_NUMBER}.json

#Register the task definition in the repository
aws ecs register-task-definition --family ${FAMILY} --cli-input-json file://${WORKSPACE}/${NAME}-v_${BUILD_NUMBER}.json --region ${REGION}
SERVICES=`aws ecs describe-services --services ${SERVICE_NAME} --cluster ${CLUSTER} --region ${REGION} | jq .failures[]`

#Get latest revision
REVISION=`aws ecs describe-task-definition --task-definition ${NAME} --region ${REGION} | jq .taskDefinition.revision`

#Create or update service
if ["$SERVICES" == ""]; then
 echo "entered existing service"
 DESIRED_COUNT=`aws ecs describe-services --services ${SERVICE_NAME} --cluster ${CLUSTER} --region ${REGION}| jq .services[].desiredCount`

 if [ ${DESIRED_COUNT} = "0" ]; then
  DESIRED_COUNT="1"
 fi
 aws ecs update-service --cluster ${CLUSTER} --region ${REGION} --service ${SERVICE_NAME} --task-definition ${FAMILY}:${REVISION} --desired-count ${DESIRED_COUNT}
else
 echo "entered new service"
 aws ecs create-service --service-name ${SERVICE_NAME} --launch-type FARGATE --desired-count 1 --task-definition ${FAMILY} --cluster ${CLUSTER} --region ${REGION} --network-configuration "awsvpcConfiguration={subnets=[subnet-08cd0135126648d89, subnet-0d902981621e8915a],securityGroups=[sg-01983ea1eb5d8db37, sg-0592bcfb288bd1e9b],assignPublicIp=ENABLED}"
fi