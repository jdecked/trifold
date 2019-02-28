#!/bin/sh
if [ -z "$TRAVIS_PULL_REQUEST" ] || [ "$TRAVIS_PULL_REQUEST" == "false" ]
then
  touch $HOME/.docker/config.json
  echo \{\"credsStore\": \"pass\"\} > $HOME/.docker/config.json
  echo "$DOCKER_PASSWORD" | docker login -u $DOCKER_ID --password-stdin

  export TAG=$TRAVIS_BRANCH
  export REPO=$DOCKER_ID
  export DJANGO_ENVIRONMENT="production"
  export DJANGO_SECRET_KEY="$DJANGO_SECRET_KEY"
  export REACT_APP_OAUTH_CLIENT_ID=$REACT_APP_OAUTH_CLIENT_ID
  export CLIENT_ID=$CLIENT_ID

  docker build $API_REPO -t $API:$COMMIT
  docker tag $API:$COMMIT $REPO/$API:$TAG
  docker push $REPO/$API:$TAG

  docker build $CLIENT_REPO -t $CLIENT:$COMMIT
  docker tag $CLIENT:$COMMIT $REPO/$CLIENT:$TAG
  docker push $REPO/$CLIENT:$TAG

  docker build $NGINX_REPO -t $NGINX:$COMMIT
  docker tag $NGINX:$COMMIT $REPO/$NGINX:$TAG
  docker push $REPO/$NGINX:$TAG

fi