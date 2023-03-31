# Azure Automated Security workshop

## Deploy "existing" environment first

```powershell
# note that instructions assume POWERSHELL is used

# enter first step
cd ./01-existing-env
cp terraform.tfvars.sample terraform.tfvars

# review inputs
code terraform.tfvars

# deploy
terraform init
terraform plan
terraform apply

# setup SSH access to U1 VM
# we assume ~/.ssh/config.d exists and ~/.ssh/config has "Include config.d/*.conf" at top
mkdir $env:USERPROFILE/.ssh/config.d
# see setup commands
terraform.exe output -raw  u1_setup_pwsh
# run them
terraform.exe output -raw  u1_setup_pwsh | iex
# profit
ssh u1aas
```

## Deploy Check Point Management Server
```powershell
# note that instructions assume POWERSHELL is used

# enter first step
cd ../02-existing-env
cp terraform.tfvars.sample terraform.tfvars

# review inputs
code terraform.tfvars

# deploy
terraform init
terraform plan
terraform apply

# inspect the command
terraform output -raw mgmt-login-pwsh
# login with password in your clipboard
terraform output -raw mgmt-login-pwsh | iex
```

## Deploy Check Point Cluster to existing network
```powershell
# note that instructions assume POWERSHELL is used

```