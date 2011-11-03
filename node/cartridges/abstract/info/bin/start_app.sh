#!/bin/bash

echo "Starting application..."
    for env_var in  ~/.env/*_CTL_SCRIPT
    do
        . $env_var
    done
    for cmd in `awk 'BEGIN { for (a in ENVIRON) if (a ~ /_CTL_SCRIPT$/) print ENVIRON[a] }'`
    do
        $cmd start
    done
echo "Done"