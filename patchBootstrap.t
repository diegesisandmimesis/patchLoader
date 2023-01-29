//
// patchBootstrap.t
//
// Loader for patch file.
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

			patchBuf = patchLoader.decode(toString(patchBuf));

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
