#!/usr/bin/env python3
"""
Script to create domains and subdomains in easyDNS.

This script reads a predefined text file with domain/subdomain information and creates
them in easyDNS using their API. By default, it creates all domains and subdomains
specified in the file, but it can also create a subset of subdomains if specified
as command-line arguments.

Usage:
    python create_domains.py [--config CONFIG_FILE] [--domains DOMAINS_FILE] [SUBDOMAIN...]

Arguments:
    --config CONFIG_FILE    Path to the configuration file with easyDNS API credentials
                           (default: config.json)
    --domains DOMAINS_FILE  Path to the file containing domain/subdomain information
                           (default: domains.txt)
    SUBDOMAIN...            Optional list of specific subdomains to create
                           (if not provided, all subdomains will be created)

Example:
    python create_domains.py                      # Create all domains/subdomains
    python create_domains.py dev test staging     # Create only dev, test, and staging subdomains
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
logger = logging.getLogger('create_domains')

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
    
    def create_domain(self, domain: str) -> Dict[str, Any]:
        """
        Create a new domain in easyDNS.
        
        Args:
            domain: The domain name to create
            
        Returns:
            The API response as a dictionary
        """
        url = f"{self.endpoint}/domains/add/{domain}"
        logger.info(f"Creating domain: {domain}")
        
        try:
            response = self.session.put(url, json={})
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to create domain {domain}: {str(e)}")
            if hasattr(e, 'response') and e.response is not None:
                logger.error(f"Response: {e.response.text}")
            return {"error": str(e)}
    
    def create_subdomain(self, domain: str, subdomain: str, record_type: str = "A", 
                         ttl: int = 3600, content: str = "127.0.0.1") -> Dict[str, Any]:
        """
        Create a new subdomain (DNS record) in easyDNS.
        
        Args:
            domain: The parent domain name
            subdomain: The subdomain name (without the parent domain)
            record_type: The DNS record type (default: A)
            ttl: Time to live in seconds (default: 3600)
            content: The record content/value (default: 127.0.0.1)
            
        Returns:
            The API response as a dictionary
        """
        url = f"{self.endpoint}/domains/{domain}/records"
        full_name = f"{subdomain}.{domain}" if subdomain else domain
        
        data = {
            "domain": domain,
            "name": subdomain,
            "type": record_type,
            "ttl": ttl,
            "prio": 0,
            "content": content
        }
        
        logger.info(f"Creating subdomain: {full_name}")
        
        try:
            response = self.session.post(url, json=data)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to create subdomain {full_name}: {str(e)}")
            if hasattr(e, 'response') and e.response is not None:
                logger.error(f"Response: {e.response.text}")
            return {"error": str(e)}

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
    """Main function to create domains and subdomains."""
    parser = argparse.ArgumentParser(description="Create domains and subdomains in easyDNS")
    parser.add_argument("--config", default="config.json", help="Path to the configuration file")
    parser.add_argument("--domains", default="domains.txt", help="Path to the domains file")
    parser.add_argument("subdomains", nargs="*", help="Optional list of specific subdomains to create")
    
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
    
    # Create domains and subdomains
    for domain_info in domains:
        domain_name = domain_info["name"]
        
        # Create the domain
        result = client.create_domain(domain_name)
        if "error" in result:
            logger.warning(f"Could not create domain {domain_name}, it may already exist or there was an error")
        
        # Create subdomains
        for subdomain in domain_info["subdomains"]:
            # If specific subdomains were provided, only create those
            if args.subdomains and subdomain not in args.subdomains:
                continue
            
            result = client.create_subdomain(domain_name, subdomain)
            if "error" in result:
                logger.warning(f"Could not create subdomain {subdomain}.{domain_name}, it may already exist or there was an error")

if __name__ == "__main__":
    main()