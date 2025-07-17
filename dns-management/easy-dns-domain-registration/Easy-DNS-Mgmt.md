## DNS Management with easyDNS

The repository includes scripts for managing domains and subdomains in easyDNS. These scripts can be run in a Docker 
container.

### Configuration

1. Update the `dns-management/config.json` file with your easyDNS API credentials:

```json
{
  "api_key": "your_easydns_api_key",
  "api_secret": "your_easydns_api_secret",
  "endpoint": "https://rest.easydns.net"
}
```

2. Define your domains and subdomains in the `dns-management/domains.txt` file.  This file is structured in such
a way that the subdomains are predefined as is needed, however it is flexible enough to create whatever
you need.  The file should look like this:

```
example.com
    www
    nexus
    gitea
 
another-example.org
    komet
```

### Creating Domains and Subdomains

To create all domains and subdomains defined in the domains.txt file:

```bash
docker-compose -f dns-management/mgmt.yml run dns-management create
```

To create only specific subdomains:

```bash
docker-compose -f dns-management/mgmt.yml run dns-management create dev test staging
```

### Deleting Subdomains

To delete all subdomains defined in the domains.txt file:

```bash
docker-compose -f dns-management/mgmt.yml run dns-management delete
```

To delete only specific subdomains:

```bash
docker-compose -f dns-management/mgmt.yml run dns-management delete dev test staging
```

### Running Scripts Directly

You can also run the scripts directly if you have Python installed:

```bash
cd dns-management
python create_domains.py [--config CONFIG_FILE] [--domains DOMAINS_FILE] [SUBDOMAIN...]
python delete_domains.py [--config CONFIG_FILE] [--domains DOMAINS_FILE] [SUBDOMAIN...]
```
