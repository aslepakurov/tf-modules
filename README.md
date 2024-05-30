# Terraform Modules

This repository contains a collection of reusable Terraform modules.

## Modules

- [Users modules](modules/iam/users)
- [Roles modules](modules/iam/roles)

## Usage

To use a module, include it in your Terraform configuration like this:

```hcl
module "users" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/iam/users"
  ...
}

module "roles" {
  source = "git::https://github.com/aslepakurov/tf-modules.git//modules/iam/roles"
  ...
}
```