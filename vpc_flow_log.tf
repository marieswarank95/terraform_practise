#cloudwatch log group creation
resource "aws_cloudwatch_log_group" "cw_log_group" {
  name              = "${var.project_name}-${var.env_name}-vpc-flow-logs"
  retention_in_days = 30
}

#IAM role policy creation
resource "aws_iam_role_policy" "fl_role_policy" {
  name = "fl_role_policy"
  role = aws_iam_role.fl_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Stmt1687340216636",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

#IAM role creation
resource "aws_iam_role" "fl_role" {
  name = "${var.project_name}-${var.env_name}-vpc-flowlog-Role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "vpc-flow-logs.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_flow_log" "flow_log" {
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.cw_log_group.arn
  vpc_id                   = aws_vpc.vpc.id
  max_aggregation_interval = 60
  iam_role_arn             = aws_iam_role.fl_role.arn
  tags = {
    Name = "${var.project_name}-${var.env_name}-flow-log"
  }

}