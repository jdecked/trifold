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
  sudo mv docker-credential-pass /usr/local/bin/
}

dockerLogin () {
  [ "$CI" = "true" ] && gpg2 --batch --gen-key <<-EOF ; pass init $(gpg2 --no-auto-check-trustdb --list-secret-keys | grep ^sec | cut -d/ -f2 | cut -d" " -f1)
%echo Generating a standard key
Key-Type: DSA
Key-Length: 1024
Subkey-Type: ELG-E
Subkey-Length: 1024
Name-Real: Justine De Caires
Name-Email: justine@minerva.kgi.edu
Expire-Date: 0
# Do a commit here, so that we can later print "done" :-)
%commit
%echo done
EOF
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_ID" --password-stdin
}

herokuLogin() {
  wget -qO- https://toolbelt.heroku.com/install.sh | sh
  echo $HEROKU_API_KEY | docker login --username=_ --password-stdin registry.heroku.com
}

if [ -z "$TRAVIS_PULL_REQUEST" ] || [ "$TRAVIS_PULL_REQUEST" == "false" ]
then
  sudo apt-get install pass
  sudo apt-get install gnupg2 -y
  mkdir $HOME/.docker
  touch $HOME/.docker/config.json
  echo \{\"credsStore\": \"pass\"\} > $HOME/.docker/config.json
  getDockerCredentialPass
  dockerLogin
  herokuLogin

  export REPO="trifold"
  export DJANGO_ENVIRONMENT="production"
  export DJANGO_SECRET_KEY="$DJANGO_SECRET_KEY"
  export REACT_APP_OAUTH_CLIENT_ID=$REACT_APP_OAUTH_CLIENT_ID
  export CLIENT_ID=$CLIENT_ID

  docker build $API_REPO -t $API:$COMMIT
  docker tag $API:$COMMIT registry.heroku.com/$REPO/$API
  docker push registry.heroku.com/$REPO/$API

  docker build $CLIENT_REPO -t $CLIENT:$COMMIT
  docker tag $CLIENT:$COMMIT registry.heroku.com/$REPO/$CLIENT
  docker push registry.heroku.com/$REPO/$CLIENT

fi