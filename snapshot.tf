###############################################################################
# AUTO‑DISABLING MANUAL SNAPSHOT (CREATES ONCE, NEVER DELETES)
###############################################################################

# 1. Check if snapshot already exists
data "aws_db_snapshot" "existing_snapshot" {
  db_snapshot_identifier = "snapshot-fms-pre-upgrade-${local.naming_suffix}"
  most_recent            = true
}

# 2. If snapshot exists → no creation
locals {
  snapshot_exists = try(data.aws_db_snapshot.existing_snapshot.id, "") != ""
}

# 3. Create snapshot ONLY IF it does not exist
resource "aws_db_snapshot" "fms_manual_snapshot" {
  count = local.snapshot_exists ? 0 : 1

  db_instance_identifier = aws_db_instance.postgres.identifier
  db_snapshot_identifier = "snapshot-fms-pre-upgrade-${local.naming_suffix}"

  tags = {
    Name        = "snapshot-fms-pre-upgrade-${local.naming_suffix}"
    Purpose     = "pre-rds-upgrade"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }

  depends_on = [aws_db_instance.postgres]
}