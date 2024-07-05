# Terraform Modules

This repository contains a collection of reusable Terraform modules.

## Modules

- [Users modules](modules/iam/users)
- [Roles modules](modules/iam/roles)
- [Network](modules/network)
- [Backend](modules/service)
- [Web](modules/web-static)

## Usage

To use a module, include it in your Terraform configuration like this:

### Users

```hcl
module "iam_users" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/users"

  iam_user_name = "example-user"

  policy_files = {
    "example-policy-1" = "path/to/policy1.json"
    "example-policy-2" = "path/to/policy2.json"
  }

  tags = {
    "Environment" = "dev"
    "Project"     = "example-project"
  }
}
```

### Roles 

```hcl
module "iam_roles" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/roles"
  
  iam_role_name         = "example-role"
  iam_role_description  = "An example IAM role"
  assume_file           = "path/to/assume1.json"
  iam_role_max_session  = 3600

  policy_files = {
    "example-policy-1" = "path/to/policy1.json"
    "example-policy-2" = "path/to/policy2.json"
  }

  tags = {
    "Environment" = "dev"
    "Project"     = "example-project"
  }
}
```
