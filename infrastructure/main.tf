module "resource_group" {
  source   = "git::https://github.com/mosesugwu/terraform-projects.git//Modules/resource-group?ref=v1.0.0"
  location = "westus"
  tags = {
    CompanyName = "Moses Dev"
    Provider    = "Azure Cloud"
    ManagedWith = "Terraform"
    Casecode    = "moses2024"
  }

}

module "virtual_network" {
  source              = "git::https://github.com/mosesugwu/terraform-projects.git//Modules/virtual-network?ref=v1.1.0"
  vnet_address_space  = ["10.1.0.0/16"]
  resource_group_name = module.resource_group.rg_name
  location            = module.resource_group.rg_location

}

module "subnet" {
  source                = "git::https://github.com/mosesugwu/terraform-projects.git//Modules/subnet?ref=v1.0.0"
  snet_address_prefixes = ["10.1.0.0/24"]
  resource_group_name   = module.resource_group.rg_name
  location              = module.resource_group.rg_location
  public_ip_address_id  = module.virtual_network.pip_id
  virtual_network_name  = module.virtual_network.vnet_name

}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each            = local.virtual_machines
  name                = each.value.name
  resource_group_name = module.resource_group.rg_name
  location            = module.resource_group.rg_location
  size                = each.value.size
  admin_username      = each.value.admin_username
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
  ]

  admin_ssh_key {
    username   = each.value.username
    public_key = each.value.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }


}

resource "azurerm_network_interface" "nic" {
  for_each            = local.network_interface_ids
  name                = each.value.name
  location            = module.resource_group.rg_location
  resource_group_name = module.resource_group.rg_name

  ip_configuration {
    name                          = each.key
    subnet_id                     = module.subnet.snet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.value.public_ip_address_id
  }
}

resource "azurerm_public_ip" "vm_2" {
  name                = "vm2PublicIP"
  resource_group_name = module.resource_group.rg_name
  location            = module.resource_group.rg_location
  allocation_method   = "Static"

}

# resource "azurerm_public_ip" "vm_3" {
#   name                = "vm3PublicIP"
#   resource_group_name = module.resource_group.rg_name
#   location            = module.resource_group.rg_location
#   allocation_method   = "Static"

# }