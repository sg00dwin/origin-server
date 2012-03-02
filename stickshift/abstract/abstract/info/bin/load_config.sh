if [ -f '/etc/stickshift/stickshift-node.conf' ]
then
    . /etc/stickshift/stickshift-node.conf
elif [ -f 'stickshift-node.conf' ]
then
    . stickshift-node.conf
else
    echo "stickshift-node.conf not found.  Cannot continue" 1>&2
    exit 3
fi