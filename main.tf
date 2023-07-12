provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami                    = "ami-06ca3ca175f37dd66"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup /usr/bin/python3 -m http.server "${var.server_port}" &
              EOF

  tags = {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP address of the Web"
}


# [root@ip-172-31-87-79 ~]# cat /usr/lib/systemd/system/http.service 
# [Unit]
# Description=Python Httpd Service


# [Service]
# Type=simple
# RemainAfterExit=yes
# ExecStart=/usr/bin/python3 -m http.server 8080
# ExecStop=killall -9 python3

# [Install]
# WantedBy=multi-user.target
# [root@ip-172-31-87-79 ~]# uptime
#  09:44:12 up 17 min,  1 user,  load average: 0.00, 0.00, 0.00