# =============================================================================
# ONE-TIME MANUAL SNAPSHOT BEFORE RDS UPGRADE
# This will create the snapshot ONLY ONCE (on first apply)
# =============================================================================
resource "aws_db_snapshot" "fms_manual_snapshot" {
  db_instance_identifier = aws_db_instance.postgres.identifier # Use .identifier, not .id
  db_snapshot_identifier = "fms-pre-upgrade-20260326"

  # Optional but recommended tags
  tags = {
    Name        = "fms-pre-upgrade-20260331"
    Purpose     = "pre-rds-upgrade"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }

  # This ensures it runs after the RDS instance exists
  depends_on = [aws_db_instance.postgres]

  # This makes sure Terraform never tries to delete or recreate it
  #lifecycle {
  #  ignore_changes = [db_snapshot_identifier]
  #}
}
