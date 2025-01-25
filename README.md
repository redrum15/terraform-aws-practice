# Terraform x AWS

Repository for creating multiple AWS resources using Terraform.

## Installation

* [Install last version of AWS Cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). 
* [Install last version of Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

## Usage

Set your AWS key credentials
```bash
aws configure
```
In the repo directory run
```bash
terraform init
```

To see the changes to apply
```bash
terraform plan
```
To apply the changes
```bash
terraform apply
```

## License

[MIT](https://choosealicense.com/licenses/mit/)