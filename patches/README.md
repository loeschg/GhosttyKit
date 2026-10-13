# Patches

Upstream Ghostty commits, applied by `build.sh` on top of the tagged release.
Each file is `git format-patch` output of the commit, unmodified.

## 0001-normalize-archives-before-libtool.patch

ghostty-org/ghostty@a83a82b3f8 (2026-03-30, after 1.3.1).

Xcode 27's `libtool` silently drops archive members that Zig's archiver did
not align to 8 bytes, while merging libghostty with its dependencies. Without
this commit, building 1.3.1 with Xcode 27 produces a `libghostty.a` with none
of the embedding API in it — just a handful of SIMD helpers — and every
consumer fails at link time. The fix runs `ranlib` over each input archive
first, which rewrites it in a layout `libtool` accepts.

Drop it once the pinned Ghostty release includes the commit.
