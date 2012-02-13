#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

function is_node_module_installed() {
    module_name=${1:-""}
    if [ -n "$module_name" ]; then
        pushd "$OPENSHIFT_APP_DIR" > /dev/null
        if npm list --parseable 2>&1 | grep "node_modules/$m" > /dev/null; then
            popd
            return 0
        fi
        popd
    fi

    return 1
}


if [ -f "${OPENSHIFT_REPO_DIR}/.openshift/markers/force_clean_build" ]; then
    echo ".openshift/markers/force_clean_build found!  Recreating npm modules" 1>&2
    declare -A npm_global_modules
    for k in `perl -ne 'print if /^\s*[^#\s]/' "${OPENSHIFT_REPO_DIR}"/npm_global_module_list`; do
        npm_global_modules[$k]="$k"
    done

    for m in `ls "${OPENSHIFT_APP_DIR}"/node_modules`; do
        #  Remove all local (or non-globally linked) modules.
        if [ -z "${npm_global_modules[$m]}" ]; then
            rm -rf "${OPENSHIFT_APP_DIR}/node_modules/$m"
        fi
    done
fi

if [ -f "${OPENSHIFT_REPO_DIR}"/deplist.txt ]; then
    for m in $(perl -ne 'print if /^\s*[^#\s]/' "${OPENSHIFT_REPO_DIR}"/deplist.txt); do
        echo "Checking npm module: $m"
        echo
        if is_node_module_installed "$m"; then
            (cd "${OPENSHIFT_APP_DIR}"; npm update "$m")
        else
            (cd "${OPENSHIFT_APP_DIR}"; npm install "$m")
        fi
    done
fi

# Run user build
user_build.sh
