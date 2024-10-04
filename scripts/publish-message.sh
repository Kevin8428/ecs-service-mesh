#!/bin/bash

ACCOUNT_ID=$1
BUS_NAME=$2

if [ -z "$ACCOUNT_ID" ]
then
    echo "ACCOUNT_ID is required"
    exit 1
fi

if [ -z "$BUS_NAME" ]
then
    echo "BUS_NAME is required"
    exit 1
fi

message="one new message here published at - $(date)"
aws sns publish \
    --topic-arn "arn:aws:sns:us-west-2:$ACCOUNT_ID:$BUS_NAME" \
    --message "$message"
