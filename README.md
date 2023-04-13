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

# review inputs
cp terraform.tfvars.sample terraform.tfvars
code terraform.tfvars

# deploy
terraform init
terraform plan
terraform apply

```

## Deploy Check Point Cluster to existing network
```powershell
# note that instructions assume POWERSHELL is used

# note that instructions assume POWERSHELL is used

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