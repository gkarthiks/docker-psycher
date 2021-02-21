#!/bin/sh
set -e
echo
# aquire token
# TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_USERNAME}'", "password": "'${DOCKER_PASSWORD}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${{secrets.DOCKER_USERNAME}}'", "password": "'${{secrets.DOCKER_PASSWORD}}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
# get list of repositories for the user account
REPO_LIST=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${DOCKER_USERNAME}/?page_size=100 | jq -r '.results|.[]|.name')

# build a list of all images & tags
for i in ${REPO_LIST}
do
  # get tags for repo
  IMAGE_TAGS=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${DOCKER_USERNAME}/${i}/tags/?page_size=1 | jq -r '.results|.[]|.name')

  # build a list of images from tags
  for j in ${IMAGE_TAGS}
  do
    # add each tag to list
    FULL_IMAGE_LIST="${FULL_IMAGE_LIST} ${DOCKER_USERNAME}/${i}:${j}"
  done
done

# output
for i in ${FULL_IMAGE_LIST}
do
  docker pull ${i}
done
