//
// patchLoader.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_PATCH_LOADER

// By default, we use base64 encoded patch files.  Comment the following
// line out to disable this.
//#define PATCH_LOADER_USE_BASE64

// "Passphrase" for this game.  This is used for verifying patches are for
// this game (so if there are multiple games in the same directory using
// this module, they all don't try to use each other's patches), so it needs
// to be unique, but it doesn't necessarily have to be a "good" passphrase,
// like if you were using it for a login password or something like that.
//#define PATCH_LOADER_PASSPHRASE 'foozle'

// Enable rudimentary code signing.
// With this enabled, patches will only be applied if they have a valid
// signature.
//#define PATCH_LOADER_VERIFY

#if (defined(PATCH_LOADER_VERIFY) && !defined(PATCH_LOADER_PASSPHRASE))
#error "You have specified PATCH_LOADER_VERIFY without defining"
#error "PATCH_LOADER_PASSPHRASE. "
#error "To define PATCH_LOADER_PASSPHRASE you can either edit the corresponding"
#error "line in patchLoader.h, or you can add -D PATCH_LOADER_PASSPHRASE='foo'"
#error "to the makefile/compile command, where 'foo' is the single-quoted"
#error "string to use as a passphrase for the patch loader."
#endif // PATCH_LOADER_VERIFY && !PATCH_LOADER_PASSPHRASE

//#define patchVerificationFailed() throw new PatchException()
