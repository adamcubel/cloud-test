# AWS

Your instructor will begin the process by providing you with the following:
- Your AWS Username
- Your AWS Password
- URL for AWS Console Access
- Access Key ID
- Secret Access Key

You will have thirty minutes to complete the instructions. Explain to the team 
what you are doing. There may be some intentional pitfalls along the way 
intended to see how you think. 

## Setting up the Developer VM

Begin by logging into the AWS Console via the URL provided. After logging into 
the AWS Console, proceed to the EC2 Dashboard. You can find the dashboard from 
the AWS Console Search bar. Create an EC2 instance with the following parameters:
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
```

## Deploy the EKS Cluster

Clone the codebase and build the docker image:

```
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

Proceed to configure the AWS CLI. This will allow you to provision AWS 
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

Within the [terraform](./terraform/) directory exists Infrastructure as Code 
defined to create an EKS cluster within the VPC you define in the AWS account. 
This EKS cluster will be provisioned to only allow for internal access. To 
begin deploying the EKS Cluster you will first need to initialize Terraform.

```
cd cloud-test/aws/terraform/

terraform init
```

After initializing the Terraform - pulling down dependencies and preparing the 
configuration as code for deployment - you can plan out the deployment using 
the following command. You will be prompted to enter the ID of the VPC. 

```
terraform plan
```

Then proceed to run the Terraform plan once more. At this point, the plan 
should succeed. There should be 40 resources to create. You can specify a 
variables file to use. Create one now named vars.tfvars

Add the following lines to the file:

```
vpc_id         = "your VPC ID here"
eks_subnet_ids = [
    "subnet id 1",
    "subnet id 2"
]
```

When ready, create the EKS cluster using the following command:

```
terraform apply --var-file=./vars.tfvars
```

You will be prompted to confirm that these are the changes you would like to 
make. Confirm by typing 'yes' and pressing enter. Explain to the team what you 
have just provisioned. 

## Install a Kubernetes App

To install a kubernetes application, you may choose your own, but for this 
instructional, we will be installing the Prometheus, Loki, and Grafana (PLG) 
stack. Begin by retrieving the EKS kubeconfig from the AWS CLI.

```
aws eks update-kubeconfig --name "eks-cluster"
```

Have a look around in the cluster. Use the tools available to ensure that the 
deployment went smoothly, and see what has been provisioned within the cluster.

This command will store your kubernetes configuration in ~/.kube/config on your
local machine, enabling you to login and configure the cluster. Create a 
namespace to run your monitoring workload.

```
kubectl create ns monitoring
```

Verify that the namespace exists in the cluster.

```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

We can install all necessary components at once by using the grafana/loki-stack
umbrella chart. Before we install the chart, let’s download the values-file and
see what customizations are supported for grafana/loki-stack:

```
helm show values grafana/loki-stack > ~/loki-stack-values.yml
```

If we look at the loki-stack-values.yml file, we will immediately recognize that 
this Helm chart can deploy more than “just” Promtail, Loki, and Grafana. However, 
we will now customize the value file to deploy just Promtail, Loki, and Grafana. 
Make the following changes within loki-stack-values.yml.

```
loki:
 enabled: true
 persistence:
  enabled: true
  storageClassName: default
  size: 50Gi

promtail:
 enabled: true
 pipelineStages:
  - cri: {}
  - json:
    expressions:
     is_even: is_even
     level: level
     version: version

grafana:
 enabled: true
 sidecar:
  datasources:
   enabled: true
 image:
  tag: 8.3.5
```

You can now deploy the PLG stack by issuing the following command. 

```
helm install plg grafana/loki-stack -n monitoring -f ~/loki-stack-values.yml
```

Using the tools available, verify that Promtail, Grafana, and Loki are running.
With this configuration, you will not be able to access Grafana over the web. 
What needs to be setup in order to reach Grafana using the configured nginx 
ingress? You can take a look at [values.yaml](./helm/values.yaml) for an idea 
of what needs to be configured to successfully deploy in this environment. 
Verift that the ingress has been configured properly and navigate to the site.
Show off the Grafana interface running over HTTP. What can be improved for the 
deployment?