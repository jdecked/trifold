<h1 align="center">
  trifold
</h1>
<h4 align="center">
  A Pokémon-inspired protein folding game.
</h4>

<p align="center">
  <a href="https://travis-ci.org/jdecked/trifold">
    <img src="https://img.shields.io/travis/jdecked/trifold.svg?logo=travis&style=popout" alt="Travis.org Build Status">
  </a>
  <a href="https://twitter.com/jdecked">
    <img src="https://img.shields.io/twitter/follow/jdecked.svg?label=&style=popout&logo=twitter&colorA=5d5d5d&logoColor=ffffff" alt="Follow @jdecked on Twitter">
  </a>
</p>


## A Detour For Design
### Color Palette
![Trifold Color Palette](./public/trifold_palette.gif)

### Color Palette Example with Material Design
![Trifold Material Design Demo](./public/trifold_mdc.gif)

## Running Instructions
Assuming you already have both git and yarn installed:
```
$ git clone https://github.com/jdecked/trifold
$ cd trifold
$ yarn install
```

Then, run `HTTPS=true yarn start` to run the client, and `cd server && DATABASE_URL=mysql://root@localhost/trifold gunicorn --certfile=config/ssl/development/localhost-cert.pem --keyfile=config/ssl/development/localhost-key.pem --ca-cert=config/ssl/development/ca-cert.pem wsgi --log-file -` to run the server.

Navigate to `http://localhost:8000` in your browser to see Trifold up and running.

### Creating a production build

To bundle the frontend code for deployment (e.g. on a Heroku server) and run the Django code, use the following commands:
```bash
$ yarn build
$ cd server
$ ./manage.py collectstatic
$ ENVIRONMENT=production DATABASE_URL=mysql://root@localhost/autograder gunicorn --certfile=config/ssl/development/localhost-cert.pem --keyfile=config/ssl/development/localhost-key.pem --ca-cert=config/ssl/development/ca-cert.pem wsgi --log-file -
```