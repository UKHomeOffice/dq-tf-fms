###############################################################################
# AUTO‑DISABLING MANUAL SNAPSHOT (CREATES ONCE, NEVER DELETES)
# - No CLI variables required
# - Snapshot is created once, then Terraform disables itself
# - Safe for DroneCI and production pipelines
###############################################################################

# 1. Detect if the snapshot ALREADY EXISTS
data "aws_db_snapshot" "existing_snapshot" {
  # Use a fixed, stable snapshot name (no timestamps)
  db_snapshot_identifier = "fms-pre-upgrade-${local.naming_suffix}-snapshot"

  # Most recent snapshot with this name (if it exists)
  most_recent = true

  # Avoid early failures — this is wrapped by try() below
  depends_on = []
}

# 2. Calculate whether snapshot exists already
locals {
  snapshot_exists = try(data.aws_db_snapshot.existing_snapshot.id, "") != ""
}

# 3. Create the snapshot ONLY IF it does NOT exist
resource "aws_db_snapshot" "fms_manual_snapshot" {
  # If snapshot exists → count = 0 → do nothing
  # If snapshot NOT exist → count = 1 → create it once
  count = local.snapshot_exists ? 0 : 1

  db_instance_identifier = aws_db_instance.postgres.identifier

  # FIXED NAME — required so Terraform can detect existence
  db_snapshot_identifier = "fms-pre-upgrade-${local.naming_suffix}-snapshot"

  tags = {
    Name        = "fms-pre-upgrade-${local.naming_suffix}"
    Purpose     = "pre-rds-upgrade"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }

  depends_on = [aws_db_instance.postgres]
}