#S3 bucket creation
resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = "codepipeline-artifact-s3-bucket"
  force_destroy = true
}