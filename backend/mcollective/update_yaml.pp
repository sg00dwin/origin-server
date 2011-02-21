# This simply generates a yaml based fact list
# It is run by puppet but outside of its normal config managemtn setup.  This
# is a standalone script
# mmcgrath@redhat.com
# 2011-02-02

file{"/etc/mcollective/facts.yaml":
   owner    => root,
   group    => root,
   mode     => 400,
   loglevel => debug,  # this is needed to avoid it being logged and reported on every run
   # avoid including highly-dynamic facts as they will cause unnecessary template writes
   content  => inline_template("<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime_seconds|timestamp|free)/ }.to_yaml %>")
}

