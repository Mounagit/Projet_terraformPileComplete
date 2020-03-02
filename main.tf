# création du resource_group

# resource "azurerm_resource_group" "resource_group_project" {
#     name = "${var.nameRG}"
#     location = "${var.location}" 
# }

# # création du Azure Vnet 

# resource "azurerm_virtual_network" "AzureVnet" {
#     name = "${var.nameVnet}" 
#     address_space = [ "10.0.0.0/16" ]
#     location = "${var.location}"
#     resource_group_name = "${azurerm_resource_group.resource_group_project.name}"
    
# }

resource "azurerm_subnet" "subnet_PileComplete" {
    name = "${var.name_subnet}"
    resource_group_name = "${azurerm_resource_group.resource_group_project.name}"
    virtual_network_name = "${azurerm_virtual_network.AzureVnet.name}"
    address_prefix = "10.0.2.0/24"
}

# creation du security group

resource "azurerm_network_security_group" "NSG_PileComplete" {
    name = "${var.name_NSG}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.resource_group_project.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"

    }

    security_rule {

        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"

    }


    security_rule {

        name                       = "HTTPS"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"

    }

      security_rule {

        name                       = "HTTP"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"

    }


}

# creation d'une adresse IP Public

resource "azurerm_public_ip" "IP_PileComplete" {
    name                         = "${var.nameIPpub}"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.resource_group_project.name}"
    allocation_method            = "Static"
    
}

# création d'une carte reseau   

resource "azurerm_network_interface" "NIC_PileComplete" {
    name                      = "${var.nameNIC}"
    location                  = "${var.location}"
    resource_group_name       = "${azurerm_resource_group.resource_group_project.name}"
    network_security_group_id = "${azurerm_network_security_group.NSG_PileComplete.id}"   

    ip_configuration {
        name                          = "${var.nameipconf}"
        subnet_id                     = "${azurerm_subnet.subnet_PileComplete.id}"
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.0.2.5"
        public_ip_address_id          = "${azurerm_public_ip.IP_PileComplete.id}"
    }

}

# création d'une VM

resource "azurerm_virtual_machine" "PileComplete" {

        name                  = "${var.name_PileComplete}"
        location              = "${var.location}"
        resource_group_name   = "${azurerm_resource_group.resource_group_project.name}"
        network_interface_ids = ["${azurerm_network_interface.NIC_PileComplete.id}"]
        vm_size               = "Standard_B1s"

        storage_os_disk {
            name              = "myOsDisk"
            caching           = "ReadWrite"
            create_option     = "FromImage"
            managed_disk_type = "Standard_LRS"

    }
        storage_image_reference {
            publisher = "OpenLogic"
            offer     = "CentOS"
            sku       = "7.6"
            version   = "latest"

        }
        
        os_profile {
            computer_name  = "MounaNekoVM2"
            admin_username = "MounaNeko2"
        }

        os_profile_linux_config {
            disable_password_authentication = true
            ssh_keys {
                path     = "/home/MounaNeko2/.ssh/authorized_keys"
                key_data = "${var.key_data}"

        }

    }
}