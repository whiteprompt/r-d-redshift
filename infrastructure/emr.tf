resource "aws_emr_cluster" "cluster" {
  name           = "${var.emr_cluster_name}"
  release_label  = "${var.emr_release_label}"
  applications   = "${var.emr_cluster_applications}"
  termination_protection = false
  configurations_json = file(var.configurations_json)
  log_uri      = "${var.emr_log_uri}"
  service_role = "${var.emr_service_role}"
  
  dynamic "step" {
    for_each = jsondecode(templatefile("${var.emr_steps}", {}))
    content {
      action_on_failure = step.value.action_on_failure
      name              = step.value.name
      hadoop_jar_step {
        jar  = step.value.hadoop_jar_step.jar
        args = step.value.hadoop_jar_step.args
      }
    }
  }

  step_concurrency_level = "${var.emr_step_concurrency_level}"
  keep_job_flow_alive_when_no_steps = "${var.emr_terminate_cluster}"

  ec2_attributes {
    key_name                          = "${var.key_name}"
    subnet_id                         = "${var.subnet_id}"
    emr_managed_master_security_group = "${var.emr_managed_master_security_group}"
    emr_managed_slave_security_group  = "${var.emr_managed_slave_security_group}"
    #service_access_security_group = "${var.service_access_security_group}"
    instance_profile               = "${var.emr_instance_profile}"
  }


master_instance_group {
      name           = "${var.master_instance_group_name}"
      instance_type  = "${var.master_instance_group_instance_type}"
      instance_count = "${var.master_instance_group_instance_count}"
      bid_price      = "${var.master_instance_group_bid_price}"    
      ebs_config {
                    #iops = "${var.master_instance_group_ebs_iops}"
                    size = "${var.master_instance_group_ebs_size}"
                    type = "${var.master_instance_group_ebs_type}"
                    volumes_per_instance = "${var.master_instance_group_ebs_volumes_per_instance}"
                    }
}

bootstrap_action {
    path = "s3://wp-data-mgmt/emr-bootstrap-actions/emr_bootstrap_redshift.sh"
    name = "Install packages"
    args = []
}
  tags = {
    Name    = "${var.emr_cluster_name}"
    EnvType = "${var.env_type}"
    Project = "${var.project_name}"
    Client  = "${var.client_name}"
  }

}