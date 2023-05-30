#!/bin/bash

PROJECT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/.."

# Run Ansible
cd "$PROJECT_PATH/ansible"
ansible-galaxy install -r requirements.yml
ansible-playbook -i inventory-$1.yml --extra-vars "firebase_credentials=$FIREBASE_CREDENTIALS_PATH" --user=$(whoami) --private-key=$ANS_PRIVATE_KEY_PATH playbook.yml
