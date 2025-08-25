import boto3
import json

def lambda_handler(event, context):
    ecs = boto3.client("ecs", region_name="ap-southeast-2")
    elbv2 = boto3.client("elbv2", region_name="ap-southeast-2")

    cluster_name = "cloud-android-cluster"
    service_name = "cloud-android-web"

    service = ecs.describe_services(cluster=cluster_name, services=[service_name])["services"][0]
    lb_name = service["loadBalancers"][0]["loadBalancerName"]

    lb = elbv2.describe_load_balancers(Names=[lb_name])["LoadBalancers"][0]
    dns = f"http://{lb['DNSName']}:6080"

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"url": dns})
    }
