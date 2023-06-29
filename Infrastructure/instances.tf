
# create application server 1
resource "aws_instance" "server_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.keypair_filename
  vpc_security_group_ids = [aws_security_group.capstone_security_grp_rule.id]
  subnet_id              = aws_subnet.capstone_public_subnet1.id

  tags = {
    Name = "app_server_1"
  }
}

# create application server 2
resource "aws_instance" "server_2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.keypair_filename

  vpc_security_group_ids = [aws_security_group.capstone_security_grp_rule.id]
  subnet_id              = aws_subnet.capstone_public_subnet2.id

  tags = {
    Name = "app_server_2"
  }
}

# create database instance
resource "aws_instance" "database_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.keypair_filename

  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  subnet_id              = aws_subnet.capstone_private_subnet.id

  provisioner "remote-exec" {
    inline = [
      "sudo su -c 'echo Port 2200 >> /etc/ssh/sshd_config && systemctl restart sshd.service'"
    ]

    connection {
      type                = "ssh"
      bastion_port        = 2200
      bastion_host        = aws_instance.bastion_host.public_ip
      bastion_user        = "ubuntu"                            // Or the appropriate SSH user for the bastion host
      bastion_private_key = tls_private_key.rsa.private_key_pem // Path to the private key for the bastion host
      host                = self.private_ip
      user                = "ubuntu"                            // Or the appropriate SSH user for the private instance
      private_key         = tls_private_key.rsa.private_key_pem // Path to the private key for the private instance
      port                = 22
    }
  }

  tags = {
    Name = "database_server"
  }
}

# create monitoring server
resource "aws_instance" "monitoring_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.montoring_instance_type
  key_name               = var.keypair_filename
  vpc_security_group_ids = [aws_security_group.monitoring_security_group.id]
  subnet_id              = aws_subnet.capstone_public_subnet1.id

  tags = {
    Name = "monitoring_server"
  }
}

# create bastion host

resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.keypair_filename

  vpc_security_group_ids = [aws_security_group.bastion_security_group.id]
  subnet_id              = aws_subnet.capstone_public_subnet1.id

  provisioner "remote-exec" {
    inline = [
      "sudo su -c 'echo Port 2200 >> /etc/ssh/sshd_config && systemctl restart sshd.service'"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      port        = 2200
      user        = "ubuntu"                            // Or the appropriate SSH user for the private instance
      private_key = tls_private_key.rsa.private_key_pem // Path to the private key for the private instance
    }
  }

  tags = {
    Name = "bastion-host"
  }
}
