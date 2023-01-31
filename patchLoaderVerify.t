#charset "us-ascii"
//
// patchLoaderVerify.t
//
// Rudimentary code signing for patch files.
//
// If verification is enabled, we concatenate the passphrase in
// PATCH_LOADER_PASSPHRASE and the "raw" patch source and compute
// the SHA256 hash of the result.
//
// A signed patch file prepends:
//
//	SIGNATURE='the_computed_hash'
//
// ...to the start of the "raw" patch source.
//
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
	// First arg is the patch blob, second is the property to save
	// the signature to.
	decode(buf, prop?) {
		buf = inherited(buf);

		// Fallback to self.sig if no property is specified.
		if(prop == nil)
			prop = &sig;

		// Remove the signature from the patch blob.
		buf = rexReplace('SIGNATURE=\'(<alphanum>+)\'\n*', buf, '');

		// If we got a match above, save the signature to the
		// specified property.
		if(rexGroup(1) != nil)
			self.(prop) = rexGroup(1)[3].toUpper();
		else
			self.(prop) = nil;

		_debug('Signature: <<toString(self.(prop))>>');

		return(buf);
	}

	// Compute the signature for the string passed in the first arg,
	// and then see if it matches the signature saved in the property
	// passed in the second arg.
	_verifySignature(buf, prop?) {
		local sig, tmp;

		// If no property is specified, use self.sig
		if(prop == nil)
			prop = &sig;

		tmp = PATCH_LOADER_PASSPHRASE + buf;
		sig = tmp.sha256().toUpper();

		_debug('Computed signature: <<toString(sig)>>');
		return(sig == self.(prop));
	}

	// Modify the verification methods to actually do verification.
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
