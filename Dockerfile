# base
FROM ubuntu:20.04

# set the github runner version
ARG RUNNER_VERSION="2.275.0"
ARG ARQ_RUNNER="linux-x64"

ENV DEBIAN_FRONTEND=noninteractive


# add a non-sudo user ( docker)
# update the base packages
# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN useradd -m docker \
   && apt-get update -y \
   && apt-get install -y --no-install-recommends curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev git curl \

   && rm -rf /var/lib/apt/lists/*


# cd into the user directory, download and unzip the github actions runner
RUN export RUNNER_VERSION=$(curl  --silent "https://api.github.com/repos/actions/runner/releases/latest" | grep "tag_name" | sed -E 's/.*"v([^"]+)".*/\1/') \
    && cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${ARQ_RUNNER}-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-${ARQ_RUNNER}-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh


# Install docker client.
RUN curl -sSL https://get.docker.com | sh
RUN usermod -aG docker docker

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
