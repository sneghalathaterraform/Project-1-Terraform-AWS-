module "vpc" {
  source = "../../modules/vpc"

  cidr_block         = var.vpc_cidr_block
  env                = var.environment
  project            = var.project
  enable_nat_gateway = false
}

module "iam" {
  source = "../../modules/iam"
  
  project     = var.project
  env         = var.environment
  bucket_name = var.bucket_name
}

module "ec2" {
  source = "../../modules/ec2"
  
  instance_type        = var.instance_type
  env                  = var.environment
  aws_region           = var.aws_region
  project              = var.project
  subnet_id            = module.vpc.public_subnet_id
  iam_instance_profile = module.iam.ec2_instance_profile_name
}

module "s3" {
  source = "../../modules/s3"
  
  bucket_name = var.bucket_name
  env         = var.environment
  project     = var.project
}
