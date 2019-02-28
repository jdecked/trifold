#!/bin/sh
cd "$(dirname $0)"

getDockerCredentialPass () {
  PASS_URL="$(curl -s https://api.github.com/repos/docker/docker-credential-helpers/releases/latest \
    | grep "browser_download_url.*pass-.*-amd64" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | cut -c2- )"

  [ "$(echo "$PASS_URL" | cut -c1-5)" != "https" ] && PASS_URL="https://github.com/docker/docker-credential-helpers/releases/download/v0.6.0/docker-credential-pass-v0.6.0-amd64.tar.gz"

  echo "PASS_URL: $PASS_URL"
  curl -fsSL "$PASS_URL" | tar xv
  chmod + $(pwd)/docker-credential-pass
}

dockerLogin () {
  [ "$CI" = "true" ] && gpg --batch --gen-key <<-EOF ; pass init $(gpg --no-auto-check-trustdb --list-secret-keys | grep ^sec | cut -d/ -f2 | cut -d" " -f1)
%echo Generating a standard key
Key-Type: DSA
Key-Length: 1024
Subkey-Type: ELG-E
Subkey-Length: 1024
Name-Real: Meshuggah Rocks
Name-Email: meshuggah@example.com
Expire-Date: 0
# Do a commit here, so that we can later print "done" :-)
%commit
%echo done
EOF
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_ID" --password-stdin
}

if [ -z "$TRAVIS_PULL_REQUEST" ] || [ "$TRAVIS_PULL_REQUEST" == "false" ]
then
  getDockerCredentialPass
  dockerLogin

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