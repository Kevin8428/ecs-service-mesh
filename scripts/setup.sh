#!/bin/bash
EC2_KEY_NAME=$1
EC2_KEY_NAME=${EC2_KEY_NAME:-dev-20240929}

if ! [ -x "$(command -v terraform)" ]; then
  echo 'Error: terraform must be installed.' >&2
  exit 1
fi

DESTINATION=main.tf
cp main.tf.tpl main.tf
sed -i "" "s/__EC2_KEY_NAME__/\"$EC2_KEY_NAME\"/g" main.tf
