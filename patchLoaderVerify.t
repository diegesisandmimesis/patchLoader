#charset "us-ascii"
//
// patchLoaderVerify.t
//
#include <tadsgen.h>
#include <dynfunc.h>

#include "patchLoader.h"

#ifdef PATCH_LOADER_VERIFY

class PatchException: FileException
	displayException() { "verification failed"; }
;

modify patchLoader
	_sig = nil

	// Extension to the decode() method to read and remove the
	// signature from the loaded patch/bootloader.
	decode(buf, prop?) {
		buf = inherited(buf);

		if(prop == nil)
			prop = &sig;

		buf = rexReplace('SIGNATURE=\'(<alphanum>+)\'\n*', buf, '');
		if(rexGroup(1) != nil)
			self.(prop) = rexGroup(1)[3].toUpper();
		else
			self.(prop) = nil;

		_debug('Signature: <<toString(self.(prop))>>');

		return(buf);
	}

	_verifySignature(buf, prop?) {
		local sig, tmp;

		if(prop == nil)
			prop = &sig;

		tmp = PATCH_LOADER_PASSPHRASE + buf;
		sig = tmp.sha256().toUpper();

		_debug('Computed signature: <<toString(sig)>>');
		return(sig == self.(prop));
	}

	verifyPatchBootstrap(buf) {
		if(!_verifySignature(buf, &bootstrapSig)) {
			_error('Invalid bootstrap signature');
			return(nil);
		}

		_debug('Bootstrap signature valid. ');
		return(true);
	}

	verifyPatch(buf) {
		if(!_verifySignature(buf, &patchSig)) {
			_error('Invalid patch signature');
			return(nil);
		}

		_debug('Patch signature valid. ');
		return(true);
	}
;

#endif // PATCH_LOADER_VERIFY
