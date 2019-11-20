# Gitlab Docker Runner for AWS using Terraform

Oh hi! :wave: I didn't see you there. Welcome to my repo about Gitlab Runners and AWS.

WHOA WHOA WHOA! I thought this was Github? Why are we talking about Gitlab? Uhhh.... Next question!

This repo will create a runner instance in AWS using an autoscaling group to maintain a capacity of 1 active runner. The runner can self-register and if the instance terminates and a new one spins up the new runner will locate the old registered runner, delete it and then register a new one in it's place. Pretty neat?

Terraform will create a group runner with additional tags so you can target any repo under the group to use the runner without having to attach the runner directly to a project. The runner is configured for GitLab Runner EC2 autoscaling so when a worker instance is needed for CI/CD automation the runner will manage the additional instances for us.

---

## Configuration

First things first. Do you have Terraform installed? [If not, let's get Terraform installed and configured](https://learn.hashicorp.com/terraform/getting-started/install.html). Now that we have that all squared away let's fill out some variables to get this up and running!

- File: `terraform-example.tfvars`
    - Let's rename this to `terraform.tfvars`. This is included in your `.gitignore` file.
        > :warning:	***Make sure this file never makes it to your repo as this will contain your AWS access and secret keys.***
    - Now let's fill out the variables in this file!
        Variable | Description | Required
        --- | --- | ---
        access_key | AWS access key Terraform will use to create infrastructure in AWS. | YES
        secret_key | AWS secret key Terraform will use to create infrastructure in AWS. | YES
        region | AWS region to create infrastructure in | YES
        app | The name of the app. You can name it whatever you want. | YES
        vpc_id | The ID of the VPC you want the runner created in. If no value provided we'll use the default VPC of your AWS account | NO
        s3_bucket_prefix | The prefix to use when creating the S3 bucket. The bucket name is a combo of prefix and app name | YES
        ssh_access | Specify whether the runner instance should have SSH access enabled. Great for testing but shouldn't be needed for a prod deployment | YES
        key_pair | Name of the keypair to use with the runner instance. This should be an existing key. We do not generate this for you :( | YES
        gitlab_url | URL of your Gitlab instance. This can be changed if you use a self hosted instance | YES
        gitlab_runner_reg_token | The token that is generated on the 'Runners'  section of the 'CI/CD Settings' page for your group. | YES
        gitlab_api_token | The personal access token generated (User Settings > Access Tokens) to use with Gitlab | YES
        gitlab_group_id | ID of the Gitlab group the runner will be registered to. | YES
        gitlab_runner_name | The name of the runner. This is used to tag the runner and I think it shows up somewhere else :man_shrugging:. This can be anything. | YES

---

## Let's do stuff!

We're ready to run Terraform and create our new runner!
1. Open terminal/command prompt/powershell or whatever else you're using and `cd` to `terraform-aws-gitlab-group-runner/all`
2. Initialize Terraform: `terraform init`
3. Apply changes via Terraform: `terraform apply` and you can review the changes before applying them. If you don't care then use `terraform apply -auto-approve`.
4. Once Terraform creates the infrastructure and completes the apply process just hang out for about 5 minutes and wait for the runner installation/registration/configuration process to finish. You can check if the runner has been created by refreshing the 'CI/CD Settings' page for your Gitlab group and looking for a 'Group Runner' under the 'Runners' section. It will include tags for the Gitlab Group ID and Runner Name you specified in `terraform.tfvars`.

---

## Yay! I've got a runner! Can I test it out?

Yeah you can! This repo contains a `Dockerfile` and `.gitlab-ci.yml` file. The CI file has a single step to build an image from `Dockerfile` and publish it to the project's Container Registry. All you have to do is create a new project under the group which the runner was registered to and then push a commit including both files. This will trigger a pipeline with the job to run. Enjoy! :sunglasses: