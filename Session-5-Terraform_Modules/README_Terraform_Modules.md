# Infra as Code - Lab Exercises

## Session 5 - Terraform Modules

These lab exercises are to be completed in order, you will need to have completed the lab exercise for session 4 before proceeding.

### Overview

You will learn how to implement both public and private modules as well as create a working web based solution with a database backend.


### Session 5 Goals

1. Refactor to include using both public and private modules.

2. Add an RDS instance to your AWS solution through your Terraform code and have a working website up and running.

3. Learn more about AWS Trust Advisor, AWS Compute Optimiser and reservations, spot, saving plans from a FinOps (cloud cost management) perspective.

4. Provide feedback on session 5

**Note:** I would like to stress that although it’s nice to complete all the lab goals it’s more important to learn and fully understand all the concepts and principles we are trying to teach you in each of these sessions.  If you are struggling for time then skip any optional goals and if you need help please reach out in the group chat.


### Architecture Diagram

Users connect to the application through a public facing load balancer which has a target of an ECS task container which resides in the private subnets spread across two AZs.  In this session we're adding an RDS database and pushing a container image to ECR to get consumed by the ECS cluster service and run our container based application.

![Architecture diagram](../images/Session-5-AWS_Architecture.png)


### Pre-requisites, Deploy and Clean Up Instructions

Please read the root level [README](../README.md) for instructions that are the same for every session on how to authenticate with AWS using the AWS CLI and how to run the Terraform commands to manage your infrastructure.

Please make sure you have Docker installed and running. If you currently do not have it installed, check out the instructions for setting up Rancher Desktop.

Hint: In the provider block, region variable or the `*.tfvars` file there is a value specified for the region, you should update this to match your AWS profile region.


### Difficulty Ratings

We're providing a relative scale of difficulty ratings from 1 to 10 for all the steps/goals in the lab exercises.  A rating of 1 is super easy and a rating of 10 is super hard.  This will hopefully help provide you with an understanding of what to expect before starting the steps/goals.


### Steps/Tasks for Goal 1 [Difficulty Rating: 8 (complex)]

For the next two goals you may notice that in many of these steps we're helping you significantly, this is based on previous participant feedback which indicated that this sessions was complex and time consuming.  We've made it easier so you can focus on learning the concepts.

In the following steps we will refactor the code to use both public and private modules.

Before we dive into the refactoring to add Terraform modules I would like to make it clear that up until this point we've just been coding with mostly resource blocks which are all clearly defined.  The Terraform Registry explicitly outlines all the optional and required inputs along with what outputs are exposed too, giving you a clear structure to follow.  As we start to use modules we will recognise we have more freedom of choice and less structure and/or definition especially when you write your own private modules.  Public modules will still have clearly defined inputs and outputs.  With private modules you can choose what resources are in your modules (can be as much or as little as you want) and you can choose what inputs and outputs you expose.  When starting out creating your modules this can be a little daunting as there isn't much guidance.

I'll provide a basic example to explain this in more depth.  Let's assume we are writing a private module for an S3 bucket, we might simply express it like this.

```
module "s3_private_module" {
  source  = "./modules/s3"
  name    = var.bucket_name
```

Alternatively we could expose more variables to provide more flexibility for the module's usage.

```
module "s3_private_module" {
  source  = "./modules/s3"
  name = var.bucket_name
  force_destroy = var.s3_bucket_force_destroy
  tags = var.tags
```

We could also add an outputs.tf inside the module to be able to retrieve data from the module so you can use it outside the module as their may be dependencies on it.

```
output "s3_bucket_arn" {
  description = "S3 Bucket ARN"
  value       = aws_s3_bucket.my_s3_bucket.arn
}
```

Hopefully the example above helps to identify that it's fairly open for you to decide on you wish to design your modules and what you expose as inputs and outputs.  We have provided some module best practices in the [Module Design Best Practice slide] that are worth following.

In the following steps we are hoping you are now ready to refactor the code to use both public and private modules.  We recommend continuing to make small commits of your changes to your repo at logical moments throughout the session.

1. Refactor `network.tf` to use the public [VPC module](https://github.com/terraform-aws-modules/terraform-aws-vpc).  Then run terraform init and apply the changes in your root directory to confirm it all works before progressing to the next step.  It's important to point out an extra attribute 'single_nat_gateway' worth using otherwise by default you will create two NAT Gateways, one for each public subnet when in our case we just wish to create a single NAT Gateway in one of the public subnets.  There are also files which reference the VPC Id, public subnet and private subnet Ids, these will now have to reference the module's outputs for these values.

2. I strongly recommend before the next refactor to run the Terraform destroy command in your root directory to remove all our AWS resources (you don't have to destroy the remote state management resources as well) because it will be easier to refactor without getting conflicts with existing resources.  Now we should create a modules folder in the root directory.  We should also create a folder called ecs inside the modules folder, this will be the location for a new private module.  Move the ecs related files (`ecs.tf`, `ecr.tf` and `iam-ecs.tf`) into the ecs folder and create a new `ecs.tf` file at your root directory.  This new `ecs.tf` file should reference your new private module, I've provided the contents for it below (you need to fill in the question marks).

```
module "ecs" {
  source = "./modules/ecs/"

  prefix                = var.prefix
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  alb_target_group_arn  = ?
  alb_security_group_id = ?
}
```

The code above helps to identify what variables you require for the module (you can create a `variables.tf` inside the ECS module which will match these variables.  You should also create an `outputs.tf` in the ECS module with the following contents.

```
output "ecr_url" {
  description = "The Elastic Container Registry (ECR) URL."
  value       = aws_ecr_repository.api.repository_url
}

output "ecs_security_group_id" {
  description = "ECS Security group Id"
  value       = aws_security_group.ecs.id
}
```

Just like before rerun run the terraform init, plan and apply in your root directory to confirm it all works before progressing to the next step.

3. Commit your working code to your repo.


### Steps/Tasks for Goal 2 [Difficulty Rating: 9 (complex)]

Now we are going to add an RDS instance to your AWS solution using Terraform and hopefully have a working REST API up and running.  The database requires a password and we do not wish to create the password in Terraform otherwise it will be stored in the state file in plain text which is why we will manually create it in Secrets Manager instead.  Once the solution is up and running we should be able to use curl commands to interact with a REST API exposed via the load balancer.  We recommend continuing to make small commits of your changes to your repo at logicial moments throughout the session.

1. Using the AWS Console (UI) manually create a new secret (create your own secret) in AWS Secret Manager, select 'Other type of secret' and in the key value pair fields enter a key of `db_password` and in the value field next to it enter a value for the password which complies with the following password requirements:

- Nine characters
- Two uppercase letters
- Two lowercase letters
- Two numbers
- One or more special characters (excluding '/', '@', '"', ' ')

After clicking next, name the secret `dev/db<your-initials>` (obviously add your initials to make it a uniquely identifiable name, for example dev/dbnp) (all other aspects of the creation wizard can be left as the defaults).

2. Now copy the file `RDS.tf` from this folder to your solution.  Notice in there the use of data resources to access secret manager to get the database password you have created (please update the name attribute value for `aws_secretsmanager_secret` to match the name of the password you created in the previous step).

3. Add the following new variables in `variables.tf` in your root directory.  Add the exact same value of 'postgres' for both of these variables in your tfvars file.

```
variable "db_username" {
  type        = string
  description = "Database username"
}

variable "db_name" {
  type        = string
  description = "Database name"
}
```

4. Expose the ECS module output for ecr_url in your root `outputs.tf` as well.

5. Also in the `outputs.tf` in your root directory you can add the following code which will provide the load balancer dns_name with a prefix of `http://` and a suffix of `/users`\ so the value provides a properly formatted URL for your REST API.

```
output "website_url" {
  description = "The website URL."
  value       = format("http://%s/users", aws_alb.this.dns_name)
}
```

6. Change `ecs.tf` file in the root directory from this.

```
module "ecs" {
  source = "./modules/ecs/"

  prefix                = var.prefix
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  alb_target_group_arn  = ?
  alb_security_group_id = ?
}
```

To this and like before please fill in the question marks.  Notice that we've specifically chosen the input variables to our private module along with the output variables in steps 4 and 5 above.  We've also chosen to include the ECR resource and IAM resources in our ECS module as it made a sensible logical grouping.

```
module "ecs" {
  source = "./modules/ecs/"

  prefix                = var.prefix
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  alb_target_group_arn  = ?
  alb_security_group_id = ?
  db_address            = ?
  db_name               = ?
  db_username           = ?
  db_secret_arn         = ?
  db_secret_key_id      = ?
}
```

7. Copy the contents of `container.json` in this folder over the top of `container.json` in your templates folder.  Notice it has some extra environment variables and a secret that is being passed in which create the database connection for the application to connect to the database.

8. Copy the contents of `ecs-task-definition.tf` in this folder and replace the existing ECS task definition which should be in a Terraform file inside your ECS module.  You'll recognise that you will need to pass in extra variables to your ECS module (e.g. var.db_name, var.db_username, etc).

9. Copy the contents of `extra-iam-permissions.tf` in this folder and append it to the end of `iam-ecs.tf`.  The contents you've copied is simply the permissions as a data source as well as `aws_iam_policy` and `aws_iam_role_policy_attachment` resources which associate it with your IAM role.  You will also need to pass two new variables into the ECS module for the IAM permissions to access the secret (see references to var.db_secret_arn and var.db_secret_key_id).  This allows the container to access and decrypt the secret as it uses it in its connection string for the database connection.

10. This next step will depend on whether you are running an M1 chipset (ARM architecture) on your laptop or not.  The ECS Task Definition resource you just copied across has an attribute for runtime_platform.  This needs to be set as ARM64 if you are running an M1 chipset and X86_64 if you are not (this is to allow for the fact you will build and push an ARM based image for consumption):

```
  runtime_platform {
    cpu_architecture = "ARM64" # "ARM64" or "X86_64"
  } 
```

11. That's quite a fair amount of refactoring, now for the moment of truth, run the following commands to test deploying your updated solution:

```
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

Troubleshoot any errors (it's expected there may be a few to work out) before proceeding to the next step.

12. Once all resources have been deployed successsfully you can now build and push our container image to ECR.  First navigate in your terminal to the crud_app folder within this folder.  Now access the AWS Console (UI) and go to ECR and locate your ECR repository.  Click on the link to go into your repository, you'll see there are no images at the moment.  There should be a button called 'View push commands'.  Click on that button and a pop up will appear with instructions on how to authenticate with ECR and tag and push our image to ECR (please follow these instructions to push your image to your ECR).

As a example of pushing docker images, you can watch this video: https://youtu.be/O3792WllJmA?si=9WhA5j4e0j0kdjzG&t=186

13. Once the image has been uploaded into the ECR repository successfully you can then check ECS to see if this has fixed the ECS task service which would have been failing.  It should now be in a running state which may take a few minutes to correct itself.  If not then please check the ECS task logs and the ECS Service events to troubleshoot any issues.  Assuming there are no errors and the ECS task is in a running state you can now access the REST API using a GET method with your web browser.  The URL should be in the output of your Terraform, it will be in the format of `http://<load_balancer_dns_name>/users` which should return an empty array on screen.  You are now ready to test the REST API.

```
curl -X GET http://<load_balancer_dns_name>/users 
```

14. First I'll provide a little more information about the solution (a simple web based REST API) we've built and how to interact with it.  Using the web browser or curl command you can hit the load balancer's address with a path (/users) and a specified method (GET, POST, PUT, etc), the load balancer then routes this request to the ECS container which then passes its request in the form of SQL statements on to a Postgres database (RDS).  The REST API is extremely basic, there's no data validation or paramatisation from a security stand point, it provides CRUD capabilities for a basic working example for user data (you can easily give it bad data or do SQL injection).  To understand what data we should send the REST API you need to know the 'user' class which is defined as follows (Id is generated by the database):

```
type User struct {
	ID    int    `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}
```

Here are the REST API routes:

```
	router.HandleFunc("/users", getUsers(db)).Methods("GET")
	router.HandleFunc("/users/{id}", getUser(db)).Methods("GET")
	router.HandleFunc("/users", createUser(db)).Methods("POST")
	router.HandleFunc("/users/{id}", updateUser(db)).Methods("PUT")
	router.HandleFunc("/users/{id}", deleteUser(db)).Methods("DELETE")
```

Knowing this information we can now use curl to add a new user using the REST API:

```
curl -X POST http://<load_balancer_dns_name>/users -d '{"name":"John Doe", "email":"jdoe@example.com"}' -H "Content-Type: application/json"
```

This should return a json object with an Id along with the data passed in.  This indicates that the command worked.  You can now either run a curl command or access the web browser at the address `http://<load_balancer_dns_name>/users` to confirm the user has been added.  You should be able to test out any of the REST API routes with this application.

15. Commit your working code to your repo.


### Steps/Tasks for Goal 3 - FinOps [Difficulty Rating: 2 (easy)]

1. The first and primary objective of this goal is to destroy your resources once you have finished using them. Organisation can only fund this IaC course if cloud costs continue to be low therefore we need your help.  Please ensure you have run the following to destroy your cloud resources.

```
terraform destroy --auto-approve -var-file="dev.tfvars"
cd backend_support
terraform destroy --auto-approve
```

We recommend that you destroy any manually created resources as well (secret in AWS Secret Manager for example)

It also doesn't take long to double check by logging in to the AWS console to verify all the resources have been terminated which should give you satisfaction that no unnecessary cloud costs are accummulating.

2. The second step of this goal is to review the cost of the resources we created in this lab exercise.  Like before we've worked out the costs using the [AWS Cost Calculator](https://calculator.aws/#/).  Now we've added our most expensive resource, the database, however this is only a small instance, we would run a larger instance size in production and possibly run it in Multi-AZ mode which provides extra redundancy but increases the costs.  Another important fact is this is just one very small solution, if we are running dev, test, uat and prod environments then costs quadruple.

| Resource / Service  | Quantity  |  Cost per Unit  | Cost per Year | Comments or extra info                        |
| ------------------- | --------- | --------------- | ------------- | --------------------------------------------- |
| VPC                 | 1         | 0.00            | 0.00          |                                               |
| Subnet              | 6         | 0.00            | 0.00          |                                               |
| Internet Gateway    | 1         | 0.00            | 0.00          |                                               |
| EIP                 | 1         | 3.65            | 43.80         |                                               |
| NAT Gateway         | 1         | 43.66           | 523.92        | 10 GB per month data processing               |
| Route Tables        | 2         | 0.00            | 0.00          |                                               |
| Data Transfer       | 1         | 3.42            | 41.04         | 30 GB per month outbound (guesstimate)        |
| DynamoDb (tf state) | 1         | 0.28            | 3.36          | 1 GB per month storage                        |
| S3 (tf state)       | 1         | 0.03            | 0.36          | 1 GB per month storage                        |
| ALB                 | 1         | 18.44           | 221.28        | 5 GB per month processing                     |
| ECR                 | 1         | 3.00            | 36.00         | 30 GB data stored                             |
| ECS                 | 1         | 43.22           | 518.64        | 1 x CPU, 2GB RAM                              |
| SecretsManager      | 1         | 0.40            | 4.80          | 4 x API calls per month                       |
| RDS                 | 1         | 45.41           | 544.92        | 1 x db.t3.small, 30 GB snapshot storage       |
| **Total**           | -         | **160.41**      | **1938.32**   |                                               |  

Note: Costs vary per region and will fluctuate due to AWS price changes and exchange rates, the prices above are for the Sydney region at the time of the README creation and are in USD.

It's worth highlighting the cost for Secrets Manager.  It's certainly not a large cost at all but we only have one secret.  If we had many secrets that cost would multiple and this is where it's worth knowing about alternative services.  Instead of storing your secrets in Secrets Manager you could store them as secure strings in SSM Paramater Store for free or you may store them externally and have your pipeline inject them.  Equally you may redesign the solution to not use RDS and instead use DynamoDB which might be cheaper alternative.  Another far cheaper solution to RDS is to store your data in S3 and use Athena to query the data instead.

3. [Trusted Advisor](https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html) is an AWS cloud service which inspects your AWS infrastructure and then provides recommendations in various areas to align with best practices (one of those areas is cost optimisation).  There is a the free basic tier as well as a business tier which provides extra recommendations and features.  Here are some examples of the recommendations relating to cost optimization checks that inspect the utilization of resources and flag resources with low utilization:

- Amazon RDS Idle DB Instances
- Idle Load Balancers
- Low Utilization Amazon EC2 Instances
- Unassociated Elastic IP Addresses
- Underutilized Amazon EBS Volumes
- Underutilized Amazon Redshift Clusters

The following cost optimization checks provide reservation and savings plan recommendations also through Trusted Advisor:

- Amazon EC2 Reserved Instance Lease Expiration
- Amazon EC2 Reserved Instances Optimization, Amazon ElastiCache Reserved Node Optimization, Amazon OpenSearch Reserved Instance Optimization, Amazon Redshift Reserved Node Optimization, and Amazon Relational Database Service (RDS) Reserved Instance Optimization.
- Savings Plan

Reservations, spot pricing and savings plans are alternative and usually much cheaper pricing plans when compared to default on-demand pricing for your cloud resources.  Here are some more details on the common AWS pricing models:

- On-Demand: Pay for compute capacity by the hour with no long-term commitments. Good for spiky workloads or yet to be defined needs.
- [Reserved](https://docs.aws.amazon.com/whitepapers/latest/cost-optimization-reservation-models/reservation-models-for-other-aws-services.html): Make an Amazon EC2 usage commitment and receive a significant discount.  This is for a committed utilization (1 or 3 years).
- [Spot](https://aws.amazon.com/ec2/spot/pricing/): Bid for unused capacity, charged at a 'Spot Price' which fluctuates based on supply and demand. Ideal for time-insensitive or transient workloads.
- [Savings Plans](https://aws.amazon.com/savingsplans/): Allows you to apply long term savings similar to reserved but not associated with instances, therefore it can include serverless (Lambda, Fargate, etc).

If you choose an EC2 reservation for an instance type (e.g. t3.large) for 3 years then you will get a large discount compared to the on-demand cost for the same resource over the same period.  If the solution you purchased the reservation for needs more resources so you decide to up-size the instance type (e.g. t3.xlarge) then you will end up paying for the on-demand cost and as well as the reservation cost (therefore more than double) which is why you need to be careful when you plan your reservation costs, hence reservations are most suitable for static workloads that run 24/7 although there are now more flexible reservation options allowing you to make changes if need be.

One aspect with choosing the right reservation is to rightsize your instance type as you want to ensure optimum utilisation for its cost.  You can use [AWS Cost Optimiser](https://aws.amazon.com/compute-optimizer/) to help with the identifying the correct instance types for the workloads which could also help to reduce costs.


### Steps/Tasks for Goal 4 - Session Feedback [Difficulty Rating: 1 (easy)]

We can only make improvements if we receive feedback. Please can you fill out this very short survey to help us understand what you liked or disliked and the learnings you've gained from this, thank you.