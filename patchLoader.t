#charset "us-ascii"
//
// patchLoader.t
//
// A runtime patch loader for TADS3.
//
// This is indended to allow authors to patch games post-release without
// invalidating players' existing savegames.
//
//
// BASIC USAGE
//
// A game compiled with this module will, at startup:
//
//	-Check for an optional patch bootloader in the file defined
//		in patchLoader.patchBootstrapFile.  This is entirely optional,
//		and you only need to fiddle with this if you need to change
//		the way patches are applied.
//
//		An example standalone patch bootloader can be found in
//		script/patchBootstrap.t
//
//	-Check for a patch in the file defined in patchLoader.patchFile.
//		If this file doesn't exist, the patch process will be silently
//		skipped.
//
//	-Optionally verify the signature on the patch file, if the game was
//		compiled with the PATCH_LOADER_VERIFY flag.  If verification
//		is enabled, the patch process will abort if signature
//		verification fails, logging an error in the process.
//
//	-Apply the patch.  This does whatever you've set up the patch to do.
//
//
// A SIMPLE PATCH
//
// In its simplest form, a patch file is just a bunch of changes to the
// game state wrapped in a function.  For example:
//
//	function() {
//		versionInfo.revision = '5.0';
//	}
//
// ...if, for some reason, you wanted a patch that does nothing but change
// the revision number.
//
//
// RESTRICTIONS ON PATCH CODE
//
// Because of limitations in TADS3, you CANNOT USE:
//
//	-String expressions in if(), for(), while(), or "?:" statements
//	-Switch statements
//
// Attempting to use the above will produce unpredictable results, probably
// causing the interpreter to segfault.
//
//
// COMPILING
//
// Compile-time options include:
//
//	PATCH_LOADER_BASE_USE_BASE64
//		If enabled, use Base64 encoded patches.  This is entirely
//		for lightweight obfuscation of the patch source, so looking
//		at the patchfile won't accidentally give spoilers.
//
//	PATCH_LOADER_VERIFY
//		If enabled, the patch loader will require that the patch file
//		has a signature, and that the signature is valid.
//
//		The signature is the SHA256 hash of the passphrase (below)
//		and the patch source concatenated together (with no whitespace).
//
//	PATCH_LOADER_PASSPHRASE
//		The passphrase to use for verification.  It is a single-quoted
//		string, so it can't contain a single quote.  If you want to use
//		"foozle" as a passphrase, you can add it to the header file via:
//
//			#define PATCH_LOADER_PASSPHRASE 'foozle'
//
//		...or add by adding this to your compile command line:
//
//			-D PATCH_LOADER_PASSPHRASE='foozle'
//
//		Note that this is NOT A SECURITY FEATURE.  It's mostly useful
//		for insuring a game doesn't accidentally apply a patch intended
//		for a different game, and for insuring a random source file
//		doesn't accidentally get applied as a patch.  This does nothing
//		to ensure that validity of the patch, or prevent tampering
//		with the patch file or the game itself.
//
// Projects compiling in support for this module must also add
// dynfunct.t via something like:
//
//	-source dynfunc.t
//
// ...in the makefile or compile command.
//
//
// This module is based on sample code posted in this thread:
//
//	https://intfiction.org/t/changing-verb-grammar-at-runtime/11880
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
	// START OF CONFIGURABLE OPTIONS
	// 
	// Name of the bootstrap loader file.
	patchBootstrapFile = 'patchBootstrap.t'
	//
	// Name of the patch file.
	patchFile = 'patch.t'
	//
	// END OF CONFIGURABLE OPTIONS

	// Method overwritten by the bootstrap loader, if an external
	// one is used.
	bootstrapLoader = nil
	//
	// Method overwritten by the patch, if one is loaded.
	applyPatch = nil

	// Stub method, used if we're not configured to use Base64 encoding.
	decode(buf, prop?) { return(buf); }

	// Load the given file, returning its contents as a string.
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

	// Try to load the patch loader.
	// If successful, the contents of the bootstrap file will be
	// used to overwrite our bootstrapLoader() method.  By default
	// it does nothing, but we can use it to overwrite the default
	// loadPatch() method, changing the way the patch itself is
	// loaded.
	bootstrap() {
		local buf;

		buf = _fileToString(patchBootstrapFile);
		if(buf == nil) {
			_debug('No bootloader to apply');
			return;
		}

		buf = decode(buf, &bootstrapSig);

		if(!verifyBootstrap(buf))
			return;

		setMethod(&bootstrapLoader, Compiler.compile(buf));
	}

	// Builtin patch loader.
	// If a custom bootstrap loader is used, it will (probably)
	// overwrite this method with its own.
	// If you don't need to change how the patch is loaded, you
	// don't need to worry about this.
	loadPatch() {
		local buf;

		_debug('Patching with builtin loadPatch()');

		// Get the contents of the file as a string.
		buf = _fileToString(patchFile);
		if(buf == nil) {
			_debug('No patch to apply');
			return;
		}

		// Decode the string, if necessary.  The second
		// arg is the property in which to store the patch
		// signature, if we've been configured to use signatures.
		buf = decode(buf, &patchSig);

		// Verify the patch, if we've been configured to.
		if(!verifyPatch(buf))
			return;

		// Compile the string and make the results our
		// new applyPatch() method.
		setMethod(&applyPatch, Compiler.compile(buf));
	}

	// Stub verification methods, used if we're not configured to do
	// verification.
	verifyBootstrap(buf) { return(true); }
	verifyPatch(buf) { return(true); }

	// Logging methods.
	//
	// _debug() is overwritten in patchLoaderDebug.t if we've been
	// compiled with the __DEBUG_PATCH_LOADER flag.
	_debug(str, e?) {}
	//
	// Format of the error messages is purely cosmetic, so you can
	// change it if you prefer something else.
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
