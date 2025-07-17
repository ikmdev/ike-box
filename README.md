# IKE in a Box

This is all the infrastructure needed for running the entire Integrated 
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

## DNS Management

If you haven't created the DNS entries for the domains and subdomains that you want to use, you can do so by following 

the instructions in the [DNS Management](dns-management/easy-dns-domain-registration/Easy-DNS-Mgmt.md) document. This will allow you to create the 

necessary DNS entries for the domains and subdomains that you want to use with this repository.

## Domain Configuration

This project uses a centralized domain configuration approach. All domain names are defined in a single `.env` file at the root of the project. This makes it easy to change the domain name across all services without having to modify multiple files.

### Setting Up Domain Configuration

1. The repository includes a default `.env` file with the following structure:

    ```bash
    # Domain configuration
    BASE_DOMAIN=ikedesigns.com
    WWW_SUBDOMAIN=www.${BASE_DOMAIN}
    NEXUS_SUBDOMAIN=nexus.${BASE_DOMAIN}
    KOMET_SUBDOMAIN=komet.${BASE_DOMAIN}
    IKMDEV_SUBDOMAIN=ikmdev.${BASE_DOMAIN}

    # Combined domain lists for services
    NGINX_DOMAINS="*.${BASE_DOMAIN}"
    CERTBOT_DOMAINS="${BASE_DOMAIN},${WWW_SUBDOMAIN},${NEXUS_SUBDOMAIN},${KOMET_SUBDOMAIN},${IKMDEV_SUBDOMAIN}"

    # Other configuration
    NGINX_PORT=80
    ```

2. To use a different domain, simply edit the `BASE_DOMAIN` value in the `.env` file. All other configurations will automatically use the updated domain.

3. For Terraform-based DNS management, run the provided scripts to generate configuration files from templates:

    ```bash
    # For domain registration
    cd dns-management/aws-domain-registration
    ./generate-tfvars.sh

    # For subdomain records
    cd dns-management/aws-domain-registration/subdomain-records
    ./generate-tfvars.sh
    ```

## Running Locally

Follow the steps below to build and run static website on your local machine:

1. Clone the repository from GitHub to your local machine

2. Change local directory to cloned repo location

3. Enter the following command to execute startup all of the applications:

    ```bash
    docker-compose up -d 
    ```

4. To view the applications directly open your web browser and navigate to: 
* Komet: http://localhost:8080
* Nexus: http://localhost:8081

* ```bash
    docker-compose up -d 
    ```

5. To shut down the applications, run the following command:

    ```bash
    docker-compose down
    ```

The application should now be running in the Docker container using Nginx as Reverse Proxy with the path based routing can be access as:

[localhost/nexus](http://localhost/nexus) and [localhost/komet](http://localhost/komet) in your web browser. If running on a remote server, replace localhost with
the server’s IP address.

Note: On the off chance that you have issues with running on the specific port on your computer, the
docker-compose file is configurable to allow for other ports.  This can be run in the following way, substituting 8080
for whatever port you would like to assign:

```bash
NGINX_PORT=8080 docker compose up -d
```

## Application access credentials
komet - a web application requires login credentials which is defined in users.ini file located at ./komet-data/users.ini

## Running on a Server

This is the complete steps that worked on Amazon linux by deploying a subdomain-based routing solution using Nginx, Docker Compose, and Terraform code on AWS to procure and set up a domain name and all of it’s necessary records for hosting IKE in a Box

## Prerequisites - running on server
 1. DNS setup: Script for DNS setup in AWS or EasyDNS is in directory called  ```bash
 dns-management/
```
2. DNS setup with easy DNS and AWS is automated as part of docker-compose script as well.
4. Domain Registration and DNS Setup with Terraform
   This will register your domain (e.g., ikedesigns.com) and create subdomain records (e.g., nexus.ikedesigns.com, komet.ikedesigns.com, www.ikedesigns.com) pointing to your EC2 instance.
5. Review and Apply the Terraform Plan
6. Verify DNS Records:After Terraform completes, verify your records in the AWS Route 53 console.
It may take a few minutes for DNS propagation.

### Connect to the Instance:
```bash
ssh -i /path/to/your-key.pem ec2-user@<EC2_PUBLIC_IP>
example: ssh -i ~/.ssh/docker-deployment-key.pem ec2-user@18.119.11.183
```
### Update system

```bash
sudo dnf update -y
```
### Install Docker
```bash
sudo dnf install docker -y
```
### Start Docker
```bash
sudo systemctl start docker

```
### Enable Docker to start on boot
```bash
sudo systemctl enable docker
```
### Add your user to the docker group (log out/in after this)
```bash
sudo usermod -aG docker $USER
```

### Install Docker Compose (latest version)
```bash
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

```

### Make Docker Compose executable
```bash
sudo chmod +x /usr/local/bin/docker-compose

```
### Verify installations
```bash
docker --version
docker-compose --version
```

## Deploy Application Services

Clone ike-in-box repository
```bash
git clone https://github.com/ikmdev/ike-box.git

```
## Run Docker Compose with Subdomain Profile
Use Docker Compose profiles to switch between subdomain and path-based routing.

Note: 
* Only one Nginx service should be active at a time to avoid port conflicts.
* Only the nginx-subdomain service is activated when you use the --profile subdomain flag
* You may want to remove the container_name: nginx line or make the names unique if you ever run both at once.
* No conflicting port mappings. (Only one Nginx service should run at a time on the same port.)

### Build and Start Services:
```bash
docker-compose --profile subdomain --build
docker-compose --profile subdomain up -d
```
To shut down the applications for Subdomain Profile, run the following command:

  ```bash
  docker-compose --profile subdomain down
  ```
Check Running Containers:
```bash
docker ps

```
Check Nginx Logs (if troubleshooting):
```bash
docker logs nginx-subdomain

```

### SSL Certificates with Let's Encrypt

This project uses Certbot to automatically obtain and renew SSL certificates from Let's Encrypt for your domains.

#### Certificate Configuration

You should configure the email address used by certbot for Let's Encrypt notifications:

```bash
CERTBOT_EMAIL=your.email@example.com docker compose up -d
```

Or combine multiple environment variables:

```bash
NGINX_PORT=8080 CERTBOT_EMAIL=your.email@example.com docker compose up -d
```

#### Certificate Renewal

Certificates are automatically obtained for all domains specified in the DOMAINS environment variable in the docker-compose.yml file. The certbot service is configured to:

1. Obtain certificates for each domain if they don't exist
2. Check for renewals every 12 hours
3. Automatically renew certificates when they're within 30 days of expiration
4. Persist certificates in the ./certbot/conf directory

No manual intervention is required for certificate renewal as long as the certbot service is running.

### Access application with your Sub-domains

Open your browser and visit:

https://www.ikedesigns.com

https://nexus.ikedesigns.com

https//komet.ikedesigns.com

## Issues and Contributions

Technical and non-technical issues can be reported to the [Issue Tracker](https://github.com/ikmdev/repo-seed/issues).

Contributions can be submitted via pull requests. Please check the [contribution guide](doc/how-to-contribute.md) for more details.
