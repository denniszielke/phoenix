variable "subscription_id" {
    default = ""
}

variable "tenant_id" {
    default = ""
}

variable "terraform_client_id" {
    default = ""
}

variable "terraform_client_secret" {
    default = ""
}

variable "client_id" {
    default = ""
}

variable "client_secret" {
    default = ""
}

variable "environment" {
    default = "stg"
}

variable "agent_count" {
    default = 3
}

variable "kubernetes_version" {
    default = "1.10.9"
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
    default = ""
}

variable "cluster_name" {
    default = ""
}

variable "resource_group_name" {
    default = ""
}

variable "location" {
    default = "WestEurope"
}