#charset "us-ascii"
//
// patchLoaderGenerate.t
//
//
#include <tadsgen.h>
#include <dynfunc.h>

#include "patchLoader.h"

#ifdef PATCH_LOADER_GENERATE

modify patchLoader
	generatePatch(fname) {
		local buf;

		buf = _fileToString(fname);
		if(buf == nil) {
			_debug('Failed to load raw patch file <q>'
				+ toString(fname) + '</q>. ');
			return(nil);
		}

		return(buf);
	}
;

#ifdef PATCH_LOADER_USE_BASE64
modify patchLoader
	generatePatch(fname) {
		return(encode(inherited(fname)));
	}

	// Moderately kludgy TADS3 implementation of Base64 encoding.
	encode(buf) {
		local c0, c1, c2, e0, e1, e2, e3, i, l, r;

		r = '';
		i = 1;
		l = buf.length();
		while(i <= l) {
			c0 = buf.toUnicode(i);
			c1 = buf.toUnicode(i + 1);
			c2 = buf.toUnicode(i + 2);

			if(c1 == nil) c1 = 0;
			if(c2 == nil) c2 = 0;

			i += 3;

			e0 = c0 >> 2;
			e1 = ((c0 & 3) << 4) | ((c1 & 0xf0) >> 4);
			e2 = ((c1 & 15) << 2) | ((c2 & 0xc0) >> 6);
			e3 = c2 & 63;
			if(c1 == 0)
				e2 = e3 = 64;
			if(c2 == 0)
				e3 = 64;
				

			r += _base64.substr(e0 + 1, 1)
				+ _base64.substr(e1 + 1, 1)
				+ _base64.substr(e2 + 1, 1)
				+ _base64.substr(e3 + 1, 1);
		}

		return(r);
	}
;
#endif // PATCH_LOADER_USE_BASE64

#ifdef PATCH_LOADER_VERIFY
modify patchLoader
	encode(buf) {
		return(inherited(addSignature(buf)));
	}

	addSignature(buf) {
		local tmp;

		tmp = PATCH_LOADER_PASSPHRASE + buf;
		sig = tmp.sha256().toUpper();

		return('SIGNATURE=\'<<sig>>\'' + buf);
	}
;
#endif // PATCH_LOADER_VERIFY

#endif // PATCH_LOADER_GENERATE
