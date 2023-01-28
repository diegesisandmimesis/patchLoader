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

transient patchLoader: object {
	// Name of the bootstrap loader file.
	patchBootstrapFile = 'patchBootstrap.t'

	// Name of the patch file.
	patchFile = 'patch.t'

	bootstrapFunc = nil
	applyPatches = nil

	decode(str) { return(str); }
	cipher(str) { return(str); }

	// Default patch compiler.  Overwritten (at runtime) by
	// patchBootstrap.t, if present in the game directory.
	compilePatches() {
		_debug('Applying patch with builtin patch compiler. ');
		try {
			local fileHandle, line, patchBuf;

			fileHandle = File.openTextFile(patchFile,
				FileAccessRead, 'utf8');

			patchBuf = new StringBuffer(fileHandle.getFileSize());
			line = fileHandle.readFile();

			while(line != nil) {
				patchBuf.append(line);
				line = fileHandle.readFile();
			}
			fileHandle.closeFile();

			patchBuf = decode(toString(patchBuf));

			setMethod(&applyPatches,
				Compiler.compile(patchBuf));
		}
		catch(Exception e) {
			if(e.ofKind(FileNotFoundException))
				_debug('Patch compile failed:', e);
			else
				_error('Patch compile failed:', e);
		}
	}

	bootstrap() {
		try {
			local fileHandle, line, patchBuf;

			fileHandle = File.openTextFile(patchBootstrapFile,
				FileAccessRead);

			patchBuf = new StringBuffer(fileHandle.getFileSize());
			line = fileHandle.readFile();
            
			while(line != nil) {
				patchBuf.append(line);
				line = fileHandle.readFile();
			}
			fileHandle.closeFile();

			patchBuf = decode(toString(patchBuf));
            
			patchLoader.setMethod(&bootstrapFunc,
				Compiler.compile(patchBuf));
		}
		catch (Exception e) {
			if(e.ofKind(FileNotFoundException))
				_debug('Failed to open bootstrap file:', e);
			else
				_error('Failed to open bootstrap file:', e);
		}
	}

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
		patchLoader.applyPatches();
	}
}

// Apply all patches on every game init.
initPatcher: InitObject {
	execute() {
		patchLoader.bootstrap();
		patchLoader.bootstrapFunc();
		patchLoader.compilePatches();
		patchLoader.applyPatches();
	}
}
