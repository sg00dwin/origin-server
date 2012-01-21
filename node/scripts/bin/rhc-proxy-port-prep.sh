#!/bin/bash

#
# Establish selinux rules which allow application UID's to access specific proxy
# ports on remote machines.
#
UID_BEGIN=500
UID_END=6500

PORT_BEGIN=35531
PORTS_PER_USER=5

source /usr/libexec/li/cartridges/abstract/info/lib/selinux

sfile="/tmp/se-proxy-port"

for uid in `seq ${UID_BEGIN} ${UID_END}`
do
  mcs_level=`openshift_mcs_level $uid`
  pbegin=$(( $(( $(( $uid - $UID_BEGIN )) * $PORTS_PER_USER )) + $PORT_BEGIN  ))
  pend=$(( $pbegin + $PORTS_PER_USER - 1 ))
  echo port -a -t libra_port_t -r $mcs_level -p tcp ${pbegin}-${pend}
done > $sfile
echo semanage -S targeted -i - < $sfile
echo rm -f $sfile
