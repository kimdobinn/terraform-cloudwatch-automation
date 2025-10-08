module "this" {
  source = "../common/ec2"

  instance_ami_id = var.instance_ami_id
  instance_type   = var.instance_type
  instance_name   = var.instance_name

  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  ingress_rules = var.ingress_rules

  instance_profile_name = aws_iam_instance_profile.this.name

  root_block_device = var.root_block_device

  user_data = "${local.download_exec_init_script}\n${local.setup_app_logs_script}\n${var.user_data}"

  # CloudWatch Configuration
  resource_name_prefix = var.resource_name_prefix
  service_name         = "backend"
  service_user         = "appsvc"

  depends_on = [aws_s3_object.init_script_object]
}
