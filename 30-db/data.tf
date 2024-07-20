data "aws_ssm_parameter" "db_sg_id" {
  name = "/${var.project}/${var.environment}/db_sg_id"
}

data "aws_ssm_parameter" "db-subnet-group-name" {
  name = "/${var.project}/${var.environment}/db-subnet-group-name"
}