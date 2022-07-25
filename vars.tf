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