#!/bin/sh
#
# Bash script that outputs a "signed" patch file.
#

# The passphrase to use.  This needs to match the value you use for
# PATCH_LOADER_PASSPHRASE when compiling the game.
PASSWD='foozle'

# The signature is the sha256 hash of the passphrase followed by the patch
# source. Note that there is no newline between the two.
SIG=`echo -n "${PASSWD}" | cat - patch.t | sha256sum | awk '{print $1}'`

# The patch file itself is the signature followed by the patch source.  A
# newline between the two is allowed, but not required.
echo "SIGNATURE='${SIG}'" | cat - patch.t | base64

exit 0
