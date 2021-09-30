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
    - uses: fugue/regula-action@v1.5.0
      with:
        input_path: infra_tf
        rego_paths: example_custom_rule

  regula_cfn_job:
    runs-on: ubuntu-latest
    name: Regula CloudFormation
    steps:
    - uses: actions/checkout@master
    - uses: fugue/regula-action@v1.5.0
      with:
        input_path: infra_cfn/cloudformation.yaml

  regula_valid_cfn_job:
    runs-on: ubuntu-latest
    name: Regula Valid CloudFormation
    steps:
    - uses: actions/checkout@master
    - uses: fugue/regula-action@v1.5.0
      with:
        input_path: infra_valid_cfn/cloudformation.yaml

  regula_multi_cfn_job:
    runs-on: ubuntu-latest
    name: Regula multiple CloudFormation templates
    steps:
    - uses: actions/checkout@master
    - uses: fugue/regula-action@v1.5.0
      with:
        input_path: '*/cloudformation.yaml'

  regula_input_list_job:
    runs-on: ubuntu-latest
    name: Regula on CloudFormation and Terraform
    steps:
    - uses: actions/checkout@master
    - uses: fugue/regula-action@v1.5.0
      with:
        input_path: |
          infra_cfn/cloudformation.yaml
          infra_valid_cfn/cloudformation.yaml
          infra_tf
```

You can see this example in action in the
[regula-ci-example](https://github.com/fugue/regula-ci-example).

## Inputs

- `input_path`: One or more Terraform directories, Terraform JSON plans, or CloudFormation templates. Accepts space-separated or newline-separated filenames and/or globbing expressions. This defaults to `.` (the root of your repository).
- `input_type`: The input types that Regula will evaluate. Defaults to `auto`, which evaluates all supported types. Possible values are:
  - `auto`
  - `tf-plan` -- Terraform plan JSON files
  - `cfn` -- CloudFormation templates in YAML/JSON
  - `tf` -- Terraform directories or files
- `rego_paths`: Custom rule and configuration paths passed in to the Regula interpreter
- `user_only`: Disable the builtin Regula rules.  Set to `true` if you only want to run custom rules.
- `severity`: The minimum severity where Regula will produce a non-zero exit code for failing rules. Defaults to `unknown`. Use `off` to always produce a zero exit code. Possible values are:
  - unknown
  - informational
  - low
  - medium
  - high
  - critical
  - off

Note: `terraform_directory` is deprecated. Use `input_path` instead.

[GitHub Action]: https://github.com/features/actions
[Regula]: https://github.com/fugue/regula

## How to use this GitHub Action

To use [Regula] to evaluate the infrastructure-as-code in your own repository via GitHub Actions, see the instructions in [regula-ci-example](https://github.com/fugue/regula-ci-example). The example walks through how to use this GitHub Action in your own repo.
