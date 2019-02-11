#!/bin/sh

if [ "$TRAVIS_BRANCH" == "development" ]; then
  docker login -e $DOCKER_EMAIL -u $DOCKER_ID -p $DOCKER_PASSWORD
  docker pull $DOCKER_ID/$API
  docker pull $DOCKER_ID/$CLIENT
  docker pull $DOCKER_ID/$NGINX
fi

docker-compose build
docker-compose -f docker-compose-ci.yml up -d --build