# Stores generated invoice PDFs until the workshop deployment is destroyed.
resource "aws_s3_bucket" "invoice_pdfs" {
  bucket        = "${var.name_prefix}-invoice-pdfs"
  force_destroy = true

  tags = {
    Name = "${var.name_prefix}-invoice-pdfs"
  }
}

# Keeps generated invoice PDFs private.
resource "aws_s3_bucket_public_access_block" "invoice_pdfs" {
  bucket = aws_s3_bucket.invoice_pdfs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
