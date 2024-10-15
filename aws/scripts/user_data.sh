
sudo yum install -y \
    docker \
    git

sudo systemctl start docker
sudo usermod -a -G docker ec2-user
sudo su - ec2-user

git clone https://github.com/adamcubel/cloud-test.git
cd cloud-test/.devcontainer
docker build . -t devcontainer:latest

docker run --rm \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/group:/etc/group:ro \
    -v /etc/shadow:/etc/shadow:ro \
    -v /home/$(id -un):/home/$(id -un) \
    -e USER \
    -w /home/$(id -un)/ \
    -it devcontainer:latest /bin/bash