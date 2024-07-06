# Infra as Code - Lab Exercises

## Session 1 - IaC and Terraform Intro

### Overview

You will learn how to authenticate with AWS via the command line and then get accustomed to the Terraform workflow commands (init, plan, apply, destroy) to create and destroy a VPC resource. We are going to build on this solution as we progress through each session. You will also learn what FinOps is.

### Session 1 Goals

1. Authenticate with AWS and write and deploy Terraform code to create an AWS VPC.

2. As a comparison to Terraform run cloudformation to create and destroy a VPC.

3. Learn what FinOps is and why it is important for an Infrastructure Engineer to understand.

4. Provide feedback on session 1

**Note:** I would like to stress that although it’s nice to complete all the lab goals it’s more important to learn and fully understand all the concepts and principles we are trying to teach you in each of these sessions.  If you are struggling for time then skip any optional goals and if you need help please reach out in the group chat.


### Architecture Diagram

The VPC is the single resource we're adding in this session.

![Architecture diagram](../images/AWS_Architecture_Session_1.png)

### Pre-requisites, Deploy and Clean Up Instructions

Please read the root level [README](../README.md) for instructions that are the same for every session on how to authenticate with AWS using the AWS CLI and how to run the Terraform commands to manage your infrastructure.

Hint: In the provider block, region variable or the \*.tfvars file there is a value specified for the region, you should update this to match your AWS profile region.

### Difficulty Ratings

We're providing a relative scale of difficulty ratings from 1 to 10 for all the steps/goals in the lab exercises.  A rating of 1 is super easy and a rating of 10 is super hard.  This will hopefully help provide you with an understanding of what to expect before starting the steps/goals.  As you progress through the sessions overall these lab exercises will increase in difficulty.


### Steps/Tasks for Goal 1 [Difficulty Rating: 2 (easy)]

1. Create a new private repo in your personal GitHub account and call it "iac-lab-exercises-<placeholder:add_your_name_or_initials>" and git clone it locally. Navigate to this repo as you will now work from this location for all the rest of the lab exercises.  We recommend making small commits to this repo at logicial moments throughout the session.  We also recommend committing your changes directly to the main branch throughout the labs, there should not be any need to create any branches.

2. Create a main.tf at the root of the repo and add a [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) resource with the following attributes:

    - cidr_block = "192.168.1.0/25"
    - enable_dns_support = "true"
    - enable_dns_hostnames = "true"
    - instance_tenancy = "default"
    - tags: Name = "iac-lab-<placeholder:add_your_name_or_initials>"

3. Also in main.tf add the following code:

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}

provider "aws" {
  region = "<placeholder:add_your_aws_region>"
}
```

4. Follow the prerequisites to authenticate to AWS via the command line, see root level [README](../README.md).

5. Run the following commands to test deploying your VPC resource:

```
terraform init
terraform plan
terraform apply
terraform apply --auto-approve
```

6. Confirm that the VPC was successfully created and tagged by inspecting the AWS resources either via the AWS CLI or via the AWS console.

7. Run the following command to destroy the created VPC resource:

```
terraform destroy
```

8. Create a .gitignore file in the root of your repo and add the following code:

```
*tfstate*
*.terraform*
```

9. We recommend committing your code to your repo if you haven't done so already.

### Steps/Tasks for Goal 2 (Optional) [Difficulty Rating: 2 (easy)]

Although this course focuses on Terraform, we want to give you some exposure to an alternative 'Infrastructure as Code' framework, in this case AWS Cloudformation.  The cloudformation examples are very simple, they will create a VPC just like you have already done with Terraform.  You will see two Cloudformation templates in this folder which you can test out, one is in yaml format and the other in json format but they do the same thing (create a VPC).

1. To create a VPC using the yaml formatted Cloudformation template run the following (assuming you've already authenticated using the AWS CLI).  Obviously please update the placeholder with your intials.

```
aws cloudformation create-stack --stack-name iac-lab-cfn-yaml-<placeholder:add_your_name_or_initials> --template-body file://./cloudformation_template.yaml
```

2. Have a look in the AWS Console (UI) and see if your Cloudformation stack exists and if your VPC exists (make sure you check the correct region).  Assuming everything looks good let's delete it, again please update the placeholder with your intials.

```
aws cloudformation delete-stack --stack-name iac-lab-cfn-yaml-<placeholder:add_your_name_or_initials>
```

3. To create a VPC using the json formatted Cloudformation template run the following (assuming you've already authenticated using the AWS CLI).  Obviously please update the placeholder with your intials.

```
aws cloudformation create-stack --stack-name iac-lab-cfn-json-<placeholder:add_your_name_or_initials> --template-body file://./cloudformation_template.json
```

4. Again you can have a look in the AWS Console (UI) and see if your Cloudformation stack exists as well as your VPC.  Assuming everything looks good let's delete it, again please update the placeholder with your intials.

```
aws cloudformation delete-stack --stack-name iac-lab-cfn-json-<placeholder:add_your_name_or_initials>
```

If you are interested in finding out more about other 'Infrastructure as Code' frameworks you can visit these links.

- [Extensive Comparison of IaC tools in 2024!](https://ibatulanand.medium.com/extensive-comparison-of-iac-tools-49118e962ef8)
- [Differences between Infrastructure as Code (IaC) Tools](https://www.encora.com/insights/differences-between-infrastructure-as-code-iac-tools-used-for-provisioning-and-configuration-management)


### Steps/Tasks for Goal 3 - FinOps [Difficulty Rating: 2 (easy)]

FinOps is all about cloud cost management and optimisation. Nearly everything in the cloud costs money often on an hourly basis. It may not come out of your personal finances but either organisation or a client has to pay for the cloud usage. Many of us have worked with many clients and cloud cost management is always underestimated and often it is easy to let cloud costs get out of control, it does require constant management. Ideally it should be a shared responsibility model (making everyone accountable) with regards to cost management in the cloud. You as a new or experienced infrastucture engineer should take responsibility of any cloud resources you come across whether you created them or not, you should ask questions and query whether cost optimisation measures have been applied. There's a few easy rules to follow like if "it's not in use turn it off" and "if it is not going to be used ever again then archive or delete it" (this is with regards to cloud resources, obviously please check with all the necessary stakeholders before taking these actions).

We are going to continue to learn about FinOps as we progress through these 6 sessions and hopefully you'll have a greater understanding around the core principles and the need for accountability.

1. The first and primary objective of this goal is to destroy your resources once you have finished using them. Organisation can only fund this IaC course if cloud costs continue to be low therefore we need your help. Please ensure you have run the following to destroy your cloud resources.

```
terraform destroy --auto-approve
```

It also doesn't take long to double check by logging in to the AWS console to verify all the resources have been terminated which should give you satisfaction that no unnecessary cloud costs are accummulating.

2. The second step of this goal is to review the cost of the resources we created in this lab exercise. To work out costs for AWS resources you can choose to look at the monthly invoice, you can also look in the AWS Console (UI) or you could use the [AWS Cost Calculator](https://calculator.aws/#/) which allows you to calculate and predict costs before using the services. Below I've itemised what AWS resources we have created and the cost for it so far. As you may imagine this will increase as we create more resources.

| Resource / Service | Quantity | Cost per Unit | Cost per Year | Comments or extra info |
| ------------------ | -------- | ------------- | ------------- | ---------------------- |
| VPC                | 1        | 0.00          | 0.00          |                        |
| **Total**          | -        | **0.00**      | **0.00**      |                        |

Note: Costs vary per region and will fluctuate due to AWS price changes and exchange rates, the prices above are for the Sydney region at the time of the README creation and are in USD.

3. I would like to recommend reading this [article](https://www.ibm.com/topics/finops) which goes into greater details about what FinOps is and its core principles.

### Steps/Tasks for Goal 4 - Session Feedback [Difficulty Rating: 1 (easy)]

We can only make improvements if we receive feedback. Please can you fill out this very short survey to help us understand what you liked or disliked and the learnings you've gained from this, thank you.
