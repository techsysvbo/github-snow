#!/usr/bin/env python3
"""
FIPS Compliance Inventory Script for Working AWS Config Setup
Run this from your local machine or CloudShell
"""

import boto3
import json
from datetime import datetime

# Configuration
AGGREGATOR_NAME = "FipsTestAggregator"
REGION = "us-east-1"

def get_fips_inventory():
    """Query Config Aggregator for all resources relevant to FIPS compliance"""
    
    config_client = boto3.client('config', region_name=REGION)
    
    # Query for resources that need FIPS compliance checking
    query = """
    SELECT
        accountId,
        awsRegion,
        resourceType,
        resourceId,
        resourceName,
        configuration
    WHERE resourceType IN (
        'AWS::ApiGateway::RestApi',
        'AWS::S3::Bucket',
        'AWS::Lambda::Function',
        'AWS::ElasticLoadBalancingV2::LoadBalancer',
        'AWS::Redshift::ClusterParameterGroup'
    )
    """
    
    all_resources = []
    
    try:
        response = config_client.select_aggregate_resource_config(
            Expression=query,
            ConfigurationAggregatorName=AGGREGATOR_NAME,
            Limit=100
        )
        
        for item in response.get('Results', []):
            all_resources.append(json.loads(item))
            
        print(f"✅ Found {len(all_resources)} resources to analyze")
        return all_resources
        
    except Exception as e:
        print(f"❌ Query failed: {e}")
        return []

def check_fips_compliance(resource):
    """Determine FIPS compliance status for each resource"""
    
    resource_type = resource.get('resourceType')
    resource_id = resource.get('resourceId')
    account_id = resource.get('accountId')
    region = resource.get('awsRegion')
    
    config_data = resource.get('configuration', {})
    if isinstance(config_data, str):
        try:
            config_data = json.loads(config_data)
        except:
            config_data = {}
    
    # API Gateway Check
    if resource_type == 'AWS::ApiGateway::RestApi':
        endpoint_config = config_data.get('endpointConfiguration', {})
        api_types = endpoint_config.get('types', [])
        
        if 'EDGE' in api_types:
            return {
                "status": "NON_COMPLIANT",
                "reason": "Edge-optimized endpoint does NOT support FIPS",
                "remediation": "Change to REGIONAL endpoint type",
                "fips_version": "NONE"
            }
        elif 'REGIONAL' in api_types:
            return {
                "status": "REQUIRES_VERIFICATION",
                "reason": "Regional endpoint supports FIPS but needs client-side configuration",
                "remediation": "Set AWS_USE_FIPS_ENDPOINT=true in all API clients",
                "fips_version": "140-2 (until client config is set)"
            }
    
    # S3 Bucket Check
    elif resource_type == 'AWS::S3::Bucket':
        return {
            "status": "VERIFICATION_NEEDED",
            "reason": "S3 FIPS compliance depends entirely on client SDK configuration",
            "remediation": "Run: export AWS_USE_FIPS_ENDPOINT=true in all environments",
            "fips_version": "140-2 (client-dependent)"
        }
    
    # Lambda Functions
    elif resource_type == 'AWS::Lambda::Function':
        runtime = config_data.get('runtime', 'unknown')
        return {
            "status": "REQUIRES_CONFIGURATION",
            "reason": "Lambda needs environment variable AWS_USE_FIPS_ENDPOINT=true",
            "remediation": f"Update Lambda {resource_id} with FIPS env var",
            "fips_version": "140-2 (requires config)"
        }
    
    # Default for other resources
    else:
        return {
            "status": "REVIEW_REQUIRED",
            "reason": f"Check AWS documentation for {resource_type} FIPS support",
            "remediation": "Consult AWS FIPS endpoint list for this service",
            "fips_version": "UNKNOWN"
        }

def main():
    print("🔍 AWS FIPS Compliance Inventory")
    print("=" * 50)
    print(f"Aggregator: {AGGREGATOR_NAME}")
    print(f"Region: {REGION}\n")
    
    # Get resources
    resources = get_fips_inventory()
    
    if not resources:
        print("\n⚠️  No resources found. Make sure:")
        print("   1. Config has been recording for at least 5 minutes")
        print("   2. You have resources of the types being queried")
        return
    
    # Analyze each resource
    report = {
        "scan_time": str(datetime.utcnow()),
        "non_compliant": [],
        "verification_needed": [],
        "compliant": []
    }
    
    print("\n📊 Analyzing FIPS compliance...\n")
    
    for resource in resources:
        result = check_fips_compliance(resource)
        
        entry = {
            "account": resource.get('accountId'),
            "region": resource.get('awsRegion'),
            "type": resource.get('resourceType'),
            "id": resource.get('resourceId'),
            "name": resource.get('resourceName', 'N/A'),
            "status": result['status'],
            "reason": result['reason'],
            "remediation": result['remediation'],
            "fips_version": result['fips_version']
        }
        
        if result['status'] == "NON_COMPLIANT":
            report['non_compliant'].append(entry)
            print(f"❌ {resource['resourceType']}: {entry['name']} - NON_COMPLIANT")
            print(f"   {result['reason']}")
        elif result['status'] in ["REQUIRES_VERIFICATION", "VERIFICATION_NEEDED", "REQUIRES_CONFIGURATION"]:
            report['verification_needed'].append(entry)
            print(f"⚠️  {resource['resourceType']}: {entry['name']} - Needs Configuration")
        else:
            report['compliant'].append(entry)
            print(f"✅ {resource['resourceType']}: {entry['name']} - Review Required")
    
    # Print Summary
    print("\n" + "=" * 50)
    print("📊 SUMMARY")
    print("=" * 50)
    print(f"Total Resources Analyzed: {len(resources)}")
    print(f"❌ Non-Compliant: {len(report['non_compliant'])}")
    print(f"⚠️  Need Verification: {len(report['verification_needed'])}")
    print(f"✅ Compliant/Review: {len(report['compliant'])}")
    
    # Save full report
    with open('fips_inventory_report.json', 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"\n💾 Full report saved to: fips_inventory_report.json")
    
    # Show non-compliant items
    if report['non_compliant']:
        print("\n🚨 NON-COMPLIANT RESOURCES TO FIX:")
        for item in report['non_compliant']:
            print(f"   - {item['type']}: {item['name']}")
            print(f"     Fix: {item['remediation']}\n")

if __name__ == "__main__":
    main()
