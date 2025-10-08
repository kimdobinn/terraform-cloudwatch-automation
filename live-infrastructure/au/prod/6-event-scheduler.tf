module "event_scheduler_ec2" {
  source = "../../../modules/event-scheduler"

  instance_ami_id = "ami-012c30a0cb682f902"
  instance_type   = "t2.micro"
  instance_name   = "${local.resource_name_prefix}-event-scheduler"
  authorization_key = var.authorization_key

  vpc_id    = module.vpc.id
  subnet_id = module.vpc.private_subnets[0].id
  ingress_rules = [
    {
      cidr_blocks = [module.vpc.private_subnets[0].cidr_block]
      from_port   = var.event_scheduler_port
      to_port     = var.event_scheduler_port
    }
  ]

  # CloudWatch Configuration
  resource_name_prefix = local.resource_name_prefix

  event_scheduler = {
    port = var.event_scheduler_port
  }

  backend_api = {
    endpoint = module.backend_lb.endpoint
    port     = var.backend_proxy_port
  }

  docdb = {
    username = local.secret_value["docdb_master_user_username"]
    password = local.secret_value["docdb_master_user_password"]
    endpoint = module.docdb.endpoint
    port     = module.docdb.port
  }

  inter_server_auth_key = local.secret_value["inter_server_auth_key"]
}
