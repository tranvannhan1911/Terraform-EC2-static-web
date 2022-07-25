# Terraform - EC2 - Static web

1. Nội dung
    - `Yêu cầu:` Tạo một instance và key pair, sau đó setup 1 static web lên server
    1. Tạo key pair trên local
        
        ```bash
        $ ssh-keygen
        ```
        
    2. Tạo `script.sh`
        
        ```bash
        #!/bin/bash
        sleep 60
        sudo apt update -y
        sudo apt install apache2 unzip -y
        sudo systemctl enable apache2
        wget "https://www.tooplate.com/zip-templates/2129_crispy_kitchen.zip"
        unzip 2129_crispy_kitchen.zip
        sudo cp -r 2129_crispy_kitchen/* /var/www/html/
        ```
        
        - script này sẽ được push lên instance để chạy
    3. Tạo các biến `vars.tf`
        
        ```bash
        variable "user" {
          description = "default user of the instance"
          default     = "ubuntu"
        }
        
        variable "region" {
          description = "Region"
          default     = "ap-southeast-1"
        }
        
        variable "instance_type" {
          description = "Instance type"
          default     = "t2.micro"
        }
        
        variable "amis" {
          description = "Amazon Machine Image"
          type        = map(any)
          default = {
            ap-southeast-1 : "ami-04ff9e9b51c1f62ca"
            ap-southeast-2 : "ami-0e040c48614ad1327"
          }
        }
        
        variable "availability_zones" {
          type = map(any)
          default = {
            ap-southeast-1 : "ap-southeast-1a"
            ap-southeast-2 : "ap-southeast-2b"
          }
        }
        
        variable "instance_name" {
          type    = string
          default = "restaurant instance"
          validation {
            condition     = length(var.instance_name) >= 5 && length(regexall("instance$", var.instance_name)) > 0
            error_message = "The image must be least 5 characters and end with `instance`"
          }
        }
        ```
        
        - `variable "region"`: Khai báo biến
        - `default`: Các giá trị mặc định
        - `type`: Loại biến. Có các loại như: `string, number, bool, list(<TYPE>), set(<TYPE>), map(<TYPE>), tuple(<TYPE>), object({<SOMETHING>})`. Sử dụng `any` để chỉ loại bất kỳ. Nếu `default` và `type` đều được cung cấp thì `default` phải đúng kiểu dữ liệu của `type`.
        - `description`: Mô tả
        - `validation`: Ràng buộc của biến
        - `condition`: Điều kiện
        - `length`: Hàm trả về độ dài. Các hàm khác ([https://www.terraform.io/language/functions](https://www.terraform.io/language/functions))
        - `error_message`: Thông báo trả về nếu không thỏa mãn điều kiện.
    4. Tạo `provider.tf`
        
        ```bash
        provider "aws" {
          region = var.region
        }
        ```
        
    5. `instance.tf`
        
        ```bash
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
        ```
        
        - `file("restaurant.pub")` : Để đọc file
        - `resource "aws_key_pair" "restaurant_keypair"`: Tạo tài nguyên key pair với name và public key đã được tạo sẵn ở local.
        - `aws_key_pair.restaurant_keypair.key_name`: Truy xuất key pair name
        - `provisioner "file"`: Copy file
        - `provisioner "remote-exec"` : Thực hiện chạy lệnh từ xa trên instance
        - `connection`: Khai báo cách kết nối tới instance
            - `self.public_ip`: Lấy địa chỉ công khai của instance
            - `type`: Loại connection
            - `private_key`: Private key để ssh tới instance
    6. `terraform validate` Để kiểm tra syntax, logic code
    7. `terraform plan`: Để xem những gì sẽ được thêm vào.
    8. `terraform apply`: Để apply.
2. Kết quả
    
    ![Untitled](https://i.imgur.com/LEFGkET.png)
    
    ![Untitled](https://i.imgur.com/fbnyfkI.png)
    
3. Tài liệu tham khảo
    - [https://www.terraform.io/language](https://www.terraform.io/language)
    - [https://registry.terraform.io/providers/hashicorp/aws/latest/docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)