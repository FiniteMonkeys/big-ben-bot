# started from https://raw.githubusercontent.com/unwetter-cloud/devcontainer-elixir/main/.devcontainer/Dockerfile

# use -slim or -alpine once we have some stability
FROM elixir:1.17.2-otp-27

LABEL org.opencontainers.image.description="Dev container for FiniteMonkeys/big-ben-bot"
LABEL org.opencontainers.image.source=https://github.com/FiniteMonkeys/big-ben-bot

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
  git procps iproute2 lsb-release ca-certificates sudo \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME

ENV DEBIAN_FRONTEND=dialog

USER vscode
ENV HOME /home/vscode