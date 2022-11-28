output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet1_id" {
  value = aws_subnet.subnet1.id
}

output "subnet2_id" {
  value = aws_subnet.subnet2.id
}

output "subnet3_id" {
  value = aws_subnet.subnet3.id
}

output "subnet4_id" {
  value = aws_subnet.subnet4.id
}

output "alb_dns_name" {
  description = "alb dns"
  value       = aws_alb.alb1.dns_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.my-s3-bucket.id
}
output "s3_bucket_region" {
    value = aws_s3_bucket.my-s3-bucket.region
}

output "private_key" {
  value     = tls_private_key.pk.private_key_pem
  sensitive = true
}