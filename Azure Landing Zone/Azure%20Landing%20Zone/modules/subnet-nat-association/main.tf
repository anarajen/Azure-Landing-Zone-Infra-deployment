variable "subnet_id" {
  type = string
}
variable "nat_gateway_id" {
  type = string
}
resource "azurerm_subnet_nat_gateway_association" "this" {
  subnet_id      = var.subnet_id
  nat_gateway_id = var.nat_gateway_id
}
