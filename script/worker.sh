#!/bin/bash

cd /root

verify_output=$(kuzco worker verify)

if [[ "$verify_output" == "Worker is valid!" ]]; then
    echo "Worker is valid, starting worker..."
    kuzco worker start > /root/log/kuzco.log 2>&1
else
    echo "Worker is not valid, logging in..."
    ./script/versioncheck.sh
    kuzco worker start > /root/log/kuzco.log 2>&1
fi