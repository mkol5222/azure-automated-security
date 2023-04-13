# Azure Automated Security workshop

## Deploy "existing" environment first

```bash
# note that instructions assume BASH is used, tested in WSL2 env

# enter first step
cd ./01-existing-env

# review inputs based on sample
cp terraform.tfvars.sample terraform.tfvars
code terraform.tfvars

# deploy
terraform init
terraform plan
terraform apply

# setup SSH access to U1 VM
#   we are adding ~/.ssh/config.d and modify  ~/.ssh/config with "Include config.d/*.conf"

# review
terraform output -raw  u1_setup_bash
# and run later
terraform output -raw  u1_setup_bash | bash
# test connection to Linux machine
ssh u1aas

# remember to remove your labs, once you stop using them (in every terraform infra folder)
terraform destroy
```

## Deploy Check Point Management Server
```bash
# note that instructions assume BASH is used, tested in WSL2 env

# enter second step - Management server deployment
cd ../02-cp-management

# check existing VNET env
VNET_RG="rg-spring-demo"
VNET_NAME="vnet-spring-demo"
MGMT_SUBNET="net-mgmt"
az network vnet subnet list -g $VNET_RG --vnet-name $VNET_NAME -o table
# look for "net-mgmt" address - e.g. 10.42.99.0/24
az network vnet subnet list-available-ips --name $MGMT_SUBNET -g $VNET_RG --vnet-name $VNET_NAME -o table
# can be used for subnet_1st_Address var

# review inputs
cp terraform.tfvars.sample terraform.tfvars
code terraform.tfvars

# deploy
terraform init
terraform plan
terraform apply

# this is how to login to Management
# review - notice password is stored to clipboard for easy login
#   VM initialization TAKES TIME
terraform output -raw mgmt-login-bash; echo 
```

## Deploy Check Point Cluster to existing network
```bash


# enter second step - Management server deployment
cd ../03-cp-cluster
cp terraform.tfvars.sample terraform.tfvars

# review inputs
code terraform.tfvars

# deploy
terraform init
terraform plan
terraform apply

# inspect the command to create cluster in Management Server
terraform output -raw mgmt-commands
# copy command for server to clipboard
terraform output -raw mgmt-commands | clip.exe

# this is how to visit server again (in other terminal tab)
cd ../02-cp-management/
#  for Linux/WSL env
terraform output -raw  mgmt-login-bash
terraform output -raw  mgmt-login-bash | bash
```