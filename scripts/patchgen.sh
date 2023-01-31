#!/bin/bash
#
# Bash script that outputs a signed patch file.
#
# Usage is:
#
#	patchgen.sh input_file passphrase
#
# ...where:
#		input_file	raw patch source to sign and encode
#		passphrase	passphrase to use in signing
#
# Output is a Base64 encoded patch blob.
#
# Example:
#
#	# sh patchgen.sh patchSource.t foozle > patch.t
#
# ...will sign and encode the patch from patchSource.t using the passphrase
# "foozle", and output the result to patch.t
#

if [ -z "$1" -o -z "$2" ]; then
	echo "Usage: $0 input_file passphrase"
	exit 1
fi

if [ ! -f "$1" ]; then
	echo "File '$1' not found"
	exit 1
fi


# The passphrase to use.  This needs to match the value you use for
# PATCH_LOADER_PASSPHRASE when compiling the game.
PASSWD=$2

# The signature is the sha256 hash of the passphrase followed by the patch
# source. Note that there is no newline between the two.
SIG=`echo -n "${PASSWD}" | cat - $1 | sha256sum | awk '{print $1}'`

# The patch file itself is the signature followed by the patch source.  A
# newline between the two is allowed, but not required.
echo -n "SIGNATURE='${SIG}'" | cat - $1 | base64

exit 0
