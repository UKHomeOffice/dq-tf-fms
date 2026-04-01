###############################################################################
# SAFE ONE‑TIME SNAPSHOT CREATION (NO STATE EDITS, NO PIPELINE FAILURES)
###############################################################################

# 1. List all snapshots matching our wanted name (zero results = OK)
data "aws_db_snapshots" "existing_snapshot" {
  db_instance_identifier = aws_db_instance.postgres.identifier

  # Filter by consistent snapshot name (NO timestamp!)
  snapshot_type = "manual"

  # We will filter names in the locals block
}

# 2. Determine if snapshot already exists
locals {
  snapshot_name    = "fms-pre-upgrade-${local.naming_suffix}"
  snapshot_matches = [
    for s in data.aws_db_snapshots.existing_snapshot.ids :
    s if substr(s, length(s) - length(local.snapshot_name), length(local.snapshot_name)) == local.snapshot_name
  ]
  snapshot_exists = length(local.snapshot_matches) > 0
}

# 3. Create snapshot ONLY IF NONE EXISTS
resource "aws_db_snapshot" "fms_manual_snapshot" {
  count = local.snapshot_exists ? 0 : 1

  db_instance_identifier = aws_db_instance.postgres.identifier

  # Fixed name → allows existence detection
  db_snapshot_identifier = local.snapshot_name

  tags = {
    Name        = local.snapshot_name
    Purpose     = "pre-rds-upgrade"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }

  depends_on = [aws_db_instance.postgres]
}