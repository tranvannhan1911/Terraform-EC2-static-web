resource "aws_key_pair" "restaurant_keypair" {
  key_name   = "restaurant"
  public_key = file("restaurant.pub")
}

resource "aws_instance" "my_instance" {
  ami                    = var.amis[var.region]
  instance_type          = var.instance_type
  availability_zone      = var.availability_zones[var.region]
  key_name               = aws_key_pair.restaurant_keypair.key_name
  vpc_security_group_ids = ["sg-03beb286e8e43cadb"]
  tags = {
    Name = var.instance_name
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod u+x /tmp/script.sh",
      "sudo /tmp/script.sh"
    ]
  }

  connection {
    user        = var.user
    type        = "ssh"
    private_key = file("restaurant")
    host        = self.public_ip
  }
}

output "PublicIp" {
	value = aws_instance.my_instance.public_ip
}

output "PublicDNS" {
	value = aws_instance.my_instance.public_dns
}

output "PrivateIp" {
	value = aws_instance.my_instance.private_ip
}