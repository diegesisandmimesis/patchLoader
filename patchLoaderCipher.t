#charset "us-ascii"
//
// patchLoaderCipher.t
//
#include <tadsgen.h>
#include <dynfunc.h>

#include "patchLoader.h"

#ifdef PATCH_LOADER_USE_CIPHER

modify patchLoader
	decode(buf) {
		buf = inherited(buf);
		return(buf);
	}
;

#endif // PATCH_LOADER_USE_CIPHER
