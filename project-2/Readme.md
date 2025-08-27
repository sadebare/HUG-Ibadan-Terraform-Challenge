# Multi-Environment Web Application Infrastructure

This project provides a production-ready, auto-scaling web application infrastructure on AWS using Terraform. It is designed with a modular approach to separate concerns and enable easy management of different environments (`dev`, `prod`).

## Architecture Overview

Internet -> Application Load Balancer (ALB) -> Auto Scaling Group (EC2 Instances) -> RDS Database (MySQL)

This architecture is deployed across two Availability Zones for high availability.

## Prerequisites

1.  **Terraform:** [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2.  **AWS Account:** An active AWS account.
3.  **AWS CLI:** [Install and configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) with your credentials.

    ```bash
    aws configure
    ```

## Project Structure

-   `environments/`: Contains the root configurations for each environment (`dev`, `prod`). This is where you run Terraform commands.
-   `modules/`: Contains reusable modules for core infrastructure components.
    -   `networking`: VPC, Subnets, Gateways, Security Groups.
    -   `database`: RDS MySQL instance and related resources.
    -   `compute`: ALB, Auto Scaling Group, Launch Template, and Scaling Policies.

## How to Deploy

You will deploy each environment separately. We'll start with `dev`.

1.  **Navigate to the dev environment directory:**
    ```bash
    cd environments/dev
    ```

2.  **Create a `terraform.tfvars` file:**
    This file will contain your environment-specific variables, including secrets. **Do not commit this file to version control.**

    Copy the contents of `terraform.tfvars.example` into a new file named `terraform.tfvars` and fill in the values. You must provide a database password.

3.  **Initialize Terraform:**
    This downloads the necessary provider plugins.
    ```bash
    terraform init
    ```

4.  **Plan the deployment:**
    This shows you what resources Terraform will create.
    ```bash
    terraform plan
    ```

5.  **Apply the configuration:**
    This will build the infrastructure. Type `yes` when prompted.
    ```bash
    terraform apply
    ```

After the apply is complete, Terraform will output the DNS name of the Application Load Balancer. You can visit this URL in your browser to see the running application.

## Testing Auto-Scaling

The EC2 instances are configured with a CPU-based auto-scaling policy. To test this:

1.  Connect to one of your EC2 instances using AWS Systems Manager Session Manager (recommended) or SSH.
2.  Install a stress testing tool.
    ```bash
    sudo amazon-linux-extras install epel -y
    sudo yum install stress -y
    ```
3.  Generate CPU load. This command will max out one CPU core.
    ```bash
    stress --cpu 1 --timeout 300s
    ```
4.  After a few minutes, go to the AWS Console -> EC2 -> Auto Scaling Groups. You should see your ASG launching a new instance to handle the load. Once the stress test finishes, the ASG will terminate the extra instance after the cool-down period.

## Cleaning Up

To destroy the infrastructure and avoid incurring costs, run the following command in the environment directory (`environments/dev`):

```bash
terraform destroy