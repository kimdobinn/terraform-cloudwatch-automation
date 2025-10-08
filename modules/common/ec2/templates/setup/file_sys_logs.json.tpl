{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/dnf.log",
            "log_group_name": "/rpm/${resource_name_prefix}/sys/dnf",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-${service}-dnf.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          },
          {
            "file_path": "/var/log/audit/audit.log",
            "log_group_name": "/rpm/${resource_name_prefix}/sys/audit",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-${service}-audit.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "/rpm/${resource_name_prefix}/sys/cloud-init-output.log",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-${service}-cloud-init-output.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          },
          {
            "file_path": "/var/log/cloud-init.log",
            "log_group_name": "/rpm/${resource_name_prefix}/sys/cloud-init.log",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-${service}-cloud-init.log",
            "timestamp_format": "%Y-%m-%dT%H:%M:%S",
            "timezone": "UTC",
            "retention_in_days": 60
          }
        ]
      }
    }
  }
}
