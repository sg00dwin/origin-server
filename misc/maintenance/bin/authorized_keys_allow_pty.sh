#!/bin/sh

LIBRA_DIR='/var/lib/libra'

if [ -z "$NOOP" ]
then
  IN_PLACE="-i"
fi

# Find all authorized_keys files in account home directories

ACCT_HOME_LIST=`grep "libra guest" /etc/passwd | cut -d: -f6`

for ACCT_HOME in $ACCT_HOME_LIST
do
   ACCT_NAME=`basename $ACCT_HOME`
   AUTH_KEYS_FILE="$ACCT_HOME/.ssh/authorized_keys"
   # check for existance?

   echo "Allowing PTYs for account $ACCT_NAME"
   perl -p $IN_PLACE -e 's/,no-pty//' $AUTH_KEYS_FILE

   # just in case...
   if [ -z "$NOOP" ]
   then
     restorecon -v $AUTH_KEYS_FILE
   fi
done

# Check
echo Checking for unpatched authorized_keys files
find $LIBRA_DIR -name authorized_keys | xargs grep -l 'no-pty'

