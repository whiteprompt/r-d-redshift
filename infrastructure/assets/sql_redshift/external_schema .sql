CREATE EXTERNAL SCHEMA wp_spectrum FROM DATA CATALOG 
DATABASE 'wp_trusted_redshift' 
IAM_ROLE 'arn:aws:iam::ACCOUNT_ID:role/wp-lakehouse-spectrum-poc-redshift-role'