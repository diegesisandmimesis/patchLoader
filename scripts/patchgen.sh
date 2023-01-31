#!/bin/bash
#
# Bash script that outputs a signed patch file.
#

if [ -z "$1" ]; then
	echo "Usage: $0 input_file"
	exit 1
fi

if [ ! -f "$1" ]; then
	echo "File '$1' not found"
	exit 1
fi

# The passphrase to use.  This needs to match the value you use for
# PATCH_LOADER_PASSPHRASE when compiling the game.
PASSWD='foozle'

# The signature is the sha256 hash of the passphrase followed by the patch
# source. Note that there is no newline between the two.
SIG=`echo -n "${PASSWD}" | cat - $1 | sha256sum | awk '{print $1}'`

# The patch file itself is the signature followed by the patch source.  A
# newline between the two is allowed, but not required.
echo "SIGNATURE='${SIG}'" | cat - $1 | base64

exit 0
