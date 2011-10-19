#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

redeploy_repo_dir.sh

if [ -z "$BUILD_NUMBER" ]
then
  USED_BUNDLER=false
  if [ -d ${OPENSHIFT_APP_DIR}tmp/.bundle ]
  then
    USED_BUNDLER=true
  fi
  
  if $USED_BUNDLER
  then
    echo 'Restoring previously bundled RubyGems (note: you can commit .openshift/markers/force_clean_build at the root of your repo to force a clean bundle)'
    mv ${OPENSHIFT_APP_DIR}tmp/.bundle ${OPENSHIFT_REPO_DIR}
    if [ -d ${OPENSHIFT_REPO_DIR}vendor ]
    then
      mv ${OPENSHIFT_APP_DIR}/tmp/vendor/bundle ${OPENSHIFT_REPO_DIR}vendor/
    else
      mv ${OPENSHIFT_APP_DIR}tmp/vendor ${OPENSHIFT_REPO_DIR}
    fi
    rm -rf ${OPENSHIFT_APP_DIR}tmp/.bundle ${OPENSHIFT_APP_DIR}tmp/vendor
  fi
  
  # If .bundle isn't currently committed and a Gemfile is then bundle install
  if ! git show master:.bundle > /dev/null 2>&1 && [ -f ${OPENSHIFT_REPO_DIR}Gemfile ] 
  then
    echo "Bundling RubyGems based on Gemfile/Gemfile.lock to deploy/vendor/bundle with 'bundle install --deployment'"
    pushd ${OPENSHIFT_REPO_DIR} > /dev/null
    bundle install --deployment
    echo "Precompiling with 'bundle exec rake assets:precompile'"
    bundle exec rake assets:precompile 2>/dev/null
    popd > /dev/null
  fi
  
fi

user_build.sh