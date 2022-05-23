#####################################
# General 
#####################################

variable "region" {
  description = "The AWS region we want to deploy our services."
  default     = "us-east-1"
}

variable "region_az" {
  description = "The AWS region we want to deploy our services."
  default     = "us-east-1a"
}

variable "key_name" {
  default = "data-mgmt"
}

variable "subnet_id" {
  default = "subnet-d66e7eb1"
}

variable "vpc_id" {
  default = "vpc-94426eee"
}

variable "app_name" {
  description = "The common name for your deployment."
  default     = "redshift-spectrum"
}

variable "env_type" {
  description = "The environment that our resources will be deployed."
  default     = "dev"
}

variable "project_name" {
  description = "The project name that every resource is related to."
  default     = "Data Research - Redshift Spectrum"
}

variable "client_name" {
  description = "The team name that is responsible for this deployment."
  default     = "WP"
}

variable "s3_bucket_name" {
  default = "wp-lakehouse"
  description = "The bucket name used by the lakehouse."
}


#####################################
# Redshift 
#####################################

variable "redshift_cluster_name" {
  description = "Redshift cluster name"
  default = "wp-lakehouse-spectrum-poc"
}

variable "redshift_db_name" {
  description = "Redshift database name"
  default = "lakehouse_poc"
}

variable "redshift_admin_user_name" {
  description = "Redshift admin user name"
  default = "wpadmin"
}

variable "redshift_admin_user_password" {
  description = "Redshift admin password"
  default = "KmG4sg54HBcWq85n"
}

variable "redshift_node_type" {
  description = "Redshift cluster node type"
  default = "dc2.large"
}

variable "redshift_cluster_type" {
  description = "Redshift cluster type"
  default = "single-node"
}

#####################################
# Glue 
#####################################

variable "registry_name" {
  description = "The name of AWS Glue Schema Registry."
  default     = "whiteprompt-data-management"
}

variable "trusted_db" {
  description = "The common name for your deployment."
  default     = "wp_trusted_redshift"
}

variable "category_schema_json" {
  type        = string
  description = "A JSON file with the schema definition."
  default = "assets/glue_schemas/category_schema.json"
}

variable "tbldate_schema_json" {
  type        = string
  description = "A JSON file with the schema definition."
  default = "assets/glue_schemas/tbldate_schema.json"
}

variable "event_schema_json" {
  type        = string
  description = "A JSON file with the schema definition."
  default = "assets/glue_schemas/event_schema.json"
}

variable "listing_schema_json" {
  type        = string
  description = "A JSON file with the schema definition."
  default = "assets/glue_schemas/listing_schema.json"
}

variable "sales_schema_json" {
  type        = string
  description = "A JSON file with the schema definition."
  default = "assets/glue_schemas/sales_schema.json"
}

variable "user_schema_json" {
  type        = string
  description = "A JSON file with the schema definition."
  default = "assets/glue_schemas/user_schema.json"
}

variable "venue_schema_json" {
  type        = string
  description = "A JSON file with the schema definition."
  default = "assets/glue_schemas/venue_schema.json"
}

variable "schema_version_number" {
  type        = number
  description = "The common version number of schemas."
  default     = 1
}


variable "storage_input_format" {
  description = "Storage input format class for aws glue for parcing data."
  default     = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
}

variable "storage_output_format" {
  description = "Storage output format class for aws glue for parcing data."
  default     = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
}

variable "serde_name" {
  description = "The serialization library name."
  default     = "JsonSerDe"
}
variable "serde_library" {
  description = "The serialization library class."
  default     = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
}

#####################################
# EMR 
#####################################

variable "emr_cluster_name" {
  description = "EMR cluster name"
  default = "WP_Process_Redshift_Data"
}

variable "emr_step_concurrency_level" {
  default = 1
}

variable "emr_terminate_cluster" {
  default = false
}

variable "emr_release_label" {
  description = "EMR Version"
  default = "emr-6.5.0"
}

variable "emr_cluster_applications" {
  type    = list(string)
  description = "Name of the applications to be installed"
  default = ["Spark"]
}

variable "emr_instance_profile" {
  default =  "EMR_EC2_DefaultRole"
}

variable "emr_managed_service_security_group"{
  default =  "sg-xxxxxxxx"
}
  
variable "emr_managed_master_security_group" {
  default = "sg-09f2e5de468ebfc3e"
}

variable "emr_managed_slave_security_group" {
  default = "sg-06347ea1f8bb1e4c2"
}

variable "emr_service_role" {
  default = "EMR_DefaultRole"
}

variable "emr_configurations_json" {
  type        = string
  description = "A JSON file with a list of configurations for the EMR cluster"
  default = "assets/emr_config/configuration.json"
}  

variable "emr_log_uri" {
  default = "s3://wp-data-mgmt/emr-logs/"
}

variable "emr_steps" {
  type        = string
  description = "Steps to execute after creation of EMR cluster"
  default = "assets/emr_config/steps.json"
}

#------Master Instance Group------

variable "master_instance_group_name" {
  type        = string
  description = "Name of the Master instance group"
  default = "MasterGroup"
}

variable "master_instance_group_instance_type" {
  type        = string
  description = "EC2 instance type for all instances in the Master instance group"
  default = "m6g.xlarge"
}

variable "master_instance_group_instance_count" {
  type        = number
  description = "Target number of instances for the Master instance group. Must be at least 1"
  default     = 1
}

variable "master_instance_group_ebs_size" {
  type        = number
  description = "Master instances volume size, in gibibytes (GiB)"
  default = 30
}

variable "master_instance_group_ebs_type" {
  type        = string
  description = "Master instances volume type."
  default     = "gp2"
}


variable "master_instance_group_ebs_iops" {
  type        = number
  description = "The number of I/O operations per second (IOPS) that the Master volume supports"
  default     = null
}

variable "master_instance_group_ebs_volumes_per_instance" {
  type        = number
  description = "The number of EBS volumes with this configuration to attach to each EC2 instance in the Master instance group"
  default     = 1
}

variable "master_instance_group_bid_price" {
  type        = string
  description = "Bid price for each EC2 instance in the Master instance group, expressed in USD. By setting this attribute, the instance group is being declared as a Spot Instance, and will implicitly create a Spot request. Leave this blank to use On-Demand Instances"
  default     = 0.10
}

