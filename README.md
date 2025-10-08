# CloudWatch Agent Automation with Terraform

## Project Overview

Automated CloudWatch agent configuration for EC2 instances across multi-region, multi-environment AWS infrastructure using Terraform Infrastructure as Code (IaC).

## Problem Statement

**Before**: CloudWatch agent setup was a manual, error-prone process:
- Required SSH access through jumpserver to each EC2 instance
- Manual creation and placement of JSON configuration files
- Manual variable adjustment based on:
  - Instance type (event-scheduler, backend, etc.)
  - Region (AU, SG, US, KR)
  - Environment (prod, uat, demo, staging)
- High risk of misconfiguration and inconsistency across environments
- Time-consuming and not scalable

**After**: Fully automated CloudWatch configuration:
- Config files automatically generated during EC2 instance provisioning
- Environment and service-specific variables automatically substituted
- Consistent monitoring across all instances and environments
- Zero manual intervention required

## Solution Architecture

### Templating Strategy

Implemented a hierarchical template system using Terraform's `templatefile()` function:

1. **Common Templates** (`modules/common/ec2/templates/setup/`)
   - Base initialization scripts shared across all instance types
   - System-level metrics and log collection

2. **Service-Specific Templates** (`modules/{service}/templates/setup/`)
   - Application-specific log configurations
   - Service-dependent setup scripts

3. **Environment Configuration** (`live-infrastructure/{region}/{env}/`)
   - Region and environment-specific parameters
   - Resource naming conventions

### File Structure

```
modules/
├── common/ec2/templates/setup/
│   ├── init.sh.tpl                    # Base CloudWatch agent installation
│   ├── file_metrics.json.tpl          # System metrics configuration
│   └── file_sys_logs.json.tpl         # System logs configuration
│
├── event-scheduler/
│   ├── 2-instance.tf                  # Module instantiation with CloudWatch params
│   └── templates/setup/
│       ├── init.sh.tpl                # Service setup script
│       ├── file_event_scheduler.json.tpl  # Application logs config
│       └── setup_app_logs.sh.tpl      # CloudWatch append script
│
└── backend/
    ├── 2-instance.tf                  # Module instantiation with CloudWatch params
    └── templates/setup/
        ├── init.sh.tpl                # Service setup script
        ├── file_app_logs.json.tpl     # Application logs config
        └── setup_app_logs.sh.tpl      # CloudWatch append script

live-infrastructure/
└── au/prod/
    ├── 6-event-scheduler.tf           # Event scheduler instance config
    └── 8-backend.tf                   # Backend instance config
```

## Technical Implementation

### 1. Variable Propagation Flow

```
Environment Config (au/prod)
    → Module Instance (event-scheduler/backend)
    → Common EC2 Module
    → Template Rendering
    → User Data Script
```

**Key Variables:**
- `resource_name_prefix`: Environment identifier (e.g., "au-prod", "sg-uat")
- `service_name`: Instance type ("event-scheduler", "backend")
- `service_user`: Application user account ("appsvc")

### 2. CloudWatch Configuration Layers

**Layer 1: Base Configuration**
```bash
# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Initialize with base config
amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
```

**Layer 2: System Metrics** (`file_metrics.json.tpl`)
- CPU usage (active, system, user, iowait, irq, softirq)
- Memory metrics (used, free, buffered, cached)
- Disk I/O (reads, writes, bytes, latency)
- Network statistics (bytes sent/received, packets)
- Process and swap metrics

**Layer 3: System Logs** (`file_sys_logs.json.tpl`)
```json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/dnf.log",
            "log_group_name": "/rpm/${resource_name_prefix}/sys/dnf",
            "log_stream_name": "{instance_id}-${resource_name_prefix}-${service}-dnf.log",
            "retention_in_days": 60
          }
          // ... audit.log, cloud-init logs
        ]
      }
    }
  }
}
```

**Layer 4: Application Logs** (Service-specific)
- Event Scheduler: PM2 logs for event-scheduler service
- Backend: PM2 logs for backend-api, mqtt-service, stomp-service

### 3. Dynamic Template Rendering

**Example: Event Scheduler Instance** (`modules/event-scheduler/2-instance.tf`)
```hcl
module "this" {
  source = "../common/ec2"

  # CloudWatch Configuration
  resource_name_prefix = var.resource_name_prefix  # e.g., "au-prod"
  service_name         = "event-scheduler"
  service_user         = "appsvc"

  user_data = "${local.init_script}\n${local.setup_app_logs_script}\n${var.user_data}"
}
```

**Template Variables Substitution:**
```bash
# Template: file_sys_logs.json.tpl
log_group_name: "/rpm/${resource_name_prefix}/sys/audit"
log_stream_name: "{instance_id}-${resource_name_prefix}-${service}-audit.log"

# Rendered (au-prod, event-scheduler):
log_group_name: "/rpm/au-prod/sys/audit"
log_stream_name: "{instance_id}-au-prod-event-scheduler-audit.log"
```

### 4. Multi-Stage Configuration Append

```bash
# Stage 1: Base config
amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/.../base-config.json -s

# Stage 2: Append metrics
amazon-cloudwatch-agent-ctl -a append-config -m ec2 -c file:/.../file_metrics.json -s

# Stage 3: Append system logs
amazon-cloudwatch-agent-ctl -a append-config -m ec2 -c file:/.../file_sys_logs.json -s

# Stage 4: Append application logs (runs after app deployment)
amazon-cloudwatch-agent-ctl -a append-config -m ec2 -c file:/.../file_app_logs.json -s
```

## Skills Demonstrated

### Infrastructure as Code (IaC)
- Terraform module architecture and composition
- Template file rendering with dynamic variables
- User data script orchestration
- Module variable propagation across nested modules

### AWS Services
- **EC2**: Instance provisioning and configuration
- **CloudWatch**: Agent installation, metrics collection, log aggregation
- **IAM**: Instance profiles and permissions for CloudWatch access
- **VPC**: Network configuration for secure access

### DevOps & Automation
- Eliminated manual configuration processes
- Created reusable, scalable infrastructure patterns
- Implemented consistent monitoring across environments
- Reduced deployment time and human error

### Problem-Solving
- Analyzed complex manual workflow
- Designed automated solution with hierarchical configuration
- Implemented environment-agnostic templating system
- Maintained backward compatibility during migration

### System Administration
- Linux shell scripting (Bash)
- CloudWatch agent configuration and operations
- Log management and retention policies
- PM2 process manager log collection

## Tools & Technologies

- **IaC**: Terraform (HCL)
- **Cloud**: AWS (EC2, CloudWatch, IAM)
- **Scripting**: Bash, Shell scripting
- **Configuration**: JSON templates, CloudWatch agent
- **Version Control**: Git
- **Languages**: HCL (Terraform), Bash

## Results & Impact

✅ **Zero Manual Configuration**: Eliminated all manual CloudWatch setup steps

✅ **Consistency**: Identical monitoring configuration across all environments

✅ **Scalability**: New instances automatically configured on launch

✅ **Maintainability**: Centralized template management

✅ **Error Reduction**: Removed human error from configuration process

✅ **Time Savings**: ~30+ minutes per instance saved

## Environment Coverage

Implemented across multiple regions and environments:
- **Regions**: Australia (AU), Singapore (SG), United States (US), Korea (KR)
- **Environments**: Production, UAT, Demo, Staging
- **Services**: Event Scheduler, Backend API, MQTT Service, STOMP Service

## Key Takeaways

1. **Automation First**: Convert repetitive manual tasks into automated workflows
2. **Template Design**: Use hierarchical templates for reusability and maintainability
3. **Variable Propagation**: Design clear data flow from environment to implementation
4. **Layered Configuration**: Build complex configurations through composition
5. **Infrastructure as Code**: Treat infrastructure configuration as version-controlled code
