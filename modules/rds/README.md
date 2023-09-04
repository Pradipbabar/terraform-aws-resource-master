# Terraform Module: pradipbabar/resource-master/rds

This Terraform module deploys an Amazon RDS database instance in AWS. It includes the creation of a DB subnet group and the associated security groups. You can configure various aspects of the RDS instance, including its engine, storage, instance class, database name, username, and password.

## Usage

```hcl
module "my_rds_instance" {
  source = "Pradipbabar/resource-master/aws//modules/rds"

  rds_identifier            = "my-db-instance"
  rds_allocated_storage     = 20
  rds_storage_type          = "gp2"
  rds_multi_az              = false
  rds_engine                = "postgres"
  rds_engine_version        = "12.6"
  rds_instance_class        = "db.t2.micro"
  rds_database_name         = "mydatabase"
  username                  = "dbuser"
  password                  = "dbpassword"
  rds_port                  = 5432
  rds_public_access         = false
  final_snapshot_identifier = "my-final-snapshot"
  vpc_security_group_ids    = [module.security_groups.my_security_group_id]
  db_subnet_group_name      = "my-db-subnet-group"
  subnet_ids                = [module.vpc.public_subnet_1a_id, module.vpc.public_subnet_1b_id]
}
```

## Inputs

| Name                          | Description                                   | Type       | Default       | Required |
| ----------------------------- | --------------------------------------------- | ---------- | ------------- | :------: |
| rds_identifier                | The identifier for the RDS instance.         | string     |               |   yes    |
| rds_allocated_storage         | The amount of allocated storage (in GB).     | number     |               |   yes    |
| rds_storage_type              | The type of storage for the RDS instance.   | string     |               |   yes    |
| rds_multi_az                  | Enable Multi-AZ deployment (true/false).    | bool       |               |   yes    |
| rds_engine                    | The name of the database engine to be used. | string     |               |   yes    |
| rds_engine_version            | The database engine version.                | string     |               |   yes    |
| rds_instance_class            | The RDS instance class.                     | string     |               |   yes    |
| rds_database_name             | The name of the initial database.           | string     |               |   yes    |
| username                      | The master username for the database.       | string     |               |   yes    |
| password                      | The master password for the database.       | string     |               |   yes    |
| rds_port                      | The port on which the database accepts connections. | number |               |   yes    |
| rds_public_access             | Allow the RDS instance to be publicly accessible (true/false). | bool |               |   yes    |
| final_snapshot_identifier     | The identifier for the final DB snapshot.   | string     |               |   yes    |
| vpc_security_group_ids        | List of security group IDs to associate with the RDS instance. | list(string) | [] |   yes    |
| db_subnet_group_name          | Name of the DB subnet group to associate with the RDS instance. | string | "" |   yes    |
| subnet_ids                    | List of subnet IDs for the DB subnet group. | list(string) | [] |   yes    |

## Outputs

| Name                  | Description                             |
| --------------------- | --------------------------------------- |
| rds_instance_id       | The ID of the RDS instance.             |
| rds_instance_endpoint | The endpoint of the RDS instance.       |

## Notes

- The module assumes that you have already defined and configured the `security_groups` and `vpc` modules. Adjust the module references accordingly.
- Make sure to set the necessary values for your specific database configuration.
- The `final_snapshot_identifier` is used for creating a final DB snapshot before destroying the RDS instance, ensuring data retention.
- You can customize other attributes such as backup retention policies, monitoring, and maintenance windows as needed.