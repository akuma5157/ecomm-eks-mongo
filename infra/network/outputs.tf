output "vpc_id" {
  value = module.vpc.vpc_id
}
output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}
output "private_subnets" {
  value = module.vpc.private_subnets
}
output "private_subnets_build" {
  value = data.aws_subnet_ids.build
}

output "private_subnets_app" {
  value = data.aws_subnet_ids.app
}

output "private_subnets_db" {
  value = data.aws_subnet_ids.db
}

output "public_subnets_bastion" {
  value = data.aws_subnet_ids.bastion
}
output "public_subnets" {
  value = module.vpc.public_subnets
}
output "key-name" {
  value = aws_key_pair.sshkey.key_name
}
output "availability_zones" {
  value = data.aws_availability_zones.available.names
}
