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
	patchFile = 'patchBootstrap.t'

	bootstrapFunc = nil;
	compilePatches = nil;
	applyPatches = nil;

	_base64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

	bootstrap() {
		try {
			local fileHandle, line, patchBuf;

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
            
			patchObj.setMethod(&bootstrapFunc,
				Compiler.compile(toString(patchBuf)));
		}
		catch (Exception e) {
			_debug('Failed to load patch bootstrap:
				<<e.displayException()>>');
		}
	}

	decode(str) {
		local c0, c1, c2, e0, e1, e2, e3, i, r;

		r = '';
		i = 1;
		str = rexReplace('[^A-Za-z0-9\+\/\=]', str, '');
		while(i <= str.length) {
			e0 = _base64.find(str.substr(i, 1)) - 1;
			e1 = _base64.find(str.substr(i + 1, 1)) - 1;
			e2 = _base64.find(str.substr(i + 2, 1)) - 1;
			e3 = _base64.find(str.substr(i + 3, 1)) - 1;

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

#ifdef __DEBUG_PATCH_LOADER
	_debug(str?) {
		"\bpatchLoader:  <<str>>\b ";
	}
#else // __DEBUG_PATCH_LOADER
	_debug(str?) {}
#endif // __DEBUG_PATCH_LOADER
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
