#!/bin/sh
#
# Delete a VPC and its dependencies

if [ -z "$1" ] then
    echo "usage: $0 <vpcid>"
    exit 64
fi
vpcid="$1"

# Delete subnets
for i in `aws ec2 describe-subnets --filters Name=vpc-id,Values="${vpcid}" | grep subnet- | sed -E 's/^.*(subnet-[a-z0-9]+).*$/\1/'`; do aws ec2 delete-subnet --subnet-id=$i; done

# Detach internet gateways
for i in `aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values="${vpcid}" | grep igw- | sed -E 's/^.*(igw-[a-z0-9]+).*$/\1/'`; do aws ec2 detach-internet-gateway --internet-gateway-id=$i --vpc-id=vpc-3279eb57; done

# Delete internet gateways
for i in `aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values="${vpcid}" | grep igw- | sed -E 's/^.*(igw-[a-z0-9]+).*$/\1/'`; do aws ec2 delete-internet-gateway --internet-gateway-id=$i; done

# Delete security groups (ignore message about being unable to delete default security group)
for i in `aws ec2 describe-security-groups --filters Name=vpc-id,Values="${vpcid}" | grep sg- | sed -E 's/^.*(sg-[a-z0-9]+).*$/\1/' | sort | uniq`; do aws ec2 delete-security-group --group-id $i; done

# Delete the VPC
aws ec2 delete-vpc --vpc-id ${vpcid}
