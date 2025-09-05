#!/bin/bash

set -euo pipefail

ASG_NAME="$1"

if [ -z "$ASG_NAME" ]; then
  echo "Usage: $0 <autoscaling-group-name>"
  exit 1
fi

echo "Looking for non-spot instance in ASG: $ASG_NAME..."

# Find a non-spot instance in the ASG
INSTANCE_ID=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "$ASG_NAME" \
  --query 'AutoScalingGroups[0].Instances[?LifecycleState==`InService` && InstanceLifecycle!=`spot`].InstanceId' \
  --output text | tr '\t' '\n' | head -n1)

if [ -z "$INSTANCE_ID" ]; then
  echo "No non-spot instances found in ASG: $ASG_NAME"
  exit 1
fi

echo "Found non-spot instance: $INSTANCE_ID"

# Detach the instance (do NOT decrement desired capacity — this allows replacement)
aws autoscaling detach-instances \
  --instance-ids "$INSTANCE_ID" \
  --auto-scaling-group-name "$ASG_NAME" \
  --no-should-decrement-desired-capacity

echo "Detaching instance $INSTANCE_ID from ASG (ASG will launch a replacement)..."

# Wait until the instance is no longer in the ASG
while true; do
  IN_ASG=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$ASG_NAME" \
    --query "AutoScalingGroups[0].Instances[?InstanceId=='$INSTANCE_ID']" \
    --output text)

  if [ -z "$IN_ASG" ]; then
    break
  fi

  echo "Waiting for instance to be detached..."
  sleep 5
done

# Get private IP of the instance
PRIVATE_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' \
  --output text)

echo "Instance $INSTANCE_ID detached. Private IP: $PRIVATE_IP"