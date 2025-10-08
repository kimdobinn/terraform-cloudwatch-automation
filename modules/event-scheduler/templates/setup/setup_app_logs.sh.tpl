#!/bin/bash
# Create event-scheduler application logs configuration
cat << 'EOF' > /opt/aws/amazon-cloudwatch-agent/etc/file_event_scheduler.json
${app_logs_config}
EOF

# Append application logs config to CloudWatch agent
amazon-cloudwatch-agent-ctl -a append-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/file_event_scheduler.json -s
