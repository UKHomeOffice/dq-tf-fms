# =============================================================================
# MANUAL PRE-UPGRADE SNAPSHOT (DISABLED BY DEFAULT)
# This resource does NOTHING in the pipeline until you change count = 1
# =============================================================================

resource "aws_db_snapshot" "fms_manual_snapshot" {
  count = 1 # ← Change to 1 ONLY when you want to create the snapshot

  db_instance_identifier = aws_db_instance.postgres.identifier
  db_snapshot_identifier = "fms-pre-upgrade-${local.naming_suffix}-${formatdate("YYYYMMDDHHmmss", timestamp())}"

  tags = {
    Name        = "fms-pre-upgrade-${local.naming_suffix}"
    Purpose     = "pre-rds-upgrade"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }

  depends_on = [aws_db_instance.postgres]

  lifecycle {
    ignore_changes = [
      db_snapshot_identifier,
      tags
    ]
  }
}