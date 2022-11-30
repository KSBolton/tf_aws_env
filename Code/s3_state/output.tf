# //////////////////////////////
# S3 BUCKET
# //////////////////////////////

output "bucket_id" {
  # The name of the bucket.
  value = [for bucket in aws_s3_bucket.assignment1_bucket: bucket.id]
}