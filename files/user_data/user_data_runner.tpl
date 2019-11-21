#!/bin/bash

# Update package manager and install extra stuff
echo "Update package manager and install extra stuff"

apt-get update

apt-get install -y curl \
  jq \
  unzip \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common \
  python3-pip

# Install AWS CLI
echo "Install AWS CLI"

pip3 install awscli

# Install, register and configure Gitlab Runner
echo "START: Install, register and configure Gitlab Runner"

curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash

apt-get install gitlab-runner

# Locate old runner and remove if exists
echo "Locate old runner and remove if exists"

OLD_RUNNER_ID=$(curl -s --header "PRIVATE-TOKEN: ${gitlab_api_token}" "${gitlab_url}api/v4/runners?type=group_type&tag_list=${gitlab_group_id},${gitlab_runner_name}" | jq '.[].id')

if [ $OLD_RUNNER_ID != "" ]; then
  OLD_RUNNER_TOKEN=$(curl -s --header "PRIVATE-TOKEN: ${gitlab_api_token}" "${gitlab_url}api/v4/runners/$OLD_RUNNER_ID" | jq '.token')
  curl --request DELETE "${gitlab_url}api/v4/runners" --form "token=$OLD_RUNNER_TOKEN"
fi

# Register new runner
echo "Register new runner"

gitlab-runner register \
  --non-interactive \
  --url ${gitlab_url} \
  --registration-token ${gitlab_runner_reg_token} \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "Docker runner: AWS > ${region}." \
  --tag-list "aws,docker,${gitlab_group_id},${gitlab_runner_name}" \
  --locked="false"

# Copy config file from S3, locate runner token, update config and restart service
echo "Copy config file from S3, locate runner token, update config and restart service"

aws s3 cp s3://${s3_gitlab_runner_bucket}/${gitlab_runner_config_file} /etc/gitlab-runner/

RUNNER_ID=$(curl -s --header "PRIVATE-TOKEN: ${gitlab_api_token}" "${gitlab_url}api/v4/runners?type=group_type&tag_list=${gitlab_group_id},${gitlab_runner_name}" | jq '.[].id')

RUNNER_TOKEN=$(curl -s --header "PRIVATE-TOKEN: ${gitlab_api_token}" "${gitlab_url}api/v4/runners/$RUNNER_ID" | jq '.token')

sed -i -e 's/'"token = <INSERT_TOKEN>"'/'"token = $RUNNER_TOKEN"'/g' /etc/gitlab-runner/config.toml

gitlab-runner restart

# Install Docker CLI
echo "Install Docker CLI"

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
   
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

apt-key fingerprint 0EBFCD88

apt-get update

apt-get install -y docker-ce docker-ce-cli

groupadd docker &> /dev/null

usermod -aG docker ubuntu

# Install docker-machine
echo "Install docker-machine"

base=https://github.com/docker/machine/releases/download/v0.16.0

curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine

mv /tmp/docker-machine /usr/local/bin/docker-machine

chmod +x /usr/local/bin/docker-machine

echo "DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE!"