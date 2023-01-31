#charset "us-ascii"
//
// patchLoaderGenerate.t
//
// Code for generating a patch file.  This is only meaningful if you've
// enabled Base64 encoding and/or signature verification (it'll work if
// you haven't, but the output patch file will just be the input file).
//
// NOTE:  You probably DON'T want to build the game itself with the
// 	PATCH_LOADER_GENERATE flag enabled.  All of the stuff related to
//	patch generation is desiged to be run in a standalone "game" that
//	doesn't do anything other than parse the "raw" patch file and
//	output the encoded and/or signed version.
//
// Doing this via TADS3 is a little clunky, so you can alternately use
// the patchgen.sh script (in the scripts directory) if you're using linux.
//
// If you're not adding signatures and you're JUST Base64 encoding the patch,
// you can just use any random Base64 encoder.  E.g. in most linux
// distributions you could just do:
//
//	# cat patchSource.t | base64 > patch.t
//
// ...and use the result.
//
#include <file.h>
#include <tadsgen.h>
#include <dynfunc.h>

#include "patchLoader.h"

#ifdef PATCH_LOADER_GENERATE

modify patchLoader
	// Read the given input file, returning the contents as a string.
	generatePatch(fname) {
		local buf;

		buf = _fileToString(fname);
		if(buf == nil) {
			_debug('Failed to load raw patch file <q>'
				+ toString(fname) + '</q>.');
			return(nil);
		}

		return(buf);
	}

	// Write patch to a file, with minimal output.
	writePatch(buf, fname) {
		if(_stringToFile(buf, fname) == true)
			"\nWrote patch to file <q><<toString(fname)>></q>.\n ";
		else
			"\nFailed to write to file
				<q><<toString(fname)>></q>.\n ";
	}

	// Write a string to a file, with minimal error handling.
	_stringToFile(buf, fname) {
		local log;

		try {
			log = File.openTextFile(fname, FileAccessWrite,
				'utf8');
			log.writeFile(buf);
			log.closeFile();

			return(true);
		}
		catch(Exception e) {
			_error('<<fname>>: File write failed:', e);
			return(nil);
		}
	}
;

#ifdef PATCH_LOADER_USE_BASE64
modify patchLoader
	// Tweak generatePatch() to Base64 encode the file contents.
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
	// Tweak the encode step to add the signature to the blob to be
	// encoded.
	encode(buf) {
		return(inherited(addSignature(buf)));
	}

	// Compute the signature for the given string, returning
	// the formatted signature concatenated with the input string.
	addSignature(buf) {
		local tmp;

		tmp = PATCH_LOADER_PASSPHRASE + buf;
		sig = tmp.sha256().toUpper();

		return('SIGNATURE=\'<<sig>>\'' + buf);
	}
;
#endif // PATCH_LOADER_VERIFY

#endif // PATCH_LOADER_GENERATE
