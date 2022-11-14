#!/bin/bash
#******************************************************************************
#    AWS VPC Creation Shell Script
#******************************************************************************
#
# 
#    Automates the creation of a custom  VPC having  public subnet , and internet gateway, and route table.
#
#
#==============================================================================
# vpc and subnet attributes
#===============================================================================
AWS_REGION=$(yq e '.attributes.AZ' vpc.yml)
VPC_NAME=$(yq e '.attributes.name' vpc.yml)
VPC_CIDR=$(yq e '.attributes.CIDR' vpc.yml)
SUBNET_PUBLIC_CIDR=$(yq e '.attributes.CIDR' vpc-batch16-pub-sn-aza.yaml)
SUBNET_PUBLIC_AZ=$(yq e '.attributes.AZ' vpc-batch16-pub-sn-aza.yaml)
SUBNET_PUBLIC_NAME=$(yq e '.attributes.name' vpc-batch16-pub-sn-aza.yaml)
#=================================================================================
#   DO NOT MODIFY CODE BELOW
#=================================================================================




#==================================================================================
# Create VPC
#===================================================================================
echo "Creating VPC in preferred region..."
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --query 'Vpc.{VpcId:VpcId}' \
  --output text \
  --region $AWS_REGION)
echo "  VPC ID '$VPC_ID' CREATED in '$AWS_REGION' region." >> output_variable.property
#======================================================================================
# Add Name tag to VPC
#=======================================================================================
aws ec2 create-tags \
  --resources $VPC_ID \
  --tags "Key=Name,Value=$VPC_NAME" \
  --region $AWS_REGION
echo "  VPC ID '$VPC_ID' NAMED as '$VPC_NAME'." >> output_variable.property
#=======================================================================================
# Create Public Subnet
#=======================================================================================
echo "Creating Public Subnet..."
SUBNET_PUBLIC_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PUBLIC_CIDR \
  --availability-zone $SUBNET_PUBLIC_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)
echo "  Subnet ID '$SUBNET_PUBLIC_ID' CREATED in '$SUBNET_PUBLIC_AZ'" \
  "Availability Zone."  >> output_variable.property


aws ec2 create-tags \
  --resources $SUBNET_PUBLIC_ID \
  --tags "Key=Name,Value=$SUBNET_PUBLIC_NAME" \
  --region $AWS_REGION
echo "  Subnet ID '$SUBNET_PUBLIC_ID' NAMED as" \
  "'$SUBNET_PUBLIC_NAME'."  >> output_variable.property

#============================================================================================
# Create Internet gateway
#============================================================================================
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
  --output text \
  --region $AWS_REGION)
echo "  Internet Gateway ID '$IGW_ID' CREATED." >> output_variable.property

#==============================================================================================
# Attach Internet gateway to your VPC
#==============================================================================================
aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $IGW_ID \
  --region $AWS_REGION
echo "  Internet Gateway ID '$IGW_ID' ATTACHED to VPC ID '$VPC_ID'." >> output_variable.property

#=============================================================================================
# Create Route Table
#============================================================================================
echo "Creating Route Table..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.{RouteTableId:RouteTableId}' \
  --output text \
  --region $AWS_REGION)
echo "  Route Table ID '$ROUTE_TABLE_ID' CREATED." >> output_variable.property


#=============================================================================================
# Create route to Internet Gateway
#============================================================================================
RESULT=$(aws ec2 create-route \
  --route-table-id $ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID \
  --region $AWS_REGION)
echo "  Route to '0.0.0.0/0' via Internet Gateway ID '$IGW_ID' ADDED to" \
  "Route Table ID '$ROUTE_TABLE_ID'." >> output_variable.property


# Associate Public Subnet with Route Table
RESULT=$(aws ec2 associate-route-table  \
  --subnet-id $SUBNET_PUBLIC_ID \
  --route-table-id $ROUTE_TABLE_ID \
  --region $AWS_REGION)
echo "  Public Subnet ID '$SUBNET_PUBLIC_ID' ASSOCIATED with Route Table ID" \
  "'$ROUTE_TABLE_ID'." >> output_variable.property






echo "COMPLETED"
