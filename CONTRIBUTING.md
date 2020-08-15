
# Contributing to the Terraform AWS EKS Jenkins X Module

This guide is for developers who want to improve the Jenkins X Terraform module.
These instructions will help you set up your development environment.

## Prerequisites
In order to run the scripts and tests, you will need:

Terraform >= 0.12.17
golang 1.13

Install the prerequisite according to its instructions.

## We Develop with Github
We use github to host code, to track issues and feature requests, as well as accept pull requests.

## All code changes happen through pull requests
Pull requests are the best way to propose changes to the codebase and we use the Github Flow.

Fork the repo and create your branch from master.
If you've added code that should be tested, add tests.
Ensure the test suite passes.
Make sure your code lints.
Issue that pull request!
Report bugs using Github Issues]
We use GitHub issues to track public bugs. Report a bug by opening a new issue here.

## Run make test to test your infrastructure after running Terraform

```shell
$ make test      # runs terratest tests against your currently connected AWS account.
```

## Adding tests
All tests are located in [the test folder](test/terraform_eks_test.go).
