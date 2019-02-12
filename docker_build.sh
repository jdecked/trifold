#!/bin/sh

echo $TRAVIS_BRANCH

echo $DOCKER_PASSWORD | docker login -u $DOCKER_ID --password-stdin
echo 'still going 1'
docker pull $DOCKER_ID/$API
echo 'still going 2'
docker pull $DOCKER_ID/$CLIENT
echo 'still going 3'
docker pull $DOCKER_ID/$NGINX
echo 'still going 4'

docker-compose build
docker-compose -f docker-compose-ci.yml up -d --build