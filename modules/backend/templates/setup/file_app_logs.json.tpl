{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/home/${service_user}/.pm2/pm2.log",
            "log_group_name": "/rpm/${resource_name_prefix}/app/pm2",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-${service}-pm2.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          },
          {
            "file_path": "/home/${service_user}/.pm2/logs/backend-api-out.log",
            "log_group_name": "/rpm/${resource_name_prefix}/app/backend-api",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-${service}_api-pm2-out.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          },
          {
            "file_path": "/home/${service_user}/.pm2/logs/backend-api-error.log",
            "log_group_name": "/rpm/${resource_name_prefix}/app/backend-api",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-${service}_api-pm2-error.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          },
          {
            "file_path": "/home/${service_user}/.pm2/logs/mqtt-service-out.log",
            "log_group_name": "/rpm/${resource_name_prefix}/app/mqtt-service",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-mqtt-pm2-out.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          },
          {
            "file_path": "/home/${service_user}/.pm2/logs/mqtt-service-error.log",
            "log_group_name": "/rpm/${resource_name_prefix}/app/mqtt-service",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-mqtt-pm2-error.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          },
          {
            "file_path": "/home/${service_user}/.pm2/logs/stomp-service-out.log",
            "log_group_name": "/rpm/${resource_name_prefix}/app/stomp-service",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-stomp-pm2-out.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          },
          {
            "file_path": "/home/${service_user}/.pm2/logs/stomp-service-error.log",
            "log_group_name": "/rpm/${resource_name_prefix}/app/stomp-service",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-stomp-pm2-error.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          },
          {
            "file_path": "/home/${service_user}/.pm2/logs/backend/access.log",
            "log_group_name": "/rpm/${resource_name_prefix}/app/api-logs",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-api-logs.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          }
        ]
      }
    }
  }
}
