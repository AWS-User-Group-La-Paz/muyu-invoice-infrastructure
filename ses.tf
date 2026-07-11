# Registers the address used by the worker to email generated invoices.
resource "aws_sesv2_email_identity" "invoice_sender" {
  email_identity = var.email_from
}
