#charset "us-ascii"
//
// patchLoaderVerify.t
//
#include <file.h>
#include <strbuf.h>
#include <tadsgen.h>
#include <dynfunc.h>

#include "patchLoader.h"

#ifdef PATCH_LOADER_VERIFY

modify patchLoader
	_sig = nil

	decode(buf) {
		buf = inherited(buf);
		buf = rexReplace('SIGNATURE=\'(<alphanum>+)\'\n*', buf, '');
		if(rexGroup(1) != nil)
			_sig = rexGroup(1)[3].toUpper();
		else
			_sig = nil;

		return(buf);
	}
	verifyPatchBootstrap(buf) {
		return(true);
	}
	verifyPatch(buf) {
		local sig, tmp;

		tmp = PATCH_LOADER_PASSPHRASE + buf;
		sig = tmp.sha256().toUpper();
		if(sig != _sig) {
			_error('Invalid patch signature');
			return(nil);
		}

		_debug('Patch signature valid. ');

		return(true);
	}
;

#endif // PATCH_LOADER_VERIFY
