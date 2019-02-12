#!/bin/sh

echo $TRAVIS_BRANCH

docker login -u $DOCKER_ID -p $DOCKER_PASSWORD
docker pull $DOCKER_ID/$API
docker pull $DOCKER_ID/$CLIENT
docker pull $DOCKER_ID/$NGINX

docker-compose build
docker-compose -f docker-compose-ci.yml up -d --build