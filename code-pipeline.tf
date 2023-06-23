# IAM role creation for build project
resource "aws_iam_role" "build_project_role" {
  name = "${var.build_project_name}-build-project-Role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Principal" : { "Service" : "codebuild.amazonaws.com" }
    }]
  })
}

# IAM policy creation for code build am IAM role
resource "aws_iam_role_policy" "build_project_policy" {
  name = "${var.build_project_name}-build-project-policy"
  role = aws_iam_role.build_project_role.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Stmt1687507915421",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Sid" : "Stmt1687507935332",
        "Action" : "ecr:*",
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Sid" : "Stmt1687507947821",
        "Action" : ["ecr-public:*", "sts:GetServiceBearerToken"],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Sid" : "Stmt1687507969037",
        "Action" : "s3:*",
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

# Code build project creation
resource "aws_codebuild_project" "build_project" {
  name         = "${var.build_project_name}-build-project"
  service_role = aws_iam_role.build_project_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image_pull_credentials_type = "CODEBUILD"
    image                       = "aws/codebuild/standard:7.0"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }
  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.cw_log_group.name
      status     = "ENABLED"
      #stream_name = aws_codebuild_project.build_project.name        }
    }
  }
  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 0
  }
}

# IAM role creation for code pipeline
resource "aws_iam_role" "pipeline_role" {
  name = "${var.project_name}-${var.service_name}-pipeline"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Principal" : { "Service" : "codepipeline.amazonaws.com" }
    }]
  })
}

# IAM policy creation for pipeline role
resource "aws_iam_role_policy" "pipeline_policy" {
  name = "${var.project_name}-pipeline-policy"
  role = aws_iam_role.pipeline_role.name
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "iam:PassRole"
        ],
        "Resource" : "*",
        "Effect" : "Allow",
        "Condition" : {
          "StringEqualsIfExists" : {
            "iam:PassedToService" : [
              "cloudformation.amazonaws.com",
              "elasticbeanstalk.amazonaws.com",
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      },
      {
        "Action" : [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "codestar-connections:UseConnection"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "elasticbeanstalk:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "cloudwatch:*",
          "s3:*",
          "sns:*",
          "cloudformation:*",
          "rds:*",
          "sqs:*",
          "ecs:*"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "lambda:InvokeFunction",
          "lambda:ListFunctions"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "opsworks:CreateDeployment",
          "opsworks:DescribeApps",
          "opsworks:DescribeCommands",
          "opsworks:DescribeDeployments",
          "opsworks:DescribeInstances",
          "opsworks:DescribeStacks",
          "opsworks:UpdateApp",
          "opsworks:UpdateStack"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeStacks",
          "cloudformation:UpdateStack",
          "cloudformation:CreateChangeSet",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DescribeChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:SetStackPolicy",
          "cloudformation:ValidateTemplate"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "devicefarm:ListProjects",
          "devicefarm:ListDevicePools",
          "devicefarm:GetRun",
          "devicefarm:GetUpload",
          "devicefarm:CreateUpload",
          "devicefarm:ScheduleRun"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "servicecatalog:ListProvisioningArtifacts",
          "servicecatalog:CreateProvisioningArtifact",
          "servicecatalog:DescribeProvisioningArtifact",
          "servicecatalog:DeleteProvisioningArtifact",
          "servicecatalog:UpdateProduct"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudformation:ValidateTemplate"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:DescribeImages"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "states:DescribeExecution",
          "states:DescribeStateMachine",
          "states:StartExecution"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "appconfig:StartDeployment",
          "appconfig:StopDeployment",
          "appconfig:GetDeployment"
        ],
        "Resource" : "*"
      }
    ],
    "Version" : "2012-10-17"
  })
}

#Code pipeline creation
resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project_name}-${var.service_name}-pipeline"
  role_arn = aws_iam_role.pipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.artifact_bucket.id
    type     = "S3"
  }
  stage {
    name = "Source-codecommit"
    action {
      category = "Source"
      owner    = "AWS"
      name     = "checkout-code"
      provider = "CodeCommit"
      version  = 1
      configuration = {
        BranchName           = "master"
        PollForSourceChanges = "false"
        RepositoryName       = "nodejs-app"
      }
      output_artifacts = ["Source_artifact"]

    }
  }
  stage {
    name = "Build"
    action {
      category = "Build"
      owner    = "AWS"
      name     = "build"
      provider = "CodeBuild"
      version  = 1
      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
      input_artifacts  = ["Source_artifact"]
      output_artifacts = ["Build_artifact"]
    }
  }
  stage {
    name = "ECS_Deployment"
    action {
      name     = "ECS-deploy"
      category = "Deploy"
      owner    = "AWS"
      provider = "ECS"
      version  = 1
      configuration = {
        ClusterName = var.cluster_name
        ServiceName = var.service_name
      }
      input_artifacts = ["Build_artifact"]
    }
  }
}