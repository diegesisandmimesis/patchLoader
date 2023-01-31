#charset "us-ascii"
//
// patchGen.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// Simple demostration program that looks for a "raw" patch file and
// outputs it as a signed and encoded patch file.
//
// It can be compiled via the included makefile with
//
//	# t3make -f patchGen.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

versionInfo:    GameID
        name = 'patchLoader Code Signing Example'
        byline = 'Diegesis & Mimesis'
        desc = 'Demo game for the patchLoader library. '
        version = '1.0'
        IFID = '12345'
	showAbout() {}
;

// This just prevents the patch loader from attempting to load or apply
// any patches at startup.  Since we're producing patches compatible with
// ourselves, we need to do this to prevent any patches we've previously
// generated from being applied while we're trying to generate a new
// patch.
modify initPatcher
	execute() {}
;

gameMain:       GameMainDef
	newGame() {
		local buf;

		buf = patchLoader.generatePatch('patchSource.t');
		"<.p>Patch (everything between but not including the dashed
			lines:<.p>-----CUT HERE-----\n";
		"<<buf>>";
		"\n-----CUT HERE-----\n";
	}
;
