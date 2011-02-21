#!/bin/sh
#
# Create a tarball with appropriate version and revision suitable for use as
# a source file for an RPM
#

while getopts g:v:r:R:s:t:n OPT
do
    case "$OPT" in
	g) GITROOT=$OPTARG ;;
	v) VERSION=$OPTARG ;;
	r) REVISION=$OPTARG ;;
	R) RELEASE=$OPTARG ;;
	s) SOURCEDIR=$OPTARG ;;
	t) TMPDIR=$OPTARG ;;
	n) NOOP=echo ;;
    esac
done

if [ -z "$GITROOT" ]
then
    echo "git root (-g) is required" >&2
    exit 1
fi

if [ -z "$VERSION" ]
then
    echo "version (-v) is required" >&2
    exit 1
fi

if [ -z "$REVISION" ]
then
    echo "version (-v) is required" >&2
    exit 1
fi

NAME=li

RELEASE=${RELEASE:=1}

PACKAGENAME=${NAME}-${VERSION}.${REVISION}
TARBALLNAME=${PACKAGENAME}.tar.gz
if [ -n "$SOURCEDIR" ]
then
    TARBALLNAME=${SOURCEDIR}/${TARBALLNAME}
fi

TMPDIR=${TMPDIR:=.}


${NOOP} ln -s ${GITROOT} ${TMPDIR}/${PACKAGENAME}
${NOOP} tar -czh --exclude=.git -f ${TARBALLNAME} -C ${TMPDIR} ${PACKAGENAME}
${NOOP} rm ${TMPDIR}/${PACKAGENAME}
