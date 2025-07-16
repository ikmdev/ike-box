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

2. Define your base domain `.env` file.  This should be something like "myexample.com". 

### Creating Domains and Subdomains

To create all domains, run the following command:

```bash
docker-compose -f dns-management/easydns-run.yml run dns-management create
```

### Deleting Subdomains

To delete all subdomains, run the following command:

```bash
docker-compose -f dns-management/easydns-run.yml run dns-management delete
```
