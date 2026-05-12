output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = module.ec2.instance_id
}

output "ec2_private_ip" {
  description = "EC2 Private IP"
  value       = module.ec2.private_ip
}

output "ec2_public_ip" {
  description = "EC2 Public IP"
  value       = module.ec2.public_ip
}

output "s3_bucket_name" {
  description = "S3 Bucket Name"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "S3 Bucket ARN"
  value       = module.s3.bucket_arn
}
