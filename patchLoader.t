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

// Module ID for the library
patchLoaderModuleID: ModuleID {
        name = 'Patch Loader Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

transient patchObj: object {
	bootstrapFunc = nil;
	compilePatches = nil;
	applyPatches = nil;

	patchFile = 'patchBootstrap.t'

	bootstrap() {
		try {
			local fileHandle, line, patchBuf;

			fileHandle = File.openTextFile(patchFile,
				FileAccessRead);
			patchBuf = new StringBuffer(fileHandle.getFileSize());
			line = fileHandle.readFile();
            
			while(line != nil) {
				patchBuf.append(line);
				line = fileHandle.readFile();
			}
			fileHandle.closeFile();
            
			patchObj.setMethod(&bootstrapFunc,
				Compiler.compile(toString(patchBuf)));
		}
		catch (Exception e) {
			"\b[Could not bootstrap patcher: <<e.displayException()>>]\b";
		}
	}
}

// Re-apply all patches after every restore.
postRestorePatcher: PostRestoreObject {
	execute() {
		patchObj.applyPatches();
	}
}

// Apply all patches on every game init.
initPatcher: InitObject {
	execute() {
		patchObj.bootstrap();
		patchObj.bootstrapFunc();
		patchObj.compilePatches();
		patchObj.applyPatches();
	}
}
