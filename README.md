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

This is the complete steps that worked on Amazon linux by deploying a subdomain-based routing solution using Nginx, Docker Compose, and Terraform on AWS to procure and set up a domain name and all of it’s necessary records for hosting IKE in a Box

1. Prerequisites
Terraform is used for domain registration and DNS management (in the dns-management directory).
Docker Compose is used for deploying application services on an EC2 instance.
Docker and Docker Compose (see below)


2. Domain Registration and DNS Setup with Terraform


Navigate to the DNS Management Directory:
 dns-management

Initialize Terraform:
terraform init

Review and Apply the Terraform Plan:

This will register your domain (e.g., ikedesigns.com) and create subdomain records (e.g., nexus.ikedesigns.com, komet.ikedesigns.com, www.ikedesigns.com) pointing to your EC2 instance.

Code ExampleBashterraform plan
terraform apply

Confirm the action when prompted.

Verify DNS Records:

After Terraform completes, verify your records in the AWS Route 53 console.
It may take a few minutes for DNS propagation.

# Connect to the Instance:
Code ExampleBashssh -i /path/to/your-key.pem ec2-user@<EC2_PUBLIC_IP>

# Update system

```bash
sudo dnf update -y
```
 
# Install Docker

sudo dnf install docker -y
 
# Start Docker
sudo systemctl start docker
 
# Enable Docker to start on boot

sudo systemctl enable docker
 
# Add your user to the docker group (log out/in after this)

sudo usermod -aG docker $USER
 
 
# Install Docker Compose (latest version)

DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

 
# Make Docker Compose executable

Plain Text
sudo chmod +x /usr/local/bin/docker-compose
 
# Verify installations

Plain Text
docker --version
docker-compose --version


Deploy Application Services

Install git Clone the repository
[text](https://github.com/ikmdev/ike-box.git)


# Verify installations
Run Docker Compose with Subdomain Profile


# Build and Start Services:
Code ExampleBashcd your-project
docker-compose --profile subdomain up -d --build
docker-compose --profile subdomain up -d

Check Running Containers:
Code ExampleBashdocker ps

Check Nginx Logs (if troubleshooting):
Code ExampleBashdocker logs nginx-subdomain


# Test Your Sub-domain

Open your browser and visit:

http://www.ikedesigns.com
http://nexus.ikedesigns.com
http://komet.ikedesigns.com

## Issues and Contributions

Technical and non-technical issues can be reported to the [Issue Tracker](https://github.com/ikmdev/repo-seed/issues).

Contributions can be submitted via pull requests. Please check the [contribution guide](doc/how-to-contribute.md) for more details.

