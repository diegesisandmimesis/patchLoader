//
// patchBootstrap.t
//
// Loader for patch file.
function() {
	patchLoader.setMethod(&compilePatches, method() {
		try {
			local fileHandle, line, patchBuf;

			fileHandle = File.openTextFile('patch.t',
				FileAccessRead, 'utf8');

			patchBuf = new StringBuffer(fileHandle.getFileSize());
			line = fileHandle.readFile();

			while(line != nil) {
				patchBuf.append(line);
				line = fileHandle.readFile();
			}
			fileHandle.closeFile();

			patchBuf = patchLoader.decode(toString(patchBuf));

			patchLoader.setMethod(&applyPatches,
				Compiler.compile(patchBuf));
		}
		catch(Exception e) {
			"\b*****ERROR*****
			\nPatch compile failed: <<e.displayException()>>
			\n*****ERROR*****\b ";
		}
	});
}
