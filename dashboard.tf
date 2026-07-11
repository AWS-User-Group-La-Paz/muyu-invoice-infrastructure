# Shows the current health and utilization of the teaching deployment in one place.
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.name_prefix}-overview"

  dashboard_body = jsonencode({
    start          = "-PT6H"
    periodOverride = "inherit"
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "# 1. Incoming Requests"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 1
        width  = 6
        height = 6
        properties = {
          title  = "Requests Received"
          region = var.aws_region
          view   = "timeSeries"
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", module.cluster.alb_arn_suffix, { stat = "Sum" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 1
        width  = 6
        height = 6
        properties = {
          title  = "Response Latency (p95)"
          region = var.aws_region
          view   = "timeSeries"
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", module.cluster.alb_arn_suffix, { stat = "p95" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 1
        width  = 6
        height = 6
        properties = {
          title  = "Successful Responses"
          region = var.aws_region
          view   = "timeSeries"
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", module.cluster.alb_arn_suffix, { stat = "Sum" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 18
        y      = 1
        width  = 6
        height = 6
        properties = {
          title  = "Healthy Service Targets"
          region = var.aws_region
          view   = "singleValue"
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", module.cluster.alb_arn_suffix, "TargetGroup", module.invoice_service.target_group_arn_suffix, { stat = "Minimum" }]
          ]
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 7
        width  = 24
        height = 1
        properties = {
          markdown = "# 2. ECS Web App Service"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 6
        height = 6
        properties = {
          title  = "Web CPU Use"
          region = var.aws_region
          view   = "gauge"
          period = 60
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", module.cluster.cluster_name, "ServiceName", module.invoice_service.service_name, { stat = "Average" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 8
        width  = 6
        height = 6
        properties = {
          title  = "Web Memory Use"
          region = var.aws_region
          view   = "gauge"
          period = 60
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", module.cluster.cluster_name, "ServiceName", module.invoice_service.service_name, { stat = "Average" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 8
        width  = 6
        height = 6
        properties = {
          title  = "Running Web Tasks"
          region = var.aws_region
          view   = "singleValue"
          period = 60
          metrics = [
            ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", module.cluster.cluster_name, "ServiceName", module.invoice_service.service_name, { stat = "Average" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 18
        y      = 8
        width  = 6
        height = 6
        properties = {
          title  = "Desired Web Tasks"
          region = var.aws_region
          view   = "singleValue"
          period = 60
          metrics = [
            ["ECS/ContainerInsights", "DesiredTaskCount", "ClusterName", module.cluster.cluster_name, "ServiceName", module.invoice_service.service_name, { stat = "Average" }]
          ]
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 14
        width  = 24
        height = 8
        properties = {
          title  = "Web Service Logs"
          region = var.aws_region
          view   = "table"
          query  = <<-QUERY
            SOURCE '${module.invoice_service.log_group_name}'
            | fields @timestamp, @message
            | filter @message not like /path="\/health"/
            | sort @timestamp desc
            | limit 20
          QUERY
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 22
        width  = 24
        height = 1
        properties = {
          markdown = "# 3. Invoice Queue"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 23
        width  = 8
        height = 6
        properties = {
          title  = "Invoices Waiting Over Time"
          region = var.aws_region
          view   = "timeSeries"
          period = 60
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", aws_sqs_queue.invoice_pdf_jobs.name, {
              stat  = "Average"
              label = "Waiting"
            }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 23
        width  = 8
        height = 6
        properties = {
          title     = "Invoices Waiting Now"
          region    = var.aws_region
          view      = "singleValue"
          period    = 60
          sparkline = true
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", aws_sqs_queue.invoice_pdf_jobs.name, {
              stat  = "Average"
              label = "Waiting"
            }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 23
        width  = 8
        height = 6
        properties = {
          title  = "Oldest Wait"
          region = var.aws_region
          view   = "singleValue"
          period = 60
          metrics = [
            ["AWS/SQS", "ApproximateAgeOfOldestMessage", "QueueName", aws_sqs_queue.invoice_pdf_jobs.name, {
              stat  = "Maximum"
              label = "Age"
            }]
          ]
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 29
        width  = 24
        height = 1
        properties = {
          markdown = "# 4. ECS Worker Service"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 30
        width  = 8
        height = 6
        properties = {
          title  = "Worker CPU Use"
          region = var.aws_region
          view   = "gauge"
          period = 60
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", module.cluster.cluster_name, "ServiceName", module.invoice_worker.service_name, { stat = "Average" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 30
        width  = 8
        height = 6
        properties = {
          title  = "Worker Memory Use"
          region = var.aws_region
          view   = "gauge"
          period = 60
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", module.cluster.cluster_name, "ServiceName", module.invoice_worker.service_name, { stat = "Average" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 30
        width  = 8
        height = 6
        properties = {
          title  = "Running Worker Tasks"
          region = var.aws_region
          view   = "singleValue"
          period = 60
          metrics = [
            ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", module.cluster.cluster_name, "ServiceName", module.invoice_worker.service_name, { stat = "Average" }]
          ]
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 36
        width  = 24
        height = 8
        properties = {
          title  = "Worker Service Logs"
          region = var.aws_region
          view   = "table"
          query  = <<-QUERY
            SOURCE '${module.invoice_worker.log_group_name}'
            | fields @timestamp, @message
            | sort @timestamp desc
            | limit 20
          QUERY
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 44
        width  = 24
        height = 1
        properties = {
          markdown = "# 5. PostgreSQL Database"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 45
        width  = 8
        height = 6
        properties = {
          title  = "Database CPU Use"
          region = var.aws_region
          view   = "gauge"
          period = 60
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.main.identifier, { stat = "Average" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 45
        width  = 8
        height = 6
        properties = {
          title  = "Database Connections"
          region = var.aws_region
          view   = "singleValue"
          period = 60
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.main.identifier, { stat = "Average" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 45
        width  = 8
        height = 6
        properties = {
          title  = "Free Database Storage"
          region = var.aws_region
          view   = "timeSeries"
          period = 60
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", aws_db_instance.main.identifier, { stat = "Average" }]
          ]
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 51
        width  = 24
        height = 8
        properties = {
          title  = "PostgreSQL Logs"
          region = var.aws_region
          view   = "table"
          query  = <<-QUERY
            SOURCE '/aws/rds/instance/${aws_db_instance.main.identifier}/postgresql'
            | fields @timestamp, @message
            | sort @timestamp desc
            | limit 20
          QUERY
        }
      }
    ]
  })
}
