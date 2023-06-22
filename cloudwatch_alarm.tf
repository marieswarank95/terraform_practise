resource "aws_cloudwatch_metric_alarm" "web_server_alarm" {
  for_each            = aws_instance.web_server
  alarm_name          = "Web-server-CPU-usage-alarm-${each.value.id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 50
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = each.value.id
  }
}