# AWS

Your instructor will begin the process by providing you with the following:
- Your AWS Username
- Your AWS Password
- URL for AWS Console Access
- Access Key ID
- Secret Access Key

You will have thirty minutes to complete the instructions. Explain to the team 
what you are doing. There may be some intentional pitfalls along the way 
intended to see how you think. Begin by logging into the AWS Console via the 
URL provided. 

After logging into the AWS Console, proceed to the EC2 Dashboard. You can find 
the dashboard from the AWS Console Search bar. Create an EC2 instance with the 
following parameters:
- Name: Deployment VM
- AMI: Amazon Linux 2023 AMI
- Instance Size: t3.medium
- Create a new key pair named test (This will download a .pem file. You should not need it)
- Leave the network settings as they are
- Configure 100 GB of gp3 storage

Once you have configured the VM, Launch the instance. When the instance has been
deployed, connect to the instance using EC2 Instance Connect. Once connected you
should be presented with the bash prompt of the VM.

Run the following commands to prepare the system:

```
sudo yum install -y \
    docker \
    git

sudo systemctl start docker
sudo usermod -a -G docker ec2-user
sudo su - ec2-user

git clone https://github.com/adamcubel/cloud-test.git
cd cloud-test/.devcontainer
docker build . -t devcontainer:latest
```

Finally, start the container using the following command:

```
docker run --rm \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/group:/etc/group:ro \
    -v /etc/shadow:/etc/shadow:ro \
    -v /home/$(id -un):/home/$(id -un) \
    -e USER \
    -w /home/$(id -un)/ \
    -it devcontainer:latest /bin/bash
```

This container you have created provides you with access to a number of tools:
- AWS CLI
- helm
- k9s
- kubectl
- terraform

Within the [terraform](./terraform/) directory exists Infrastructure as Code 
defined to create an EKS cluster within the VPC you define in the AWS account. 
This EKS cluster will be provisioned to only allow for internal access. To 
begin deploying the EKS Cluster you will first need to initialize Terraform.

```
cd <REPO root>/aws/terraform/

terraform init
```

After initializing the Terraform - pulling down dependencies and preparing the 
configuration as code for deployment - you can plan out the deployment using 
the following command. You will be prompted to enter the ID of the VPC. 

```
terraform plan
```

If you run into an error stating that "No valid credential sources found", 
proceed to configure the AWS CLI. This will allow you to provision AWS 
resources in the account. To do this, issue the following command:

```
aws configure
```

After configuring the AWS CLI, to validate, issue the following command:

```
aws sts get-caller-identity

or 

aws s3 ls
```