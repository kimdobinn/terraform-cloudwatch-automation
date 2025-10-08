#!/bin/bash
## Log setup output to /var/log/terraform-user-data.logs
exec > >(tee /var/log/terraform-user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "===== Updating yum ====="
yum update -y

echo "===== Installing CloudWatch agent ====="
yum install -y amazon-cloudwatch-agent

echo "===== Creating CloudWatch configuration ====="
cat << EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
${file("${setup_file_dir}/amazon-cloudwatch-config.json.tpl")}
EOF

# Create metrics configuration
cat << 'EOF' > /opt/aws/amazon-cloudwatch-agent/etc/file_metrics.json
${file_metrics_config}
EOF

# Create system logs configuration
cat << 'EOF' > /opt/aws/amazon-cloudwatch-agent/etc/file_sys_logs.json
${file_sys_logs_config}
EOF

echo "===== Initializing CloudWatch Agent ====="
amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Append metrics config
amazon-cloudwatch-agent-ctl -a append-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/file_metrics.json -s

# Append system logs config
amazon-cloudwatch-agent-ctl -a append-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/file_sys_logs.json -s

echo "===== Reinstall awscli ====="
yum remove awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

rm awscliv2.zip
rm -rf aws
