#!/usr/bin/env bash

set -e

ANSI_YELLOW="\033[33m"
ANSI_RED="\033[31m"
ANSI_RESET="\033[0m"

export VERSION="$1"
if [ -z "$VERSION" ]; then
  echo "USAGE: release.sh <version-hash>"
  exit 1
fi

if [ $VERSION = '-p' ]; then
  VERSION=$(./package.sh | tail -n 1 | tr -d '\n')
fi

#HOST="deploy@datainsight"
HOST="deploy@datainsight.alphagov.co.uk"

scp datainsight-todays-activity-recorder-$VERSION.zip $HOST:/srv/datainsight-todays-activity-recorder/packages
# deploy
echo -e "${ANSI_YELLOW}Deploying package${ANSI_RESET}"
ssh $HOST "mkdir /srv/datainsight-todays-activity-recorder/release/$VERSION; unzip -o /srv/datainsight-todays-activity-recorder/packages/datainsight-todays-activity-recorder-$VERSION.zip -d /srv/datainsight-todays-activity-recorder/release/$VERSION;"
# link
echo -e "${ANSI_YELLOW}Linking package${ANSI_RESET}"
ssh $HOST "rm /srv/datainsight-todays-activity-recorder/current; ln -s /srv/datainsight-todays-activity-recorder/release/$VERSION/ /srv/datainsight-todays-activity-recorder/current;"
# restart
echo -e "${ANSI_YELLOW}Restarting web service${ANSI_RESET}"
ssh $HOST "sudo service datainsight-todays-activity-recorder-web restart"
echo -e "${ANSI_YELLOW}Restarting listener${ANSI_RESET}"
ssh $HOST "sudo service datainsight-todays-activity-recorder-listener restart"
