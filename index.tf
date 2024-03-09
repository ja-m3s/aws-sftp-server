provider "aws" {
  region = "eu-west-2"
}

//Creates an sftp server in AWS using S3 and Transfer Family
//Requires terraform and aws cli access
//User name is: sftp_user
//To get the private key run:
//terraform output -raw private_key > ssh.key
//To apply: terraform init && terraform apply
//To destroy: terraform destroy

//Set up bucket
resource "aws_s3_bucket" "host_artifact_store" {
  bucket = "host-artifact-store"
  force_destroy = "true"
}

resource "aws_s3_bucket_ownership_controls" "host_artifact_store_oc" {
  bucket = aws_s3_bucket.host_artifact_store.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "host_artifact_store_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.host_artifact_store_oc]
  bucket = aws_s3_bucket.host_artifact_store.id
  acl    = "private"
}

//Setup sftp connector

resource "aws_transfer_server" "host_artifact_transfer_server" {
  endpoint_type = "PUBLIC"
  domain = "S3"
  protocols   = ["SFTP"]
  identity_provider_type = "SERVICE_MANAGED"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_role" {
  name               = "host_artifact_transfer_server_sftp_user_iam_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    sid       = "AllowFullAccesstoS3"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "iam_role_policy" {
  name   = "host_artifact_transfer_server_sftp_role_policy"
  role   = aws_iam_role.iam_role.id
  policy = data.aws_iam_policy_document.policy_document.json
}

resource "aws_transfer_user" "sftp_user" {
  server_id = aws_transfer_server.host_artifact_transfer_server.id
  user_name = "sftp_user"
  role      = aws_iam_role.iam_role.arn

  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${aws_s3_bucket.host_artifact_store.id}/$${Transfer:UserName}"
  }
}

//ssh sftp user keys

resource "tls_private_key" "user_ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_transfer_ssh_key" "sftp_user_ssh_key" {
  server_id = aws_transfer_server.host_artifact_transfer_server.id
  user_name = aws_transfer_user.sftp_user.user_name
  body      = tls_private_key.user_ssh_key.public_key_openssh
}


//outputs
output "private_key" {
  value = tls_private_key.user_ssh_key.private_key_pem
  sensitive=true
}

output "public_key" {
  value = tls_private_key.user_ssh_key.public_key_openssh
  sensitive=true
}

output "endpoint" {
  value = aws_transfer_server.host_artifact_transfer_server.endpoint  
}

output "ftp_user" {
  value = aws_transfer_user.sftp_user.user_name
}

//terraform apply -auto-approve && terraform output private_key


