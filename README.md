# IKE in a Box

This is all of the infrastructure needed for running the entire Integrated 
Knowledge Environment. 

This will include the following:

* sonatype nexus - a repository manager for maven artifacts
* posgresql database - a database for nexus
* ike website - a static website that is built from the ikmdev repo at 
* [ikmdev/ikmdev-site](https://github.com/ikmdev/ikmdev-site)
* komet - a web application for managing knowledge artifacts, which can be found at 
[ikmdev/komet](https://github.com/ikmdev/komet)

## Disclaimer

This repository is for demonstration purposes only. It is not intended for production use. Please consult 
security professionals before using these products in a production environment.  In general, it is suggested
that you use hardened images or equivalent organizational systems for production use.  This repository is not 
intended to contain hardened images.

## Prerequisites

* Install [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/)
  (or something compatible, such as on your local machine.

## Running Locally

Follow the steps below to build and run static website on your local machine:

1. Clone the repository from GitHub to your local machine

2. Change local directory to cloned repo location

3. Enter the following command to execute startup all of the applications:

  ```bash
  docker-compose up -d 
  ```

4. To view the applications directly open your web browser and navigate to: http://localhost


5. To shut down the applications, run the following command:

  ```bash
  docker-compose down
  ```

The application should now be running in the Docker container using Nginx as Reverse Proxy with the path based routing can be access as:

[localhost/nexus](http://localhost/nexus) and [localhost/komet](http://localhost/komet) in your web browser.

## Application access credentials
komet - a web application requires login credentials which is defined in users.ini file located at ./komet-data/users.ini

Note: On the off chance that you have issues with running on the specific port on your computer, the
docker-compose file is configurable to allow for other ports.  This can be run in the following way, substituting 8080
for whatever port you would like to assign:

```bash
NGINX_PORT=8080 docker compose up -d
```

## Running on a Server

To be updated soon!

## Issues and Contributions

Technical and non-technical issues can be reported to the [Issue Tracker](https://github.com/ikmdev/repo-seed/issues).

Contributions can be submitted via pull requests. Please check the [contribution guide](doc/how-to-contribute.md) for more details.

