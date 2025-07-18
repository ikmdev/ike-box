#!/usr/bin/env python3
"""
Script to delete domains and subdomains in easyDNS.

This script reads a predefined text file with domain/subdomain information and deletes
the specified subdomains in easyDNS using their API. It will not fail if a subdomain
doesn't exist.

Usage:
    python delete_domains.py [--config CONFIG_FILE] [--domains DOMAINS_FILE] [SUBDOMAIN...]

Arguments:
    --config CONFIG_FILE    Path to the configuration file with easyDNS API credentials
                           (default: config.json)
    --domains DOMAINS_FILE  Path to the file containing domain/subdomain information
                           (default: domains.txt)
    SUBDOMAIN...            Optional list of specific subdomains to delete
                           (if not provided, all subdomains will be deleted)

Example:
    python delete_domains.py                      # Delete all subdomains
    python delete_domains.py dev test staging     # Delete only dev, test, and staging subdomains
"""

import argparse
import json
import os
import sys
import requests
import logging
from typing import List, Dict, Any, Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('delete_domains')

class EasyDNSClient:
    """Client for interacting with the easyDNS API."""
    
    def __init__(self, api_key: str, api_secret: str, endpoint: str = "https://rest.easydns.net"):
        """
        Initialize the easyDNS API client.
        
        Args:
            api_key: The easyDNS API key
            api_secret: The easyDNS API secret
            endpoint: The easyDNS API endpoint URL
        """
        self.api_key = api_key
        self.api_secret = api_secret
        self.endpoint = endpoint
        self.session = requests.Session()
        self.session.auth = (api_key, api_secret)
        self.session.headers.update({
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        })
    
    def get_records(self, domain: str) -> List[Dict[str, Any]]:
        """
        Get all DNS records for a domain.
        
        Args:
            domain: The domain name
            
        Returns:
            List of DNS records
        """
        url = f"{self.endpoint}/domains/{domain}/records"
        logger.info(f"Getting records for domain: {domain}")
        
        try:
            response = self.session.get(url)
            response.raise_for_status()
            data = response.json()
            return data.get("data", [])
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to get records for domain {domain}: {str(e)}")
            if hasattr(e, 'response') and e.response is not None:
                logger.error(f"Response: {e.response.text}")
            return []
    
    def delete_record(self, domain: str, record_id: str) -> Dict[str, Any]:
        """
        Delete a DNS record.
        
        Args:
            domain: The domain name
            record_id: The record ID to delete
            
        Returns:
            The API response as a dictionary
        """
        url = f"{self.endpoint}/domains/{domain}/records/{record_id}"
        logger.info(f"Deleting record {record_id} from domain {domain}")
        
        try:
            response = self.session.delete(url)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to delete record {record_id} from domain {domain}: {str(e)}")
            if hasattr(e, 'response') and e.response is not None:
                logger.error(f"Response: {e.response.text}")
            return {"error": str(e)}
    
    def delete_subdomain(self, domain: str, subdomain: str) -> bool:
        """
        Delete a subdomain by finding and deleting its DNS records.
        
        Args:
            domain: The parent domain name
            subdomain: The subdomain name (without the parent domain)
            
        Returns:
            True if successful, False otherwise
        """
        full_name = f"{subdomain}.{domain}" if subdomain else domain
        logger.info(f"Deleting subdomain: {full_name}")
        
        # Get all records for the domain
        records = self.get_records(domain)
        
        # Find records for the subdomain
        subdomain_records = [
            record for record in records
            if record.get("host") == subdomain
        ]
        
        if not subdomain_records:
            logger.warning(f"No records found for subdomain {full_name}")
            return True  # Not failing if subdomain doesn't exist
        
        # Delete each record
        success = True
        for record in subdomain_records:
            record_id = record.get("id")
            if record_id:
                result = self.delete_record(domain, record_id)
                if "error" in result:
                    success = False
        
        return success

def load_config(config_file: str) -> Dict[str, Any]:
    """
    Load configuration from a JSON file.
    
    Args:
        config_file: Path to the configuration file
        
    Returns:
        Configuration as a dictionary
    """
    try:
        with open(config_file, 'r') as f:
            return json.load(f)
    except (json.JSONDecodeError, FileNotFoundError) as e:
        logger.error(f"Failed to load config file {config_file}: {str(e)}")
        sys.exit(1)

def parse_domains_file(domains_file: str) -> List[Dict[str, Any]]:
    """
    Parse the domains file to extract domain and subdomain information.
    
    The file format should be:
    domain.com
        subdomain1
        subdomain2
    domain2.com
        subdomain3
        subdomain4
    
    Args:
        domains_file: Path to the domains file
        
    Returns:
        List of dictionaries with domain and subdomain information
    """
    domains = []
    current_domain = None
    
    try:
        with open(domains_file, 'r') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                
                if not line.startswith(' ') and not line.startswith('\t'):
                    # This is a domain
                    current_domain = {
                        "name": line,
                        "subdomains": []
                    }
                    domains.append(current_domain)
                elif current_domain is not None:
                    # This is a subdomain
                    subdomain = line.strip()
                    current_domain["subdomains"].append(subdomain)
    except FileNotFoundError:
        logger.error(f"Domains file not found: {domains_file}")
        sys.exit(1)
    
    return domains

def main():
    """Main function to delete subdomains."""
    parser = argparse.ArgumentParser(description="Delete subdomains in easyDNS")
    parser.add_argument("--config", default="config.json", help="Path to the configuration file")
    parser.add_argument("--domains", default="domains.txt", help="Path to the domains file")
    parser.add_argument("subdomains", nargs="*", help="Optional list of specific subdomains to delete")
    
    args = parser.parse_args()
    
    # Load configuration
    config = load_config(args.config)
    
    # Create easyDNS client
    client = EasyDNSClient(
        api_key=config.get("api_key"),
        api_secret=config.get("api_secret"),
        endpoint=config.get("endpoint", "https://rest.easydns.net")
    )
    
    # Parse domains file
    domains = parse_domains_file(args.domains)
    

    # Get ACME challenge value from env
    acme_challenge = os.getenv("ACME_CHALLENGE", "")

    # Delete subdomains
    for domain_info in domains:
        domain_name = domain_info["name"]

        for subdomain in domain_info["subdomains"]:
            # If specific subdomains were provided, only delete those
            if args.subdomains and subdomain not in args.subdomains:
                continue
            client.delete_subdomain(domain_name, subdomain)

        # Delete ACME challenge TXT record if value is set
        if acme_challenge:
            logger.info(f"Deleting ACME challenge TXT record for {domain_name}")
            # Find and delete TXT record for _acme-challenge
            records = client.get_records(domain_name)
            for record in records:
                if record.get("host") == "_acme-challenge" and record.get("type") == "TXT":
                    client.delete_record(domain_name, record.get("id"))

if __name__ == "__main__":
    main()