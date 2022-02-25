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
    - uses: fugue/regula-action@v1.6.0
      with:
        input_path: infra_tf
        include: example_custom_rule

  regula_cfn_job:
    runs-on: ubuntu-latest
    name: Regula CloudFormation
    steps:
    - uses: actions/checkout@master
    - uses: fugue/regula-action@v1.6.0
      with:
        input_path: infra_cfn/cloudformation.yaml

  regula_valid_cfn_job:
    runs-on: ubuntu-latest
    name: Regula Valid CloudFormation
    steps:
    - uses: actions/checkout@master
    - uses: fugue/regula-action@v1.6.0
      with:
        input_path: infra_valid_cfn/cloudformation.yaml

  regula_multi_cfn_job:
    runs-on: ubuntu-latest
    name: Regula multiple CloudFormation templates
    steps:
    - uses: actions/checkout@master
    - uses: fugue/regula-action@v1.6.0
      with:
        input_path: '*/cloudformation.yaml'

  regula_input_list_job:
    runs-on: ubuntu-latest
    name: Regula on CloudFormation and Terraform
    steps:
    - uses: actions/checkout@master
    - uses: fugue/regula-action@v1.6.0
      with:
        input_path: |
          infra_cfn/cloudformation.yaml
          infra_valid_cfn/cloudformation.yaml
          infra_tf

  regula_tf_plan_job:
    runs-on: ubuntu-latest
    name: Regula on a Terraform plan JSON
    steps:
    - uses: actions/checkout@master
    - uses: hashicorp/setup-terraform@v1
      with:
        # See the note below for why this option is necessary.
        terraform_wrapper: false
        terraform_version: 1.0.8
    - run: |
        cd infra_tf
        terraform init
        terraform plan -refresh=false -out="plan.tfplan"
        terraform show -json plan.tfplan > plan.json
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    - uses: fugue/regula-action@v1.6.0
      with:
        input_path: infra_tf/plan.json
        input_type: tf-plan
        include: example_custom_rule
```

You can see this example in action in the
[regula-ci-example](https://github.com/fugue/regula-ci-example).

## Inputs

- `input_path`: One or more Terraform directories, Terraform JSON plans, or CloudFormation templates. Accepts space-separated or newline-separated filenames and/or globbing expressions. This defaults to `.` (the root of your repository).
- `config`: Path to .regula.yaml file. By default regula will look in the current working directory and its parents.
- `environment_id`: Environment ID in Fugue.
- `exclude`: Rule IDs or names to exclude. This can be a space or newline-separated list.
- `include`: Custom rule and configuration paths passed in to the Regula interpreter. This can be a space or newline-separated list.
- `input_type`: The input types that Regula will evaluate. Defaults to `auto`, which evaluates all supported types. Possible values are:
  - `auto`
  - `tf-plan` -- Terraform plan JSON files
  - `cfn` -- CloudFormation templates in YAML/JSON
  - `tf` -- Terraform directories or files
  - `k8s` -- Kubernetes manifest in YAML format
- `no_built_ins`: Disable the built-in Regula rules. Set to `"true"` if you only want to run custom rules.
- `no_config`: Do not look for or load a regula config file. Set to `"true"` to enable this option.
- `no_ignore`: Disable use of .gitignore. Set to `"true"` to enable this option.
- `only`: Rule IDs or names to run. All other rules will be excluded. This can be a space or newline-separated list.
- `severity`: The minimum severity where Regula will produce a non-zero exit code for failing rules. Defaults to `unknown`. Use `off` to always produce a zero exit code. Possible values are:
  - unknown
  - informational
  - low
  - medium
  - high
  - critical
  - off
- `sync`: Fetch rules and configuration from Fugue. Set to `"true"` to enable this option.
- `upload`: Upload results to Fugue.  Set to `"true"` to enable this.  Requires `sync` to be set as well.
- `rego_paths`: Custom rule and configuration paths passed in to the Regula interpreter
- `user_only`: Disable the builtin Regula rules.  Set to `true` if you only want to run custom rules.

### Integration with Fugue

You can easily integrate this action with Fugue.

1.  Set `sync` and `upload` to true in the input values:

    ```yaml
    - uses: fugue/regula-action@v2.5.0
      with:
        sync: "true"
        upload: "true"
    ```

    Note that setting `upload` will require you to set an environment ID as
    well.  You can either specify that in the `.regula.yaml` or pass it in as
    an input value.

2.  Set up `FUGUE_API_ID` and `FUGUE_API_SECRET` environment variables for the
    action.

    You can find more info about these in the
    [Fugue API Documentation](https://docs.fugue.co/api.html).

### Deprecated options

These options still function, but we encourage you to update your configurations before
they are removed in a future release.

* `user_only` is deprecated. Use `no_built_ins` instead.
* `rego_paths` is deprecated. Use `include` instead.
* `terraform_directory` is deprecated. Use `input_path` instead.

### Links to additional information

[GitHub Action]: https://github.com/features/actions
[Regula]: https://github.com/fugue/regula

## How to use this GitHub Action

To use [Regula] to evaluate the infrastructure-as-code in your own repository via GitHub Actions, see the instructions in [regula-ci-example](https://github.com/fugue/regula-ci-example). The example walks through how to use this GitHub Action in your own repo.

## Compatibility with the `hashicorp/setup-terraform` action

The `hashicorp/setup-terraform` action can be used to generate a Terraform plan JSON file that Regula can evaluate. By default, the `hashicorp/setup-terraform` action wraps the `terraform` binary with a script that outputs some additional information for each command it executes. It's necessary to use the `terraform_wrapper: false` option, as we're doing in the example above, in order for the plan JSON file to be valid.
