# Azure Automated Security workshop

Deploy "existing" environment first

```powershell
# enter first step
cd ./01-existing-env
cp terraform.tfvars.sample terraform.tfvars

# review inputs
code terraform.tfvars

# deploy
terraform init
terraform plan
terraform apply
```