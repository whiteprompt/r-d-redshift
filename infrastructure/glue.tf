resource "aws_glue_registry" "glue_registry" {
  registry_name = "${var.registry_name}"
  tags = {
    EnvType = "${var.env_type}"
    Project = "${var.project_name}"
    Client  = "${var.client_name}"
  }
}

resource "aws_glue_catalog_database" "aws_glue_database_trusted" {
  name = "${var.trusted_db}"
}

resource "aws_glue_schema" "event" {
  schema_name       = "event"
  registry_arn      = aws_glue_registry.glue_registry.arn
  data_format       = "JSON"
  compatibility     = "FULL_ALL"
  schema_definition = file(var.event_schema_json)
}

resource "aws_glue_schema" "user" {
  schema_name       = "user"
  registry_arn      = aws_glue_registry.glue_registry.arn
  data_format       = "JSON"
  compatibility     = "FULL_ALL"
  schema_definition = file(var.user_schema_json)
}

resource "aws_glue_schema" "category" {
  schema_name       = "category"
  registry_arn      = aws_glue_registry.glue_registry.arn
  data_format       = "JSON"
  compatibility     = "FULL_ALL"
  schema_definition = file(var.category_schema_json)
}

resource "aws_glue_schema" "listing" {
  schema_name       = "listing"
  registry_arn      = aws_glue_registry.glue_registry.arn
  data_format       = "JSON"
  compatibility     = "FULL_ALL"
  schema_definition = file(var.listing_schema_json)
}

resource "aws_glue_schema" "sales" {
  schema_name       = "sales"
  registry_arn      = aws_glue_registry.glue_registry.arn
  data_format       = "JSON"
  compatibility     = "FULL_ALL"
  schema_definition = file(var.sales_schema_json)
}

resource "aws_glue_schema" "venue" {
  schema_name       = "venue"
  registry_arn      = aws_glue_registry.glue_registry.arn
  data_format       = "JSON"
  compatibility     = "FULL_ALL"
  schema_definition = file(var.venue_schema_json)
}


resource "aws_glue_catalog_table" "aws_glue_table_event_trusted" {
  name          = "${aws_glue_schema.event.schema_name}"
  database_name = "${aws_glue_catalog_database.aws_glue_database_trusted.name}"

  parameters = {
    EXTERNAL          = "TRUE"
    "classification"  = "parquet"
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket_name}/trusted/${aws_glue_schema.event.schema_name}/"
    input_format  = "${var.storage_input_format}"
    output_format = "${var.storage_output_format}"

    ser_de_info {
      name                  = "${var.serde_name}"
      serialization_library = "${var.serde_library}"

      parameters = {
        "serialization.format" = 1
        "parquet.compression"  = "SNAPPY"
      }
    }

    schema_reference {
      schema_id {
        registry_name = "${aws_glue_registry.glue_registry.registry_name}"
        schema_name   = "${aws_glue_schema.event.schema_name}"
      }
      schema_version_number = "${var.schema_version_number}"

    }
  }
}


resource "aws_glue_catalog_table" "aws_glue_table_user_trusted" {
  name          = "${aws_glue_schema.user.schema_name}"
  database_name = "${aws_glue_catalog_database.aws_glue_database_trusted.name}"

  parameters = {
    EXTERNAL          = "TRUE"
    "classification"  = "parquet"
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket_name}/trusted/${aws_glue_schema.user.schema_name}/"
    input_format  = "${var.storage_input_format}"
    output_format = "${var.storage_output_format}"

    ser_de_info {
      name                  = "${var.serde_name}"
      serialization_library = "${var.serde_library}"

      parameters = {
        "serialization.format" = 1
        "parquet.compression"  = "SNAPPY"
      }
    }

    schema_reference {
      schema_id {
        registry_name = "${aws_glue_registry.glue_registry.registry_name}"
        schema_name   = "${aws_glue_schema.user.schema_name}"
      }
      schema_version_number = "${var.schema_version_number}"

    }
  }
}


resource "aws_glue_catalog_table" "aws_glue_table_category_trusted" {
  name          = "${aws_glue_schema.category.schema_name}"
  database_name = "${aws_glue_catalog_database.aws_glue_database_trusted.name}"

  parameters = {
    EXTERNAL          = "TRUE"
    "classification"  = "parquet"
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket_name}/trusted/${aws_glue_schema.category.schema_name}/"
    input_format  = "${var.storage_input_format}"
    output_format = "${var.storage_output_format}"

    ser_de_info {
      name                  = "${var.serde_name}"
      serialization_library = "${var.serde_library}"

      parameters = {
        "serialization.format" = 1
        "parquet.compression"  = "SNAPPY"
      }
    }

    schema_reference {
      schema_id {
        registry_name = "${aws_glue_registry.glue_registry.registry_name}"
        schema_name   = "${aws_glue_schema.category.schema_name}"
      }
      schema_version_number = "${var.schema_version_number}"

    }
  }
}


resource "aws_glue_catalog_table" "aws_glue_table_listing_trusted" {
  name          = "${aws_glue_schema.listing.schema_name}"
  database_name = "${aws_glue_catalog_database.aws_glue_database_trusted.name}"

  parameters = {
    EXTERNAL          = "TRUE"
    "classification"  = "parquet"
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket_name}/trusted/${aws_glue_schema.listing.schema_name}/"
    input_format  = "${var.storage_input_format}"
    output_format = "${var.storage_output_format}"

    ser_de_info {
      name                  = "${var.serde_name}"
      serialization_library = "${var.serde_library}"

      parameters = {
        "serialization.format" = 1
        "parquet.compression"  = "SNAPPY"
      }
    }

    schema_reference {
      schema_id {
        registry_name = "${aws_glue_registry.glue_registry.registry_name}"
        schema_name   = "${aws_glue_schema.listing.schema_name}"
      }
      schema_version_number = "${var.schema_version_number}"

    }
  }
}


resource "aws_glue_catalog_table" "aws_glue_table_sales_trusted" {
  name          = "${aws_glue_schema.sales.schema_name}"
  database_name = "${aws_glue_catalog_database.aws_glue_database_trusted.name}"

  parameters = {
    EXTERNAL          = "TRUE"
    "classification"  = "parquet"
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket_name}/trusted/${aws_glue_schema.sales.schema_name}/"
    input_format  = "${var.storage_input_format}"
    output_format = "${var.storage_output_format}"

    ser_de_info {
      name                  = "${var.serde_name}"
      serialization_library = "${var.serde_library}"

      parameters = {
        "serialization.format" = 1
        "parquet.compression"  = "SNAPPY"
      }
    }

    schema_reference {
      schema_id {
        registry_name = "${aws_glue_registry.glue_registry.registry_name}"
        schema_name   = "${aws_glue_schema.sales.schema_name}"
      }
      schema_version_number = "${var.schema_version_number}"

    }
  }
}


resource "aws_glue_catalog_table" "aws_glue_table_venue_trusted" {
  name          = "${aws_glue_schema.venue.schema_name}"
  database_name = "${aws_glue_catalog_database.aws_glue_database_trusted.name}"

  parameters = {
    EXTERNAL          = "TRUE"
    "classification"  = "parquet"
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket_name}/trusted/${aws_glue_schema.venue.schema_name}/"
    input_format  = "${var.storage_input_format}"
    output_format = "${var.storage_output_format}"

    ser_de_info {
      name                  = "${var.serde_name}"
      serialization_library = "${var.serde_library}"

      parameters = {
        "serialization.format" = 1
        "parquet.compression"  = "SNAPPY"
      }
    }

    schema_reference {
      schema_id {
        registry_name = "${aws_glue_registry.glue_registry.registry_name}"
        schema_name   = "${aws_glue_schema.venue.schema_name}"
      }
      schema_version_number = "${var.schema_version_number}"

    }
  }
}


