
patchLoader
Version 1.0
Copyright 2022 Diegesis & Mimesis, distributed under the MIT License



ABOUT THIS LIBRARY

A runtime patch loader for TADS3.

This is indended to allow authors to patch games post-release without
invalidating players' existing savegames.


BASIC USAGE

A game compiled with this module will, at startup:

	-Check for an optional patch bootloader in the file defined
		in patchLoader.patchBootstrapFile.  This is entirely optional,
		and you only need to fiddle with this if you need to change
		the way patches are applied.

		An example standalone patch bootloader can be found in
		script/patchBootstrap.t

	-Check for a patch in the file defined in patchLoader.patchFile.
		If this file doesn't exist, the patch process will be silently
		skipped.

	-Optionally verify the signature on the patch file, if the game was
		compiled with the PATCH_LOADER_VERIFY flag.  If verification
		is enabled, the patch process will abort if signature
		verification fails, logging an error in the process.

	-Apply the patch.  This does whatever you've set up the patch to do.


A SIMPLE PATCH

In its simplest form, a patch file is just a bunch of changes to the
game state wrapped in a function.  For example:

	function() {
		versionInfo.revision = '5.0';
	}

...if, for some reason, you wanted a patch that does nothing but change
the revision number.


RESTRICTIONS ON PATCH CODE

Because of limitations in TADS3, you CANNOT USE:

	-String expressions in if(), for(), while(), or "?:" statements
	-Switch statements

Attempting to use the above will produce unpredictable results, probably
causing the interpreter to segfault.


COMPILING

Compile-time options include:

	PATCH_LOADER_BASE_USE_BASE64
		If enabled, use Base64 encoded patches.  This is entirely
		for lightweight obfuscation of the patch source, so looking
		at the patchfile won't accidentally give spoilers.

	PATCH_LOADER_VERIFY
		If enabled, the patch loader will require that the patch file
		has a signature, and that the signature is valid.

		The signature is the SHA256 hash of the passphrase (below)
		and the patch source concatenated together (with no whitespace).

	PATCH_LOADER_PASSPHRASE
		The passphrase to use for verification.  It is a single-quoted
		string, so it can't contain a single quote.  If you want to use
		"foozle" as a passphrase, you can add it to the header file via:

			#define PATCH_LOADER_PASSPHRASE 'foozle'

		...or add by adding this to your compile command line:

			-D PATCH_LOADER_PASSPHRASE='foozle'

		Note that this is NOT A SECURITY FEATURE.  It's mostly useful
		for insuring a game doesn't accidentally apply a patch intended
		for a different game, and for insuring a random source file
		doesn't accidentally get applied as a patch.  This does nothing
		to ensure that validity of the patch, or prevent tampering
		with the patch file or the game itself.

Projects compiling in support for this module must also add
dynfunct.t via something like:

	-source dynfunc.t

...in the makefile or compile command.


GENERATING A PATCH FILE

If you're not using Base64 encoding or verification, the patch file
doesn't need any special formatting.

If you're using Base64 encoding but NOT verification, then you can
use any Base64 encoder to encode the patch file.  E.g., on most linux
distributions you can just do something like:

	# cat patchSource.t | base64 > patch.t

If you're using Base64 and verification, you can use a couple tools to
generate the patch file.

First, there's ./scripts/patchgen.sh.  Sample usage:

	# sh patchgen.sh patchSource.t foozle > patch.t

...will sign and encode the code in patchSource.t using the
passphrase "foozle" and writes the result to patch.t

Second, you can compile and use the "game" in ./demo/src/patchGen.t to
do the same thing.  There's a sample makefile in ./demo/patchgen.t3m.  You
should be able to compile it from the ./demo directory using something
like:

	# t3make -f patchGen.t3m

...to produce ./demo/games/patchGen.t3.  You can then copy your
patch source to ./demo/games/patchSource.t, and then run the game with
most interpreters.  It should read the patch source and print the
signed and encoded patch blob, which you can then cut and paste into
a file.  This is obviously more of a pain that just using the bash
script, but it should be fairly portable.


CREDITS

This module is based on sample code posted in this thread:

https://intfiction.org/t/changing-verb-grammar-at-runtime/11880




LIBRARY CONTENTS

	patchBootstrap.t
		Example patch bootstrap loader.

	patchBootstrap64.t
		The example patch bootstrap loader file, base64 encoded.

	patchgen.sh
		A simple bash script to generate a signed patch file.

	patchLoaderBase64.t
		Source for optional decoder for base64-encoded patch files.

	patchLoaderDebug.t
		Debugging code for the patch loader.

	patchLoaderGenerate.t
		Code for generating signed and encoded patch files.

	patchLoader.h
		Header file, containing all the #defines for the library.

		You can enable and disable features by commenting or
		uncommenting the #define statements.  Each #define is prefaced
		by comments explaining what it does.

	patchLoader.t
		Contains the module ID for the library.

	patchLoader.tl
		The library file for the library.

	patchLoaderVerify.t
		Rudimentary code signing checks for the patch file.


	doc/README.txt
		This file

	scripts/patchBootstrap.t
		An example patch bootloader file.

	scripts/patchgen.sh
		A bash script for signing and encoding a patch
	
	scripts/patchSource.t
		An example patch file
