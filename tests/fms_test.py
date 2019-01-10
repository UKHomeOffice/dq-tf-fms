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
              #opssubnet_cidr_block             = "1.2.3.0/24"
              fms_cidr_block                   = "10.1.40.0/24"
              fms_cidr_block_az2               = "10.1.41.0/24"
              #data_pipe_apps_cidr_block        = "1.2.3.0/24"
              peering_cidr_block               = "1.1.1.0/24"
              az                               = "eu-west-2a"
              az2                              = "eu-west-2b"
              naming_suffix                    = "apps-preprod-dq"
            }
        """
        self.result = Runner(self.snippet).result

    def test_root_destroy(self):
        self.assertEqual(self.result["destroy"], False)

    def test_fms(self):
        self.assertEqual(self.result['fms']["aws_subnet.fms"]["cidr_block"], "10.1.40.0/24")

    def test_name_suffix_fms(self):
        self.assertEqual(self.result['fms']["aws_subnet.fms"]["tags.Name"], "subnet-fms-apps-preprod-dq")

    #def test_name_suffix_fms_rds(self):
    #    self.assertEqual(self.result['fms']["aws_security_group.fms_rds"]["tags.Name"],"sg-db-fms-apps-preprod-dq")

    #def test_subnet_group(self):
    #    self.assertEqual(self.result['fms']["aws_db_subnet_group.rds"]["tags.Name"], "rds-subnet-group-datafeeds-apps-preprod-dq")

    #def test_az2_subnet(self):
    #    self.assertEqual(self.result['fms']["aws_subnet.fms_az2"]["tags.Name"], "az2-subnet-fms-apps-preprod-dq")

    #def test_rds_name(self):
    #    self.assertEqual(self.result['fms']["aws_db_instance.postgres"]["tags.Name"],"ext-postgres-datafeeds-apps-preprod-dq")

    #def test_rds_id(self):
    #    self.assertEqual(self.result['fms']["aws_db_instance.postgres"]["identifier"], "ext-postgres-datafeeds-apps-preprod-dq")

if __name__ == '__main__':
    unittest.main()
