
resource "local_file" "host_file" {
  content              = <<-EOT
---
all:
  children:
    servers:
      children:
        local:
          children:
            ubuntu:
              children:
                application:
                  hosts:
                    app-server-1:
                      ansible_host: ${aws_instance.server_1.public_ip}
                      ansible_user :  ubuntu
                      ansible_ssh_common_args: '-o IdentityFile=${var.keypair_filename}.pem -o StrictHostKeyChecking=no'

                    app-server-2:
                      ansible_host: ${aws_instance.server_2.public_ip}
                      ansible_user :  ubuntu
                      ansible_ssh_common_args: '-o IdentityFile=${var.keypair_filename}.pem -o StrictHostKeyChecking=no'

                database:
                  hosts:
                    db-server:
                      ansible_host: ${aws_instance.database_server.private_ip}
                      ansible_user :  ubuntu
                      ansible_port :  2200
                      ansible_ssh_common_args: '-o IdentityFile=${var.keypair_filename}.pem -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i ${var.keypair_filename}.pem ubuntu@18.130.83.54 -p 2200 -W %h:%p"'

                bastion:
                  hosts:
                    bastion-server:
                      ansible_host: ${aws_instance.bastion_host.public_ip}
                      ansible_user :  ubuntu
                      ansible_port: 2200
                      ansible_ssh_common_args: '-o IdentityFile=${var.keypair_filename}.pem -o StrictHostKeyChecking=no'

                monitoring:
                  hosts:
                    monitoring-server:
                      ansible_host: ${aws_instance.monitoring_server.public_ip}
                      ansible_user :  ubuntu
                      ansible_ssh_common_args: '-o IdentityFile=${var.keypair_filename}.pem -o StrictHostKeyChecking=no'
EOT
  directory_permission = "0775"
  file_permission      = "0664"
  filename             = "./../ansible/inventories/production/servers.yml"
}


#####################################################################################
# # Create a file to store the IP addresses of the monitoring instance
# resource "local_file" "monitoring_Ip" {
#   filename = "${path.module}/inventories/monitoring"
#   content  = <<EOT
# ${aws_instance.monitoring_server.public_ip}
#   EOT
# }

# # Create a file to store the IP addresses of the application instances
# resource "local_file" "application_Ip" {
#   filename = "${path.module}/inventories/inventory"
#   content  = <<EOT
# ${aws_instance.server_1.public_ip}
# ${aws_instance.server_2.public_ip}
#   EOT
# }

# # Create a file to store the IP addresses of the bastion instance
# resource "local_file" "bastion_Ip" {
#   filename = "${path.module}/inventories/bastion"
#   content  = <<EOT
# ${aws_instance.bastion_host.public_ip}
#   EOT
# }

# # Create a file to store the IP addresses of the database instance
# resource "local_file" "database_Ip" {
#   filename = "${path.module}/inventories/database"
#   content  = <<EOT
# ${aws_eip.database_eip.public_ip}
#   EOT
# }
