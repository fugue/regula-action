# regula-action

This is a [GitHub Action] to run [Regula] against your repository.

## Example

```yaml
on: [push]
jobs:
  regula_job:
    runs-on: ubuntu-latest
    name: Regula
    steps:
    - uses: actions/checkout@master
    - name: Regula
      id: regula
      uses: fugue/regula-action@v0.0.1
      with:
        terraform_directory: .
        rego_paths: /opt/regula/rules
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

You can see this example in action in
[this repository](https://github.com/fugue/regula-action-example).

## Inputs

-   `terraform_directory`: the directory where your terraform files are located.
    This defaults to `.`.
-   `rego_paths`: all paths that need to be passed to OPA.  This is typically
    `/opt/regula/lib`, which contains some default Regula rules, but you can
    also pass paths within your repository for custom checks.

## Environment variables

Because Regula runs `terraform init`, `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY` must be set. Your AWS account will not be modified, but
if you want to be absolutely certain about this you can always create a dummy
user within your account.

[GitHub Action]: https://github.com/features/actions
[Regula]: https://github.com/fugue/regula
