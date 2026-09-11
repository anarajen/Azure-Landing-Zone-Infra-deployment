variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "public_ip_address_id" {
  type = string
}
variable "sku" {
  type = string
  default = "Basic"
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_bastion_host" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  tags                = var.tags
  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = var.public_ip_address_id
  }
}
output "id" {
  value = azurerm_bastion_host.this.id
}
