locals {
  backend_instance_name = "${local.resource_name_prefix}-backend"
  artifact_folder = local.resource_name_prefix
}

module "backend_ec2" {
  source = "../../../modules/backend"

  instance_ami_id = "ami-012c30a0cb682f902"
  instance_type   = "t2.large"
  instance_name   = local.backend_instance_name
  artifact_folder = local.artifact_folder
  authorization_key = var.authorization_key

  vpc_id    = module.vpc.id
  subnet_id = module.vpc.private_subnets[0].id
  ingress_rules = [
    {
      cidr_blocks = [module.vpc.public_subnets[0].cidr_block, module.vpc.public_subnets[1].cidr_block]
      from_port   = var.backend_port
      to_port     = var.backend_port
    }
  ]

  root_block_device = {
    volume_size = 64
  }

  # CloudWatch Configuration
  resource_name_prefix = local.resource_name_prefix

  rds_db = {
    username = local.secret_value["rds_db_master_user_username"]
    password = local.secret_value["rds_db_master_user_password"]
    name     = module.rds_db.database_name
    endpoint = module.rds_db.endpoint
    port     = module.rds_db.port
  }

  mq = {
    ssl_used             = 1
    username             = local.secret_value["mq_default_user_username"]
    password             = local.secret_value["mq_default_user_password"]
    endpoint             = module.mq.endpoints[0].endpoint
    port                 = var.mq_mqtt_port
    stomp_port           = var.mq_stomp_port
    gw_report_topic_name = var.mq_gw_report_topic_name
    gw_report_queue_name = var.mq_gw_report_queue_name
  }

  frontend_dashboard = {
    bucket              = module.frontend.bucket
    endpoint            = module.frontend.endpoint
    local_storage_token = local.secret_value["frontend_local_storage_token"]
  }

  backend_api = {
    endpoint                      = module.backend_lb.endpoint
    proxy_port                    = var.backend_proxy_port
    port                          = var.backend_port
    env_flag                      = var.backend_env_flag
    jwt_secret                    = local.secret_value["firebase_api_key"]
    jwt_refresh_secret            = local.secret_value["backend_jwt_refresh_secret"]
    service_api_key               = local.secret_value["backend_service_api_key"]
    app_buckets_access_key_id     = aws_iam_access_key.app_buckets_user_key.id
    app_buckets_secret_access_key = aws_iam_access_key.app_buckets_user_key.secret
    app_buckets_region            = var.region
    notification_region           = module.notification.region
    notification_access_key       = module.notification.access_key
    notification_secret_key       = module.notification.secret_key
    notification_sender           = var.backend_notification_sender
    notification_email_sender     = var.backend_notification_email_sender
    super_admin                   = local.secret_value["backend_super_admin"]

    firebase_account_key  = local.secret_value["backend_firebase_account_key"]
    app_bucket_name       = aws_s3_bucket.app_bucket.id
    thumbnail_bucket_name = aws_s3_bucket.thumbnail_bucket.id
  }

  event_scheduler = {
    host = module.event_scheduler_ec2.endpoint
    port = module.event_scheduler_ec2.port
  }

  data_processing = {
    endpoint = var.data_processing_endpoint
    port     = var.data_processing_port
    api_key  = local.secret_value["data_processing_api_key"]
  }

  mqtt_service = {
    is_prod = 0
    host    = "127.0.0.1"
    port    = var.mqtt_service_port
  }

  stomp_service = {
    host                  = "127.0.0.1"
    port                  = var.stomp_service_port
    gateway_ping_endpoint = var.stomp_service_gateway_ping_endpoint
    gateway_ping_source   = "${local.backend_instance_name}-stomp-service"
    gateway_ping_api_key  = local.secret_value["stomp_service_gateway_ping_api_key"]
  }

  mq_service_api_key = local.secret_value["mq_service_api_key"]

  agora = {
    app_id   = local.secret_value["agora_app_id"]
    app_cert = local.secret_value["agora_app_cert"]
  }

  connecty_cube = {
    app_id      = local.secret_value["connecty_cube_app_id"]
    auth_key    = local.secret_value["connecty_cube_auth_key"]
    auth_secret = local.secret_value["connecty_cube_auth_secret"]
  }

  inter_server_auth_key = local.secret_value["inter_server_auth_key"]

  firebase = {
    project_id         = var.firebase_project_id
    app_id             = var.firebase_app_id
    storage_bucket     = var.firebase_storage_bucket
    app_measurement_id = var.firebase_app_measurement
    message_sender_id  = var.firebase_message_sender_id
    auth_domain        = var.firebase_auth_domain
    api_key            = local.secret_value["firebase_api_key"]
  }

  mobile_app_versions = {
    aus_ios     = var.mobile_app_aus_ios_version
    sgp_ios     = var.mobile_app_sgp_ios_version
    usa_ios     = var.mobile_app_usa_ios_version
    aus_android = var.mobile_app_aus_android_version
    sgp_android = var.mobile_app_sgp_android_version
    usa_android = var.mobile_app_usa_android_version
  }

  dialog_env_key = local.secret_value["dialog_env_key"]
}

module "backend_lb" {
  source = "../../../modules/common/load-balancer"

  godaddy_access_key = local.secret_value["godaddy_access_key"]
  godaddy_secret_key = local.secret_value["godaddy_secret_key"]

  name             = "${module.backend_ec2.name}-lb"
  root_domain_name = var.root_domain_name
  subdomain_name   = "api.${var.subdomain_name}"

  vpc_id     = module.vpc.id
  subnet_ids = [module.vpc.public_subnets[0].id, module.vpc.public_subnets[1].id]

  instance = {
    id   = module.backend_ec2.id,
    name = module.backend_ec2.name
  }

  lb_config = [
    {
      name              = "api"
      frontend_port     = var.backend_proxy_port
      backend_port      = var.backend_port
      health_check_path = "/api"
    }
  ]

  dns_config = {
    ttl = 600
  }
}
