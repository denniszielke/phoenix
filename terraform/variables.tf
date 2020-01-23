# Guid of your azure subscription
variable "subscription_id" {
    default = ""
}

# Directory id of your azure ad account
variable "tenant_id" {
    default = ""
}

# # Terraform client id
# variable "terraform_client_id" {
#     default = ""
# }

# # Terraform client secret
# variable "terraform_client_secret" {
#     default = ""
# }

# Kubernetes service principal id
variable "client_id" {
    default = ""
}

# Kubernetes service principal secret
variable "client_secret" {
    default = ""
}

# Name your environment
variable "environment" {
    default = "dennis"
}

# Number of agents
variable "agent_count" {
    default = 3
}

# Kubernetes Version
variable "kubernetes_version" {
    default = "1.15.7"
}

# Public key
variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

# Your dns prefix
variable "dns_prefix" {
    default = ""
}

# Your cluster name
variable "cluster_name" {
    default = ""
}

# Kubernetes Resource group
variable "resource_group_name" {
    default = ""
}

# Deployment location
variable "location" {
    default = "WestEurope"
}