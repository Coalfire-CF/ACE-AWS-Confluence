resource "aws_security_group" "confluence_instance_sg" {
  provider = aws.mgmt

  name        = "confluence_instance_sg"
  description = "Allow Confluence traffic"
  vpc_id      = data.terraform_remote_state.network-mgmt.outputs.vpc_id

  #ssh traffic form within environment 
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["${var.ip_network_mgmt}.0.0/16"]
  }

  ingress {
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
    cidr_blocks = ["${var.ip_network_mgmt}.0.0/16"]
  }

  ingress {
    from_port   = 8090
    protocol    = "tcp"
    to_port     = 8091
    cidr_blocks = ["${var.ip_network_mgmt}.0.0/16"]
  }

  ingress {
    from_port = 8443
    protocol  = "tcp"
    to_port   = 8443
    cidr_blocks = [
      "${var.ip_network_mgmt}.0.0/16",
      "${var.ip_network_prod}.0.0/16",
      "${var.ip_network_stage}.0.0/16",

    ]
  }


  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "confluence_db_sg" {
  provider = aws.mgmt

  name        = "confluence_db_sg"
  vpc_id      = data.terraform_remote_state.network-mgmt.outputs.vpc_id
  description = "Allow Confluence DB traffic"

  ingress {
    from_port   = 5432
    description = "confluence instance"
    protocol    = "tcp"
    to_port     = 5432
    security_groups = [
      aws_security_group.confluence_instance_sg.id,
    ]
  }

  ingress {
    from_port       = 5432
    protocol        = "tcp"
    to_port         = 5432
    security_groups = [data.terraform_remote_state.nessusburp.outputs.nessusburp_instance_sg_id]
    description     = "Nessusburp"
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
