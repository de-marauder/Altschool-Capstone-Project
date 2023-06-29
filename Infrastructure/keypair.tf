
resource "aws_key_pair" "altschool-keypair" {
  key_name   = var.keypair_filename
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "altschool-keypair" {
  content         = tls_private_key.rsa.private_key_pem
  filename        = "../ansible/${var.keypair_filename}.pem"
  file_permission = 400
}