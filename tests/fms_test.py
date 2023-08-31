# pylint: disable=missing-docstring, line-too-long, protected-access, E1101, C0202, E0602, W0109
import unittest
from runner import Runner

class TestE2E(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.snippet = """

            provider "aws" {
              region = "eu-west-2"
              skip_credentials_validation = true
              skip_get_ec2_platforms = true
            }

            module "fms" {
              source = "./mymodule"

              providers = {
                aws = "aws"
              }

              appsvpc_id                       = "1234"
              opssubnet_cidr_block             = "1.2.3.0/24"
              fms_cidr_block                   = "10.1.40.0/24"
              fms_cidr_block_az2               = "10.1.41.0/24"
              peering_cidr_block               = "1.1.1.0/24"
              az                               = "eu-west-2a"
              az2                              = "eu-west-2b"
              naming_suffix                    = "apps-preprod-dq"
              environment                      = "prod"
              rds_enhanced_monitoring_role     = "arn:aws:iam::123456789:role/rds-enhanced-monitoring-role"

            }
        """
        self.runner = Runner(self.snippet)
        self.result = self.runner.result

    def test_fms(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_subnet.fms", "cidr_block"), "10.1.40.0/24")

    def test_name_suffix_fms(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_subnet.fms", "tags"), {'Name': "subnet-fms-apps-preprod-dq"})

    def test_name_suffix_fms_rds(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_security_group.fms_db", "tags"), {'Name': "sg-db-fms-apps-preprod-dq"})

    def test_name_suffix_az2_subnet(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_subnet.fms_az2", "tags"), {'Name': "az2-subnet-fms-apps-preprod-dq"})

    def test_name_suffix_az1_subnet(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_subnet.fms", "tags"), {'Name': "subnet-fms-apps-preprod-dq"})

    def test_name_suffix_subnet_group(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_db_subnet_group.rds", "tags"), {'Name': "rds-subnet-group-fms-apps-preprod-dq"})

    def test_name_suffix_rds_instance(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_db_instance.postgres", "tags"), {'Name': "postgres-fms-apps-preprod-dq"})

    def test_rds_deletion_protection(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_db_instance.postgres", "deletion_protection"), True)

    def test_rds_fms_service_username(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_ssm_parameter.rds_fms_service_username", "name"), "rds_fms_service_username")

    def test_rds_fms_service_username_type(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_ssm_parameter.rds_fms_service_username", "type"), "SecureString")

    def test_rds_fms_service_password(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_ssm_parameter.rds_fms_service_password", "name"), "rds_fms_service_password")

    def test_rds_fms_service_password_type(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_ssm_parameter.rds_fms_service_password", "type"), "SecureString")

    def test_rds_fms_backup_window(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_db_instance.postgres", "backup_window"), "00:00-01:00")

    def test_rds_fms_maintenance_window(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_db_instance.postgres", "maintenance_window"), "tue:01:00-tue:02:00")

    def test_rds_fms_engine_version(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_db_instance.postgres", "engine_version"), "14.7")

    def test_rds_fms_apply_immediately(self):
        self.assertEqual(self.runner.get_value("module.fms.aws_db_instance.postgres", "apply_immediately"), False)

if __name__ == '__main__':
    unittest.main()
