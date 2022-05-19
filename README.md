# Redshift Spectrum

## Introduction

## Problem to solve

## Journey

## Architecture

### Environment creation

### AWS Service deployment

To start the deployment we'll validate the infrastructure code developed with Terraform. 
If you doesn't have Terraform installed, here we'll see two approach, installing from the repository and downloading the standalone version.

```sh
# Installing from repository
$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
$ sudo apt-get update && sudo apt-get install terraform
$ terraform -version
Terraform v1.1.9
on linux_amd64


# Standalone version
$ curl -o terraform.zip https://releases.hashicorp.com/terraform/1.1.9/terraform_1.1.9_linux_amd64.zip && unzip terraform.zip
$ ./terraform -version
Terraform v1.1.9
on linux_amd64
```

Now we'll need to initialize Terraform by running `terraform init`. Terraform will generate a directory named `.terraform` and download each module source declared in `main.tf` file.

There is a useful command to validate the terraform code before the plan `terraform validade`.

Following the best practices, always run the command `terraform plan -out=redshift-stack-plan` to review the output before start creating or changing existing resources.

After getting plan validated, it's possible to safely apply the changes by running `terraform apply "redshift-stack-plan"`. Terraform will do one last validation step and prompt for confirmation before applying.

## Conclusion

## We think and we do!
Do you have a business that requires an efficient and powerful data architecture to succeed? [Get in touch](https://www.whiteprompt.com/contact), we can help you to make it happen!
