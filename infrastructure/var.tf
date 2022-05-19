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

variable "date_schema_json" {
  type        = string
  description = "A JSON file with the schema definition."
  default = "assets/glue_schemas/date_schema.json"
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