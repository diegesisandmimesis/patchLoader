#charset "us-ascii"
//
// patchLoaderBase64.t
//
// A simple decode-only Base64 implementation in TADS3.  Support for
// encoding is added in patchLoaderGenerate.t if we're compiled with
// the PATCH_LOADER_GENERATE flag.
//
#include <tadsgen.h>
#include <dynfunc.h>

#include "patchLoader.h"

#ifdef PATCH_LOADER_USE_BASE64

// A very simplistic Base64 implementation.
modify patchLoader
	// base64 character set.
	_base64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='

	// Decode a base64-encoded string.
	decode(buf) {
		local c0, c1, c2, e0, e1, e2, e3, i, r;

		r = '';
		i = 1;
		buf = rexReplace('[^A-Za-z0-9\+\/\=]', buf, '');
		while(i <= buf.length) {
			e0 = _base64.find(buf.substr(i, 1)) - 1;
			e1 = _base64.find(buf.substr(i + 1, 1)) - 1;
			e2 = _base64.find(buf.substr(i + 2, 1)) - 1;
			e3 = _base64.find(buf.substr(i + 3, 1)) - 1;

			i += 4;

			c0 = (e0 << 2) | (e1 >> 4);
			c1 = ((e1 & 15) << 4) | (e2 >> 2);
			c2 = ((e2 & 3) << 6) | e3;

			r = r + makeString(c0);

			if(e2 != 64) {
				r = r + makeString(c1);
			}
			if(e3 != 64) {
				r = r + makeString(c2);
			}
		}
		return(r);
	}
;

#endif // PATCH_LOADER_USE_BASE64
