# regula-action

[Regula] is a tool that evaluates CloudFormation and Terraform infrastructure-as-code for potential AWS, Azure, and Google Cloud security misconfigurations and compliance violations prior to deployment. This is a [GitHub Action] to run [Regula] against your repository.

## Example

Here's an example workflow file.  It checks three different IaC configurations: one Terraform directory and two CloudFormation templates:

```yaml
on: [push]

jobs:
  regula_tf_job:
    runs-on: ubuntu-latest
    name: Regula Terraform
    steps:
    - uses: actions/checkout@master
    - uses: fugue/regula-action@b9c14d3af0333de617bb5258e21d5823d6762939
      with:
        input_path: infra_tf
        rego_paths: |
          /opt/regula/rules
          example_custom_rule
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

  regula_cfn_job:
    runs-on: ubuntu-latest
    name: Regula CloudFormation
    steps:
    - uses: actions/checkout@master
    - uses: fugue/regula-action@b9c14d3af0333de617bb5258e21d5823d6762939
      with:
        input_path: infra_cfn/cloudformation.yaml
        rego_paths: /opt/regula/rules

  regula_valid_cfn_job:
    runs-on: ubuntu-latest
    name: Regula Valid CloudFormation
    steps:
    - uses: actions/checkout@master
    - uses: fugue/regula-action@b9c14d3af0333de617bb5258e21d5823d6762939
      with:
        input_path: infra_valid_cfn/cloudformation.yaml
        rego_paths: /opt/regula/rules

  regula_multi_cfn_job:
    runs-on: ubuntu-latest
    name: Regula multiple CloudFormation templates
    steps:
    - uses: actions/checkout@master
    - uses: fugue/regula-action@b9c14d3af0333de617bb5258e21d5823d6762939
      with:
        input_path: '*/cloudformation.yaml'
        rego_paths: /opt/regula/rules

  regula_input_list_job:
    runs-on: ubuntu-latest
    name: Regula on CloudFormation and Terraform
    steps:
    - uses: actions/checkout@master
    - uses: fugue/regula-action@b9c14d3af0333de617bb5258e21d5823d6762939
      with:
        input_path: |
          infra_cfn/cloudformation.yaml
          infra_valid_cfn/cloudformation.yaml
          infra_tf
        rego_paths: /opt/regula/rules
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

You can see this example in action in the
[regula-ci-example](https://github.com/fugue/regula-ci-example).

## Inputs

-   `input_path`: One or more Terraform project directories, Terraform JSON plans, or CloudFormation templates. Accepts space-separated filenames and/or globbing expressions.
    This defaults to `.` (the root of your repository).
-   `rego_paths`: all paths that need to be passed to OPA.  This is typically
    `/opt/regula/rules`, which contains some default Regula rules, but you can
    also pass paths within your repository for custom checks.

Note: `terraform_directory` is deprecated. Use `input_path` instead.

## Environment variables

**Terraform:** Because Regula runs `terraform init`, `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY` must be set. Your AWS account will not be modified, but
if you want to be absolutely certain about this you can always create a dummy
user within your account.

**CloudFormation:** No keys are necessary to evaluate CloudFormation.

[GitHub Action]: https://github.com/features/actions
[Regula]: https://github.com/fugue/regula

## How to use this GitHub Action

To use [Regula] to evaluate the infrastructure-as-code in your own repository via GitHub Actions, see the instructions in [regula-ci-example](https://github.com/fugue/regula-ci-example). The example walks through how to use this GitHub Action in your own repo.
