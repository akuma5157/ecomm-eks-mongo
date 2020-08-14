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
  value = [for id in data.aws_subnet_ids.build.ids : id]
}

output "private_subnets_app" {
  value = [for id in data.aws_subnet_ids.app.ids : id]
}

output "private_subnets_db" {
  value = [for id in data.aws_subnet_ids.db.ids : id]
}

output "public_subnets_bastion" {
  value = [for id in data.aws_subnet_ids.bastion.ids : id]
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
