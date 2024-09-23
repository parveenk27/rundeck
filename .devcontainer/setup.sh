#!/usr/bin/env bash
set -xeuo pipefail

export DEBIAN_FRONTEND="noninteractive"

function main() {
  curl -sfL https://packagecloud.io/install/repositories/pagerduty/rundeck/script.deb.sh?any=true | sudo bash
  sudo apt install -y rundeck-cli openjdk-11-jre-headless
}

main
