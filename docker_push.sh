#!/bin/sh

if [ -z "$TRAVIS_PULL_REQUEST" ] || [ "$TRAVIS_PULL_REQUEST" == "false" ]
then

  if [ "$TRAVIS_BRANCH" == "development" ]
  then
    docker login -e $DOCKER_EMAIL -u $DOCKER_ID -p $DOCKER_PASSWORD
    export TAG=$TRAVIS_BRANCH
    export REPO=$DOCKER_ID
    export DJANGO_ENVIRONMENT="development"
    export DJANGO_SECRET_KEY="everything_is_tater_tots"
    export REACT_APP_OAUTH_CLIENT_ID=$REACT_APP_OAUTH_CLIENT_ID
    export CLIENT_ID=$CLIENT_ID
  fi

  if [ "$TRAVIS_BRANCH" == "staging" ]
  then
    export DJANGO_ENVIRONMENT="production"
    export DJANGO_SECRET_KEY="$DJANGO_SECRET_KEY"
    export REACT_APP_OAUTH_CLIENT_ID=$REACT_APP_OAUTH_CLIENT_ID
    export CLIENT_ID=$CLIENT_ID
  fi

  if [ "$TRAVIS_BRANCH" == "production" ]
  then
    export DJANGO_ENVIRONMENT="production"
    export DJANGO_SECRET_KEY="$DJANGO_SECRET_KEY"
    export REACT_APP_OAUTH_CLIENT_ID=$REACT_APP_OAUTH_CLIENT_ID
    export CLIENT_ID=$CLIENT_ID
  fi

  if [ "$TRAVIS_BRANCH" == "development" ] || \
     [ "$TRAVIS_BRANCH" == "staging" ] || \
     [ "$TRAVIS_BRANCH" == "production" ]
  then
    # api
    if [ "$TRAVIS_BRANCH" == "production" ] || \
       [ "$TRAVIS_BRANCH" == "staging" ]
    then
      docker build $API_REPO -t $API:$COMMIT
      docker build $CLIENT_REPO -t $CLIENT:$COMMIT
    else
      docker build $API_REPO -t $API:$COMMIT -f Dockerfile-local
      docker build $CLIENT_REPO -t $CLIENT:$COMMIT -f Dockerfile-local
    fi
    docker tag $API:$COMMIT $REPO/$API:$TAG
    docker push $REPO/$API:$TAG

    docker tag $CLIENT:$COMMIT $REPO/$CLIENT:$TAG
    docker push $REPO/$CLIENT:$TAG

    docker build $NGINX_REPO -t $NGINX:$COMMIT
    docker tag $NGINX:$COMMIT $REPO/$NGINX:$TAG
    docker push $REPO/$NGINX:$TAG
  fi

fi