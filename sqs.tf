# Queues invoice IDs for asynchronous PDF generation.
resource "aws_sqs_queue" "invoice_pdf_jobs" {
  name                       = "${var.name_prefix}-invoice-pdf-jobs"
  visibility_timeout_seconds = 300
  sqs_managed_sse_enabled    = true

  tags = {
    Name = "${var.name_prefix}-invoice-pdf-jobs"
  }
}
