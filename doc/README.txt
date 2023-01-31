
patchLoader
Version 1.0
Copyright 2022 Diegesis & Mimesis, distributed under the MIT License



ABOUT THIS LIBRARY



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
