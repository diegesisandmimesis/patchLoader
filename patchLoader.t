#charset "us-ascii"
//
// patchLoader.t
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
	// Name of the bootstrap loader.
	patchFile = 'patchBootstrap.t'

	bootstrapFunc = nil;
	compilePatches = nil;
	applyPatches = nil;

	decode(str) { return(str); }

	bootstrap() {
		try {
			local fileHandle, line, patchBuf;

			// We wrap the file open in a separate try/catch
			// block so we can silently ignore the case where
			// the patch bootloader is absent.
			try {
				fileHandle = File.openTextFile(patchFile,
					FileAccessRead);
			}
			catch(Exception e) {
				_debug('Patch file <q><<patchFile>></q> not
					found. ');
				return;
			}

			patchBuf = new StringBuffer(fileHandle.getFileSize());
			line = fileHandle.readFile();
            
			while(line != nil) {
				patchBuf.append(line);
				line = fileHandle.readFile();
			}
			fileHandle.closeFile();

			//patchBuf = decode(toString(patchBuf));
			patchBuf = toString(patchBuf);
            
			patchLoader.setMethod(&bootstrapFunc,
				Compiler.compile(patchBuf));
		}
		catch (Exception e) {
			_debug('Failed to load patch bootstrap:
				<<e.displayException()>>');
		}
	}

	_debug(str?) {}
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
