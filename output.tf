output "darlington-ip-address" {
    value = "aws_instance.set14.public_ip"
}


output "s3-bucket-arn" {
    value = "aws_s3_bucket.set14-s3-backend.arn"
}