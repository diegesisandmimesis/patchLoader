#charset "us-ascii"
//
// patchLoaderDebug.t
//
#include <file.h>
#include <strbuf.h>
#include <tadsgen.h>
#include <dynfunc.h>

#include "patchLoader.h"

#ifdef __DEBUG_PATCH_LOADER

// Make debugging more chatty.
modify patchLoader
	_debug(str, e?) {
		"\npatchLoader:  <<str>>\n ";
		if(e) {
			"\t";
			e.displayException();
		}
	}
;

#endif // __DEBUG_PATCH_LOADER
