#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

function is_node_module_installed() {
    module_name=${1:-""}
    if [ -n "$module_name" ]; then
        if npm list --parseable | grep "node_modules/$m" > /dev/null; then
            return 0
        fi
    fi

    return 1
}


if [ -f "${OPENSHIFT_REPO_DIR}/.openshift/markers/force_clean_build" ]; then
    echo ".openshift/markers/force_clean_build found!  Recreating npm modules" 1>&2
    rm -rf "${OPENSHIFT_APP_DIR}"/node_modules/*
    mkdir -p "${OPENSHIFT_APP_DIR}"/node_modules
fi

if [ -f "${OPENSHIFT_REPO_DIR}"/deplist.txt ]; then
    for m in $(perl -ne 'print if /^\s*[^#\s]/' "${OPENSHIFT_REPO_DIR}"/deplist.txt); do
        echo "Checking npm module: $m"
        echo
        if is_node_module_installed "$m"; then
            npm update "$m"
        else
            npm install "$m"
        fi
    done
fi

# Run user build
user_build.sh
