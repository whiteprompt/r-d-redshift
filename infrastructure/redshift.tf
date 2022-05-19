resource "aws_redshift_subnet_group" "lakehouse_subnet_grp" {
  name = "${var.redshift_cluster_name}-subnet-group"

  subnet_ids = [
    "${var.subnet_id}"
  ]
}

resource "aws_redshift_parameter_group" "lakehouse_param_grp" {
  name   = "${var.redshift_cluster_name}-parameter-group"
  family = "redshift-1.0"

  parameter {
    name  = "require_ssl"
    value = "true"
  }

  parameter {
    name  = "query_group"
    value = "lakehouse_poc"
  }
}

resource "aws_redshift_cluster" "lakehouse_poc" {
  cluster_identifier = "${var.redshift_cluster_name}"
  database_name      = "${var.redshift_db_name}"
  master_username    = "${var.redshift_admin_user_name}"
  master_password    = "${var.redshift_admin_user_password}"
  node_type          = "${var.redshift_node_type}"
  number_of_nodes    = 1
  cluster_type       = "${var.redshift_cluster_type}"
  encrypted          = false
  port               = 5439

  allow_version_upgrade               = false
  automated_snapshot_retention_period = 7
  preferred_maintenance_window        = "sun:00:00-sun:00:30"
  publicly_accessible                 = true
  skip_final_snapshot                 = true
  availability_zone                   = "${var.region}"

  cluster_subnet_group_name    = "${aws_redshift_subnet_group.lakehouse_subnet_grp.name}"
  cluster_parameter_group_name = "${aws_redshift_parameter_group.lakehouse_param_grp.name}"
  iam_roles = [
    "${aws_iam_role.lakehouse_role.arn}"
  ]
  vpc_security_group_ids = [
    "${aws_security_group.lakehouse_poc_sg.id}"
  ]

  logging {
    enable = false
  }

  tags = {
    Name    = "${var.redshift_cluster_name}"
    EnvType = "${var.env_type}"
    Project = "${var.project_name}"
    Client  = "${var.client_name}"
  }

}

