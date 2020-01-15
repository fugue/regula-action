# regula-action

[Regula] is a tool that evaluates Terraform infrastructure-as-code for potential security misconfigurations and compliance violations prior to deployment. This is a [GitHub Action] to run [Regula] against your repository.

## Example

Here's an example workflow file:

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
[this repository](https://github.com/fugue/regula-ci-example).

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

## How to use this GitHub Action

To use [Regula] to evaluate the Terraform in your own repository via GitHub Actions, see the instructions below.

### 1. Customize workflow

In your own repo, create a `.github/workflows` directory and customize your `main.yml` workflow file based on the template [above](#example). 

You can see the example repo's configuration in [.github/workflows/main.yml](https://github.com/fugue/regula-action-example/blob/master/.github/workflows/main.yml).

The example uses the following [inputs](#inputs):
- `terraform_directory` is set to `.`, where [main.tf](https://github.com/fugue/regula-action-example/blob/master/main.tf) lives (in the repo root).
- `rego_paths` is set to `/opt/regula/rules example_custom_rule`, which includes the default Regula rules in addition to the rule in the repo's [`example_custom_rule`](https://github.com/fugue/regula-action-example/tree/master/example_custom_rule) folder. If you want to specify additional directories, you could do so with something like `/opt/regula/rules example_custom_rule company_policy_rules`.

You can read GitHub's documentation [here](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets) about configuring the action to use your own AWS access key ID and secret access key.

If you'd like to further customize your action, check out GitHub's docs for [configuring a workflow](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/configuring-a-workflow).

When you're done, push your changes. Now, the action will run every time you push to the repo. (Unless you've configured your action with a different trigger, of course!) For more information about GitHub Actions, see the [docs](https://help.github.com/en/actions).

### 2. Test it out!

Commit a Terraform file to your repository (and make sure it's in the directory you specified in your `main.yml`!). In the example case, that's [main.tf](https://github.com/fugue/regula-action-example/blob/master/main.tf).

The action will run automatically, and you can view the Regula test results in the Actions tab of your repo. For example, see how the Terraform in the example failed the [Regula check here](https://github.com/fugue/regula-action-example/runs/389223751). That's because [one of the IAM policies](https://github.com/fugue/regula-action-example/blob/master/main.tf#L6-L9) violated the Rego policy by having a description shorter than 25 characters.

### Understanding the Regula test results

If you look at the [Regula portion of the logs](https://github.com/fugue/regula-action-example/runs/389223751#step:4:12), you'll see the report, which looks like this (though we shortened it here):

```
{
  "result": [
    {
      "expressions": [
        {
          "value": {
            "controls": {
              "CIS_1-16": {
                "rules": [
                  "iam_user_attached_policy"
                ],
                "valid": true
                ...
              },
            },
            "rules": {
              "cloudtrail_log_file_validation": {
                "resources": {},
                "valid": true
              },
              ...
            },
            "summary": {
              "controls_failed": 2,
              "controls_passed": 12,
              "rules_failed": 2,
              "rules_passed": 8,
              "valid": false
            }
          },
          "text": "data.fugue.regula.report",
          "location": {
            "row": 1,
            "col": 1
          }
        }
      ]
    }
  ]
}
8 rules passed, 2 rules failed
12 controls passed, 2 controls failed
##[error] 2 rules failed
##[error]Docker run failed with exit code 1
```

The bit at the end is the most important part -- it's a breakdown of the compliance state of your Terraform files. In this case, the test failed. This is great, because now we know there's a policy violation in our Terraform! (You'll also see this information in the `summary` block of the output.)

Dig a little deeper and you'll see exactly which resources violated which controls or rules.

#### Controls vs. Rules

But wait, what's the difference between controls and rules? A **control** represents an individual recommendation within a compliance standard, such as "IAM policies should not have full `"*:*"` administrative privileges" (CIS AWS Foundations Benchmark 1-22).

In Regula, a **rule** is a Rego policy that validates whether a cloud resource violates a control (or multiple controls). One example of a rule is [`iam_admin_policy`](https://github.com/fugue/regula/blob/master/rules/aws/iam_admin_policy.rego), which checks whether an IAM policy in a Terraform file has `"*:*"` privileges. If it does not, the resource fails validation.

Controls map to sets of rules, and rules can map to multiple controls. For example, control `CIS_1-22` and `REGULA_R00002` [both map to](https://github.com/fugue/regula/blob/master/rules/aws/iam_admin_policy.rego#L7) the rule `iam_admin_policy`. (To learn how to specify controls in a custom rule, see the [Regula README](https://github.com/fugue/regula#compliance-controls).)

Regula shows you compliance results for both controls and rules, in addition to which specific resources failed. Below, in the `controls` block, you can see that the Terraform in the example is noncompliant with `CIS_1-22`, and the mapped rules that failed are listed underneath (in this case, `iam_admin_policy`).

In the `rules` block further down, you'll see that the resource `aws_iam_policy.basically_allow_all` was the one that failed the mapped rule -- as noted by `"valid": false`. In contrast, `aws_iam_policy.basically_deny_all` passed.

```
            "controls": {
              "CIS_1-22": {
                "rules": [
                  "iam_admin_policy"
                ],
                "valid": false
              },
            },
            ...
            "rules": {
              "iam_admin_policy": {
                "resources": {
                  "aws_iam_policy.basically_allow_all": {
                    "id": "aws_iam_policy.basically_allow_all",
                    "message": "invalid",
                    "type": "aws_iam_policy",
                    "valid": false
                  },
                  "aws_iam_policy.basically_deny_all": {
                    "id": "aws_iam_policy.basically_deny_all",
                    "message": "",
                    "type": "aws_iam_policy",
                    "valid": true
                  }
                },
                "valid": false
              },
```

The resource `aws_iam_policy.basically_allow_all` _also_ failed the custom rule [long\_description](https://github.com/fugue/regula-action-example/blob/master/example_custom_rule/long_description.rego):

```
            "rules": {
              ...
              "long_description": {
                "resources": {
                  "aws_iam_policy.basically_allow_all": {
                    "id": "aws_iam_policy.basically_allow_all",
                    "message": "invalid",
                    "type": "aws_iam_policy",
                    "valid": false
                  },
                  "aws_iam_policy.basically_deny_all": {
                    "id": "aws_iam_policy.basically_deny_all",
                    "message": "",
                    "type": "aws_iam_policy",
                    "valid": true
                  }
                },
                "valid": false
              },
```

You can see this example in <https://github.com/fugue/regula-ci-example>. For more information about Regula and how to use it, check out these resources:

- [Regula](https://github.com/fugue/regula)
- [More Regula CI/CD examples](https://github.com/fugue/regula-ci-example)
- [fregot](https://github.com/fugue/fregot)
- [OPA](https://www.openpolicyagent.org/)