#!/bin/bash

#
# jrd's tool for building self-signed certs with embedded user id info.
# cf http://www.mozilla.org/projects/security/pki/nss/ref/ssl/gtstd.html
# for testing qpid ssl/auth stuff
#

# boilerplate and arg defaulting
months_valid=3
server_id="localhost.localdomain"
owner_domain_name="localhost.localdomain"
user_id="node"
cert_password="l1br@"
ca_name="OpenShift Dev CA"
ca_pretty_name="OpenShift Dev Root CA"
owner="Red Hat"
state="MA"
dir="test"
verbose=0
pretend=
dc=

#
# NB!!! all this horsing around with debug_pw and sleep is leftover
# from debugging a problem where when you run this thing the normal
# way, you get screwed-up certs, but if you slow it down, it works.
# there's some kind of bug here, but I don't have time to chase it now.
#

debug_pw=
sleep=1

usage()
{
	echo "cert creator doodad"
	echo "  -v increase verbosity"
  echo "  -m <months valid>"
	echo "  -s <server-id>"
	echo "  -u <user id>"
	echo "  -p pretend"
	echo "  -P <cert password>"
	echo "  -d <target dir>"
	echo "  -S <state>"
	echo "  -o <owner short name>"
	echo "  -O <owner domain name>"
	echo "  -c <ca name>"
	echo "  -C <ca pretty name>"
	echo "  -p pretend"

	exit 1;
}

while getopts d:s:m:u:p:P:o:O:c:C:vpwz: option
do case $option in
	v) verbose=`echo $verbose + 1 | bc` ;;
	m) months_valid="$OPTARG" ;;
	d) dc="$OPTARG" ;;
	s) server_id="$OPTARG" ;;
	u) user_id="$OPTARG" ;;
	P) password="$OPTARG" ;;
	d) dir="$OPTARG" ;;
	S) state="$OPTARG" ;;
	o) owner="$OPTARG" ;;
	O) owner_domain_name="$OPTARG" ;;
	c) ca_name="$OPTARG" ;;
	C) ca_pretty_name="$OPTARG" ;;
	p) pretend=yes ;;

	w) debug_pw=yes ;;
	z) sleep="$OPTARG" ;;

	?) usage ;;
    esac
done

x()
{
	if [ $verbose > 0 ] ; then echo ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ; fi
	if [ "X$pretend" != "Xyes" ] ; then ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8} ${9} ${10} ${11} ${12} ${13} ${14} ${15} ${16} ${17} ${18} ${19} ; fi

	err=$?
	if [ $err != 0 ] ; then echo "Error $err" ; exit $err ; fi
}

if [ "x$pretend" != "Xyes" ] ; then mkdir -p $dir ; fi
if [ "X$pretend" != "Xyes" ] ; then echo "$cert_password" > $dir/cert.password ; fi
# if [ "X$pretend" != "Xyes" ] ; then echo "server.$cert_password" > $dir/cert.password.server ; fi
# if [ "X$pretend" != "Xyes" ] ; then echo "client.$cert_password" > $dir/cert.password.client ; fi
if [ "X$pretend" != "Xyes" ] ; then dd if=/dev/random of=$dir/random1 bs=4096 count=1 ; fi
# ./make-certs-helper < $dir/random1 > $dir/random2
# ./make-certs-helper < $dir/random2 > $dir/random3
# ./make-certs-helper < $dir/random3 > $dir/random4
# ./make-certs-helper < $dir/random4 > $dir/random5
# ./make-certs-helper < $dir/random5 > $dir/random6
# ./make-certs-helper < $dir/random6 > $dir/random7
# ./make-certs-helper < $dir/random7 > $dir/random8
# ./make-certs-helper < $dir/random8 > $dir/random9
# ./make-certs-helper < $dir/random9 > $dir/random10
# ./make-certs-helper < $dir/random10 > $dir/random11
# ./make-certs-helper < $dir/random11 > $dir/random12
cat < $dir/random1 > $dir/random2
cat < $dir/random2 > $dir/random3
cat < $dir/random3 > $dir/random4
cat < $dir/random4 > $dir/random5
cat < $dir/random5 > $dir/random6
cat < $dir/random6 > $dir/random7
cat < $dir/random7 > $dir/random8
cat < $dir/random8 > $dir/random9
cat < $dir/random9 > $dir/random10
cat < $dir/random10 > $dir/random11
cat < $dir/random11 > $dir/random12

#
#   1. Create a new certificate database in the CA_db directory.
#      >mkdir CA_db
#      >certutil -N -d CA_db

x mkdir -p $dir/CA_db
if [ "X$debug_pw" == "X" ] ; then
    x certutil -N -d $dir/CA_db -f $dir/cert.password -z $dir/random1
else
    x certutil -N -d $dir/CA_db -z $dir/random1
fi

sleep $sleep

#   2. Create the self-signed Root CA certificate, specifying the
#   subject name for the certificate.
#      >certutil -S -d CA_db -n "MyCo's Root CA" -s "CN=My CA,O=MyCo,ST=California,C=US" -t "CT,," -x -2
#      Enter Password or Pin for "Communicator Certificate DB":

if [ "X$debug_pw" == "X" ] ; then
    x certutil -S -d $dir/CA_db -n "$ca_pretty_name" -s "CN=$ca_name,O=$owner,ST=$state,C=US" -t "CT,," -f $dir/cert.password -z $dir/random2  -x -2 <<EOF
y
0
n
EOF
else
    x certutil -S -d $dir/CA_db -n "$ca_pretty_name" -s "CN=$ca_name,O=$owner,ST=$state,C=US" -t "CT,," -z $dir/random2  -x -2 <<EOF
y
0
n
EOF
fi

sleep $sleep

#   3. Extract the CA certificate from the CA's certificate database
#   to a file.
#      >certutil -L -d CA_db -n "MyCo's Root CA" -a -o CA_db/rootca.crt
#      Enter Password or Pin for "Communicator Certificate DB":

x certutil -L -d $dir/CA_db -n "$ca_pretty_name" -a -o $dir/CA_db/rootca.crt

sleep $sleep

#   4. Display the contents of the CA's certificate databases.
#      >certutil -L -d CA_db

x certutil -L -d $dir/CA_db

sleep $sleep

# The trust flag settings "CTu,u,u" indicate that the certificate is a
# CA certificate that is trusted to issue both client (C) and server
# (T) SSL certificates. The u flag indicates that the private key for
# the CA certificate is present in this set of databases, so the CA
# can issue SSL client and server certificates with these databases.
# Setting Up the Server DB and Certificate
# The sections that follow describe how to set up the Server DB and
# certificate:

#    1. Create a new certificate database in the server_db directory.
#       >mkdir server_db
#       >certutil -N -d server_db

x mkdir -p $dir/server_db
if [ "X$debug_pw" == "X" ] ; then
    x certutil -N -d $dir/server_db  -f $dir/cert.password -z $dir/random3
else
    x certutil -N -d $dir/server_db -z $dir/random3
fi

sleep $sleep

   # 2. Import the new CA certificate into the server's certificate
   # database, and mark it trusted for issuing certificates for SSL
   # client and server authentication.
   #    >certutil -A -d server_db -n "MyCo's Root CA" -t "TC,," -a -i CA_db/rootca.crt

if [ "X$debug_pw" == "X" ] ; then
    x certutil -A -d $dir/server_db -n "$ca_pretty_name" -t "TC,," -a -i $dir/CA_db/rootca.crt -f $dir/cert.password  -z $dir/random4
else
    x certutil -A -d $dir/server_db -n "$ca_pretty_name" -t "TC,," -a -i $dir/CA_db/rootca.crt  -z $dir/random4
fi

sleep $sleep

   # 3. Create the server certificate request, specifying the subject
   # name for the server certificate. We make the common name (CN) be
   # identical to the hostname of the server. Note that this step
   # generates the server's private key, so it must be done in the
   # server's database directory.
   #    >certutil -R -d server_db -s "CN=myco.mcom.org,O=MyCo,ST=California,C=US" -a -o server_db/server.req
   #    Enter Password or Pin for "Communicator Certificate DB":

if [ "X$debug_pw" == "X" ] ; then
    x certutil  -R -d $dir/server_db -s "CN=$owner_domain_name,O=$owner,ST=$state,C=US" -a -o $dir/server_db/server.req  -f $dir/cert.password -z $dir/random5
else
    x certutil  -R -d $dir/server_db -s "CN=$owner_domain_name,O=$owner,ST=$state,C=US" -a -o $dir/server_db/server.req -z $dir/random5
fi

sleep $sleep

   # 4. This step simulates the CA signing and issuing a new server
   # certificate based on the server's certificate request. The new
   # cert is signed with the CA's private key, so this operation uses
   # the CA's databases. This step leaves the server's new certificate
   # in a file.
   #    >certutil -C -d CA_db -c "MyCo's Root CA" -a -i server_db/server.req -o server_db/server.crt -2 -6
   #    Enter Password or Pin for "Communicator Certificate DB":

if [ "X$debug_pw" == "X" ] ; then
    x certutil -C -v $months_valid -d $dir/CA_db -c "$ca_pretty_name" -a -i $dir/server_db/server.req -o $dir/server_db/server.crt -f $dir/cert.password -z $dir/random6  -2 -6 <<EOF
0
9
n
n
-1
EOF
else
    x certutil -C -v $months_valid -d $dir/CA_db -c "$ca_pretty_name" -a -i $dir/server_db/server.req -o $dir/server_db/server.crt -z $dir/random6  -2 -6 <<EOF
0
9
n
n
-1
EOF
fi

sleep $sleep

   # 5. Import (Add) the new server certificate to the server's
   # certificate database in the server_db directory with the
   # appropriate nickname. Notice that no trust is explicitly needed
   # for this certificate.
   #    >certutil -A -d server_db -n myco.mcom.org -a -i server_db/server.crt -t ",,"

if [ "X$debug_pw" == "X" ] ; then
    x certutil -A -d $dir/server_db -n "$owner_domain_name" -a -i $dir/server_db/server.crt -t ",,"  -f $dir/cert.password -z $dir/random7
else
    x certutil -A -d $dir/server_db -n "$owner_domain_name" -a -i $dir/server_db/server.crt -t ",," -z $dir/random7
fi

sleep $sleep

   # 6. Display the contents of the server's certificate databases.
   #    >certutil -L -d server_db

x certutil -L -d $dir/server_db

sleep $sleep

# The trust flag settings "u,u,u" indicate that the server's databases contain the private key for this certificate. This is necessary for the SSL server to be able to do its job.
# Setting Up the Client DB and Certificate
# Setting up the client certificate database involves three stages:

#    1. Create a new certificate database in the client_db directory.
#       >mkdir client_db
#       >certutil -N -d client_db

x mkdir $dir/client_db
if [ "X$debug_pw" == "X" ] ; then
    x certutil -N -d $dir/client_db -f $dir/cert.password -z $dir/random8
else
    x certutil -N -d $dir/client_db -z $dir/random8
fi

sleep $sleep

   # 2. Import the new CA certificate into the client's certificate
   # database, and mark it trusted for issuing certificates for SSL
   # client and server authentication.
   #    >certutil -A -d client_db -n "MyCo's Root CA" -t "TC,," -a -i CA_db/rootca.crt

if [ "X$debug_pw" == "X" ] ; then
    x certutil -A -d $dir/client_db -n "$ca_pretty_name" -t "TC,," -a -i $dir/CA_db/rootca.crt -f $dir/cert.password -z $dir/random9
else
    x certutil -A -d $dir/client_db -n "$ca_pretty_name" -t "TC,," -a -i $dir/CA_db/rootca.crt -z $dir/random9
fi

sleep $sleep

   # 3. Create the client certificate request, specifying the subject name for the certificate.
   #    >certutil -R -d client_db -s "CN=Joe Client,O=MyCo,ST=California,C=US" -a -o client_db/client.req
   #    Enter Password or Pin for "Communicator Certificate DB":

if [ "X$debug_pw" == "X" ] ; then
    x certutil -R -d $dir/client_db -s "CN=$user_id,O=$owner,ST=$state,C=US,$dc" -a -o $dir/client_db/client.req -f $dir/cert.password -z $dir/random10
else
    x certutil -R -d $dir/client_db -s "CN=$user_id,O=$owner,ST=$state,C=US,$dc" -a -o $dir/client_db/client.req -z $dir/random10
fi

sleep $sleep

   # 4. This step simulates the CA signing and issuing a new client certificate based on the client's certificate request. The new cert is signed with the CA's private key, so this operation uses the CA's databases. This step leaves the client's new certificate in a file.
   #    >certutil -C -d CA_db -c "MyCo's Root CA" -a -i client_db/client.req -o client_db/client.crt -2 -6
   #    Enter Password or Pin for "Communicator Certificate DB":

if [ "X$debug_pw" == "X" ] ; then
    x certutil -C -v $months_valid -d $dir/CA_db -c "$ca_pretty_name" -a -i $dir/client_db/client.req -o $dir/client_db/client.crt -f $dir/cert.password -z $dir/random11 -2 -6 <<EOF
1
9
n
n
-1
n
EOF
else
    x certutil -C -v $months_valid -d $dir/CA_db -c "$ca_pretty_name" -a -i $dir/client_db/client.req -o $dir/client_db/client.crt -z $dir/random11 -2 -6 <<EOF
1
9
n
n
-1
n
EOF
fi

   # 5. Add the new client certificate to the client's certificate
   # database in the client_db directory with the appropriate
   # nickname. Notice that no trust is required for this certificate.
   #    >certutil -A -d client_db -n "Joe Client" -a -i client_db/client.crt -t ",,"

if [ "X$debug_pw" == "X" ] ; then
    x certutil -A -d $dir/client_db -n "$user_id" -a -i $dir/client_db/client.crt -t ",,"  -f $dir/cert.password -z $dir/random12
else
    x certutil -A -d $dir/client_db -n "$user_id" -a -i $dir/client_db/client.crt -t ",," -z $dir/random12
fi
   # 6. Display the contents of the client's certificate databases.
   #    >certutil -L -d client_db

x certutil -L -d $dir/client_db


# The trust flag settings "u,u,u" indicate that the client's databases
# contain the private key for this certificate. This is necessary for
# the SSL client to be able to authenticate to the server.  Verifying
# the Server and Client Certificates When you have finished setting up
# the server and client certificate databases, verify that the client
# and server certificates are valid, as follows:

# >certutil -V -d server_db -u V -n myco.mcom.org
# certutil: certificate is valid

x certutil -V -d $dir/server_db -u V -n "$server_id"

# >certutil -V -d client_db -u C -n "Joe Client"
# certutil: certificate is valid

x certutil -V -d $dir/client_db -u C -n "$user_id"
