#charset "us-ascii"
//
// patchLoader.t
//
// A runtime patch loader for TADS3.
//
// This module is based on sample code posted in this thread:
//
//	https://intfiction.org/t/changing-verb-grammar-at-runtime/11880
//
//
// NOTE: Projects compiling in support for this module must also add
// dynfunct.t via something like:
//
//	-source dynfunc.t
//
// ...in the makefile or compile command.
//
#include <file.h>
#include <strbuf.h>
#include <tadsgen.h>
#include <dynfunc.h>

#include "patchLoader.h"

// Module ID for the library
patchLoaderModuleID: ModuleID {
        name = 'Patch Loader Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

class PatchException: FileException
	displayException() { "verification failed"; }
;

transient patchLoader: object {
	// Name of the bootstrap loader file.
	patchBootstrapFile = 'patchBootstrap.t'

	// Name of the patch file.
	patchFile = 'patch.t'

	bootstrapLoader = nil
	applyPatch = nil

	decode(str) { return(str); }
	cipher(str) { return(str); }

	_fileToString(fname) {
		local buf, fileHandle, line;

		try {
			fileHandle = File.openTextFile(fname, FileAccessRead,
				'utf8');

			buf = new StringBuffer(fileHandle.getFileSize());

			line = fileHandle.readFile();

			while(line != nil) {
				buf.append(line);
				line = fileHandle.readFile();
			}
			fileHandle.closeFile();
		}
		catch(Exception e) {
			if(e.ofKind(FileNotFoundException))
				_debug('<<fname>>: File load failed:', e);
			else
				_error('<<fname>>: File load failed:', e);
		}
		finally {
			if(buf != nil)
				return(toString(buf));
			else
				return(nil);
		}
	}

	loadPatch() {
		local buf;

		_debug('Patching with builtin loadPatch()');

		buf = _fileToString(patchFile);
		if(buf == nil) {
			_debug('No patch to apply');
			return;
		}

		buf = decode(buf);

		if(!verifyPatch(buf))
			patchVerificationFailed();

		setMethod(&applyPatch, Compiler.compile(buf));
	}

	bootstrap() {
		local buf;

		buf = _fileToString(patchBootstrapFile);
		if(buf == nil) {
			_debug('No bootloader to apply');
			return;
		}

		buf = decode(buf);

		if(!verifyBootstrap(buf))
			patchVerificationFailed();

		setMethod(&bootstrapLoader, Compiler.compile(buf));
	}

	verifyBootstrap(buf) { return(true); }
	verifyPatch(buf) { return(true); }

	_debug(str, e?) {}
	_error(str?, e?) {
		"\n*****ERROR APPLYING PATCH*****
		\n<<str>>\n ";
		if(e) {
			"\t";
			e.displayException();
		}
		"\n*****END PATCH ERROR*****\n";
	}
}

// Re-apply all patches after every restore.
postRestorePatcher: PostRestoreObject {
	execute() {
		patchLoader.applyPatch();
	}
}

// Apply all patches on every game init.
initPatcher: InitObject {
	execute() {
		patchLoader.bootstrap();
		patchLoader.bootstrapLoader();
		patchLoader.loadPatch();
		patchLoader.applyPatch();
	}
}
