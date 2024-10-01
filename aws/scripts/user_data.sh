
sudo yum install -y \
    docker \
    git

sudo systemctl start docker
sudo usermod -a -G docker ec2-user
sudo su - ec2-user

git clone https://github.com/adamcubel/cloud-test.git
cd cloud-test/.devcontainer
docker build . -t devcontainer:latest