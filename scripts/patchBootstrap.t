//
// patchBootstrap.t
//
// This is a sample patch bootloader for use with the
// patchLoader module.
//
// NOTE:  You do not need to use a standalone patch bootloader like this
//	unless you're trying to change how the patch process works.  If
//	you're just patching a game, in most cases all you need is is
//	a patch file.
//
// This bootloader does the same stuff that the builtin bootloader does:
//
//	-Open the patch file (filename defined in patchLoader.patchFile)
//	-Read, decode, and verify the file (decoding and verification
//		including whatever options were included when the game
//		was compiled)
//	-Compile the source found in the file and use it as the
//		patchLoader.applyPatch() method
//
//
function() {
	patchLoader.setMethod(&loadPatch, method() {
		try {
			local fileHandle, line, patchBuf;

			fileHandle = File.openTextFile(patchLoader.patchFile,
				FileAccessRead, 'utf8');

			patchBuf = new StringBuffer(fileHandle.getFileSize());
			line = fileHandle.readFile();

			while(line != nil) {
				patchBuf.append(line);
				line = fileHandle.readFile();
			}
			fileHandle.closeFile();

			patchBuf = patchLoader.decode(toString(patchBuf),
				&patchSig);

			if(!verifyPatch(patchBuf))
				patchVerificationFailed();

			patchLoader.setMethod(&applyPatch,
				Compiler.compile(patchBuf));
		}
		catch(Exception e) {
			if(e.ofKind(FileNotFoundException))
				patchLoader._debug('Patch compile failed:', e);
			else
				patchLoader._error('Patch compile failed:', e);
		}
	});
}
