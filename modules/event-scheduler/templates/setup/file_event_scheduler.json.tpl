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
            "file_path": "/home/${service_user}/.pm2/logs/event-scheduler-out.log",
            "log_group_name": "/rpm/${resource_name_prefix}/app/${service}",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-${service}_${service}-pm2-out.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          },
          {
            "file_path": "/home/${service_user}/.pm2/logs/event-scheduler-error.log",
            "log_group_name": "/rpm/${resource_name_prefix}/app/${service}",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-${service}_${service}-pm2-error.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          }
        ]
      }
    }
  }
}
