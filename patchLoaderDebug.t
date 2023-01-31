#charset "us-ascii"
//
// patchLoaderDebug.t
//
// Debugging stuff.
//
#include <tadsgen.h>
#include <dynfunc.h>

#include "patchLoader.h"

#ifdef __DEBUG_PATCH_LOADER

modify patchLoader
	// Make debugging more chatty.
	_debug(str, e?) {
		"\npatchLoader:  <<str>>\n ";
		if(e) {
			"\t";
			e.displayException();
		}
	}
;

#endif // __DEBUG_PATCH_LOADER
