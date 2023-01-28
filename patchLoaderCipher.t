#charset "us-ascii"
//
// patchLoaderBase64.t
//
#include <file.h>
#include <strbuf.h>
#include <tadsgen.h>
#include <dynfunc.h>

#include "patchLoader.h"

#ifdef PATCH_LOADER_USE_CIPHER

modify patchLoader
	cipher(str) { return(str); }
;

#endif // PATCH_LOADER_USE_CIPHER
