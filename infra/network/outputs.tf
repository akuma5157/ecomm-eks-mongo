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
    value = slice(module.vpc.private_subnets, 0, 3)
//  value = [for s in data.aws_subnet.build : s.id]
}

output "private_subnets_app" {
  value = slice(module.vpc.private_subnets, 3, 6)
//  value = [for s in data.aws_subnet.app : s.id]
}

output "private_subnets_db" {
    value = slice(module.vpc.private_subnets, 6, 9)
//  value = [for s in data.aws_subnet.db : s.id]
}

output "public_subnets_bastion" {
    value = module.vpc.public_subnets
//  value = [for s in data.aws_subnet.bastion: s.id]
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
