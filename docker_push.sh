#!/bin/sh

if [ -z "$TRAVIS_PULL_REQUEST" ] || [ "$TRAVIS_PULL_REQUEST" == "false" ]
then

  if [ "$TRAVIS_BRANCH" == "development" ]
  then
    docker login -e $DOCKER_EMAIL -u $DOCKER_ID -p $DOCKER_PASSWORD
    export TAG=$TRAVIS_BRANCH
    export REPO=$DOCKER_ID
    export DATABASE_URL="mysql://root@localhost/trifold_dev"
    export HTTPS=true
    export DJANGO_ENVIRONMENT="development"
    export DJANGO_SECRET_KEY="everything_is_tater_tots"
  fi

  if [ "$TRAVIS_BRANCH" == "staging" ]
  then
    export DATABASE_URL="mysql://root@localhost/trifold_staging"
    export HTTPS=true
    export DJANGO_ENVIRONMENT="production"
    export DJANGO_SECRET_KEY="$DJANGO_SECRET_KEY"
  fi

  if [ "$TRAVIS_BRANCH" == "production" ]
  then
    export DATABASE_URL="mysql://root@localhost/trifold"
    export HTTPS=true
    export DJANGO_ENVIRONMENT="production"
    export DJANGO_SECRET_KEY="$DJANGO_SECRET_KEY"
  fi

  if [ "$TRAVIS_BRANCH" == "development" ] || \
     [ "$TRAVIS_BRANCH" == "staging" ] || \
     [ "$TRAVIS_BRANCH" == "production" ]
  then
    # users
    if [ "$TRAVIS_BRANCH" == "production" ]
    then
      docker build $API_REPO -t $API:$COMMIT -f Dockerfile-prod
    else
      docker build $API_REPO -t $API:$COMMIT
    fi
    docker tag $API:$COMMIT $REPO/$API:$TAG
    docker push $REPO/$API:$TAG
    # client
    docker build $CLIENT_REPO -t $CLIENT:$COMMIT
    docker tag $CLIENT:$COMMIT $REPO/$CLIENT:$TAG
    docker push $REPO/$CLIENT:$TAG
    # nginx
    docker build $NGINX_REPO -t $NGINX:$COMMIT
    docker tag $NGINX:$COMMIT $REPO/$NGINX:$TAG
    docker push $REPO/$NGINX:$TAG
  fi

fi