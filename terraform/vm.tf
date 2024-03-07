resource "azurerm_virtual_network" "vnet" {
  name                = "my-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "snap-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.vnic.id]
  size                  = "Standard_D2s_v5"
  admin_username        = "benhu"


  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS"
    version   = "latest"
  }

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_size_gb           = 512
    disk_encryption_set_id = azurerm_disk_encryption_set.des.id
  }


  admin_ssh_key {
    username   = "benhu"
    public_key = file("~/.ssh/id_rsa.pub")
  }

}

resource "azurerm_disk_encryption_set" "des" {
  name                = "bhfuncsnapdes"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  key_vault_key_id = azurerm_key_vault_key.vmkey.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_network_interface" "vnic" {
  name                = "bhfuncsnapnic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "my-nic-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

