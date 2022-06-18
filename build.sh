#!/bin/bash
set -ex

controller() {
   terraform apply -replace=module.ecr.null_resource.build_and_push_image_jenkins_controller -auto-approve
}

agent() {
   terraform apply -replace=module.ecr.null_resource.build_and_push_image_jenkins_agent -auto-approve
}

$1 2>&1 | tee -a ./build.log