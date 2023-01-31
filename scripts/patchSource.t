//
// patchSource.t
//
// This is a sample patch file for the "game" in ./demo/src/sample.t.
// It fixes a typo in the pebble's description.
function() {
	// Display some rather unhelpful patch information.
	"<.p>This is the patch, being successfully applied.<.p>";

	// Replace the pebble's desc() method.
	pebble.setMethod(&desc, method() { "It's a small, round pebble. "; });
}
