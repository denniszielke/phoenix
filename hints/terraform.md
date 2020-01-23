# Use terraform to deploy all resources


1. Create a sp for terraform
You need a service principal for Kubernetes to use - if you do not have, use the following command to creat one:

```
az ad sp create-for-rbac --role="Contributor" --name "kubernetes_sp"
```

1. prepare terraform execution

navigate to the terraform folder and ensure that all variables have been correctly configured in `variables.tf`
```
cd terraform
```

initialize the terraform state storage account
```
terraform init
```

1. create an execution plan and execute it
```
terraform plan -out out.plan
```

apply the execution plan
```
terraform apply out.plan
```