# Lets the web process queue invoices and download completed PDFs.
resource "aws_iam_role_policy" "invoice_web" {
  name = "${var.name_prefix}-invoice-web-policy"
  role = module.invoice_service.task_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.invoice_pdf_jobs.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.invoice_pdfs.arn}/invoices/*"
      }
    ]
  })
}

# Lets the worker consume jobs, store PDFs, and email invoices.
resource "aws_iam_role_policy" "invoice_worker" {
  name = "${var.name_prefix}-invoice-worker-policy"
  role = module.invoice_worker.task_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
        ]
        Resource = aws_sqs_queue.invoice_pdf_jobs.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.invoice_pdfs.arn}/invoices/*"
      },
      {
        Effect   = "Allow"
        Action   = ["ses:SendRawEmail"]
        Resource = "*"
      }
    ]
  })
}
