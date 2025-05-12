# IKE in a Box

|| This is all the container infrastructure code including docker compose scripts that configures and installs images on the allocated machines.||

### Static Website - 

 repository that builds a static website is managed separtately at ikmdev-site

## Getting Started

Required for running this:

1. install docker
2. docker-compose scripts

## Building and Running

Follow the steps below to build and run static website on your local machine:

1. Clone the repository from GitHub to your local machine

2. Change local directory to cloned repo location

3. Enter the following command to build the application:

Unix/Linux/OSX:

```bash
docker-compose up -d 
docker-compose down
```

Windows:

```bash
docker-compose up -d 
http://localhost:8080
```

## Issues and Contributions
Technical and non-technical issues can be reported to the [Issue Tracker](https://github.com/ikmdev/repo-seed/issues).

Contributions can be submitted via pull requests. Please check the [contribution guide](doc/how-to-contribute.md) for more details.

