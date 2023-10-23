#!/bin/bash

exec 3>&1 4>&2

trap 'exec 2>&4 1>&3' 0 1 2 3

exec 1>/tmp/nessus-install-log.out 2>&1



PACKAGE_NAME="nessusagent"

ACTIVATION_CODE="<Your Nessus Activation Key/Code>"

NESSUS_HOST="<fqdn of your Nessus Manager>"

NESSUS_AGENT="/opt/nessus_agent/sbin/nessuscli"

NESSUS_PORT="<port # if different from 8834>"

NESSUS_GROUP="<name of your group>"

base_url="<url to your Storage Account>"

debian_filename="NessusAgent-10.3.1-ubuntu1404_amd64.deb" #

redhat_7_filename="NessusAgent-10.3.1-es7.x86_64.rpm" # Redhat EL7 filename

redhat_8_filename="NessusAgent-10.3.1-es8.x86_64.rpm" # Redhat EL8 filename





if_register_agent() {

  if  "$NESSUS_AGENT" agent status | grep -q "Linked to: $NESSUS_HOST"; then

    echo "Nessus Agent is already linked to Nessus Manager."

  else

    $NESSUS_AGENT agent link --host="$NESSUS_HOST" --port="$NESSUS_PORT" --key="$ACTIVATION_CODE" --groups="$NESSUS_GROUP"

    if [ $? -eq 0 ]; then

        echo "Nessus Agent linked successfully."

        else

          echo "Failed to link Nessus Agent. Check your activation code or permissions."

          exit 1

    fi

  fi

}



is_package_installed_debian() {

  if  dpkg -l | grep -i "ii  $PACKAGE_NAME"; then

    if_register_agent

    return 0

  else

    return 1

  fi

}



is_package_installed_redhat() {

  if  rpm -qa | grep -i "$PACKAGE_NAME" > /dev/null; then

    if_register_agent

    return 0

  else

    return 1

  fi

}



install_package_debian() {

  echo "$PACKAGE_NAME is not installed on $ID. Installing it now..." &&

  sleep 20 &&

   wget -qP /tmp $base_url$debian_filename &&

  sleep 20 &&

   dpkg -i /tmp/"$debian_filename" &&

  sleep 20 &&

   $NESSUS_AGENT agent link --host="$NESSUS_HOST" --port="$NESSUS_PORT" --key="$ACTIVATION_CODE" --groups="$NESSUS_GROUP" &&

  sleep 20 &&

   systemctl enable nessusagent --now &&

  sleep 20 &&

   $NESSUS_AGENT agent status |  tee /tmp/nessus_agent_status &&

   sleep 20 &&

   rm -f /tmp/"$debian_filename"

   exit

}





install_package_redhat_v7() {

  echo "$PACKAGE_NAME is not installed on $ID-$VERSION_ID Installing it now..."

  yum -y install wget &&

  sleep 20 &&

   wget -qP /tmp $base_url$redhat_7_filename &&

  sleep 20 &&

   rpm -ivh /tmp/"$redhat_7_filename" &&

  sleep 20 &&

   $NESSUS_AGENT agent link --host="$NESSUS_HOST" --port="$NESSUS_PORT" --key="$ACTIVATION_CODE" --groups="$NESSUS_GROUP" &&

  sleep 20 &&

   systemctl enable nessusagent --now &&

  sleep 20 &&

   $NESSUS_AGENT agent status |  tee /tmp/nessus_agent_status &&

   rm -f /tmp/"$redhat_7_filename"

   exit

}



install_package_redhat_v8() {

  echo "$PACKAGE_NAME is not installed on $ID-$VERSION_ID. Installing it now..."

  sleep 20 &&

   wget -qP /tmp $base_url$redhat_8_filename &&

  sleep 20 &&

   rpm -ivh /tmp/"$redhat_8_filename" &&

  sleep 20 &&

   $NESSUS_AGENT agent link --host="$NESSUS_HOST" --port="$NESSUS_PORT" --key="$ACTIVATION_CODE" --groups="$NESSUS_GROUP" &&

  sleep 20 &&

   systemctl enable nessusagent --now &&

  sleep 20 &&

   $NESSUS_AGENT agent status |  tee /tmp/nessus_agent_status &&

   rm -f /tmp/"$redhat_8_filename"

   exit

}



check_debian_based() {

  lowercase_id=$(echo "$ID" | tr '[:upper:]' '[:lower:]')

  if [[ "$lowercase_id" == *debian* || "$lowercase_id" == *ubuntu* ]]; then

    if is_package_installed_debian; then

      echo "$PACKAGE_NAME is already installed on $ID."

      exit 0

    else

      install_package_debian

    fi

  fi

}



check_redhat_based() {

  lowercase_id=$(echo "$ID" | tr '[:upper:]' '[:lower:]')

  if [[ "$lowercase_id" == *centos* || "$lowercase_id" == *rhel* || "$lowercase_id" == *ol* || "$lowercase_id" == *el* ]]; then

    if is_package_installed_redhat; then

      echo "$PACKAGE_NAME is already installed on $ID."

      exit 0

    else

      if [[ "$VERSION_ID" == 7 ]]; then

        echo "Red Hat $ID version 7 detected."

        install_package_redhat_v7

      elif [[ "$VERSION_ID" == 8 ]]; then

        echo "Red Hat $ID version 8 detected."

        install_package_redhat_v8

      else

        echo "Unsupported version: $VERSION_ID"

        exit 1

      fi

    fi

  fi

}



if [ -f /etc/os-release ]; then

  . /etc/os-release

  check_debian_based

  check_redhat_based

else

  echo "Unsupported Linux distribution."

  exit 1

fi
