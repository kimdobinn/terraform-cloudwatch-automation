{
  "agent": {
    "metrics_collection_interval": 60,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "metrics": {
    "append_dimensions": {
      "InstanceId": "$${aws:InstanceId}"
    },
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_active",
          "cpu_usage_nice",
          "cpu_usage_system",
          "cpu_usage_user",
          "cpu_usage_iowait",
          "cpu_usage_irq",
          "cpu_usage_softirq"
        ],
        "resources": ["*"],
        "metrics_collection_interval": 60,
        "totalcpu": true
      },
      "mem": {
        "measurement": [
          "mem_used_percent",
          "mem_free",
          "mem_used",
          "mem_buffered",
          "mem_cached",
          "mem_total"
        ],
        "metrics_collection_interval": 60
      },
      "processes": {
        "measurement": [
          "processes_total",
          "processes_total_threads"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used_percent",
          "swap_used",
          "swap_free"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "disk_used",
          "disk_free",
          "disk_total",
          "disk_used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "diskio": {
        "measurement": [
          "diskio_io_time",
          "diskio_read_time",
          "diskio_write_time",
          "diskio_reads",
          "diskio_writes",
          "diskio_read_bytes",
          "diskio_write_bytes"
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "net": {
        "measurement": [
          "net_bytes_sent",
          "net_bytes_recv",
          "net_packets_sent",
          "net_packets_recv"
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "netstat": {
        "measurement": [
          "netstat_tcp_established",
          "netstat_tcp_close_wait"
        ],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      }
    }
  },
  "force_flush_interval": 300
}
