# GhosttyKit

[libghostty](https://github.com/ghostty-org/ghostty) — the terminal core of
Ghostty — as a prebuilt, **Release-optimized** XCFramework for macOS
(arm64 + x86_64), distributed as a Swift Package binary target.

Personal software, published in case it's useful. The point of the package is
the optimization flag: `zig build` defaults to Debug, which renders noticeably
slower and is several times the size.

> [!WARNING]
> **Maintenance is not guaranteed.** New Ghostty releases may be packaged
> late, skipped, or not at all, and this repository may stop being updated
> without notice. There is no support. If you depend on it, pin an exact
> version — or better, run [`build.sh`](build.sh) yourself and host your own
> copy.

## Use

```swift
.package(url: "https://github.com/loeschg/GhosttyKit", exact: "1.3.1")
```

Then `import GhosttyKit` and call the C API in `ghostty.h`. Pin exactly:
libghostty's embedding API is not stable, and Ghostty changes it between
releases. Ghostty's own macOS app
([`macos/Sources/Ghostty`](https://github.com/ghostty-org/ghostty/tree/main/macos/Sources/Ghostty))
is the reference for using it.

Terminfo and shell integration are not included. Point
`GHOSTTY_RESOURCES_DIR` at an installed Ghostty.app's
`Contents/Resources/ghostty` before calling `ghostty_init`, or `TERM` falls
back to `xterm-256color`.

## Versions

Each tag matches the Ghostty release it was built from.

| Tag     | Ghostty commit                             | Patches                | Zig    | Xcode |
| ------- | ------------------------------------------ | ---------------------- | ------ | ----- |
| `1.3.1` | `332b2aefc6e72d363aa93ab6ecfc86eeeeb5ed28` | ghostty-org/ghostty@a83a82b3f8 | 0.15.2 | 27.0  |

## Building

[`build.sh`](build.sh) is the whole process: it clones the tagged Ghostty
release, applies the upstream fixes in [`patches/`](patches) — currently one,
needed to build with Xcode 27 at all — builds with `-Doptimize=ReleaseFast`,
keeps only the macOS slice, checks the embedding API made it into both
architectures, zips it, and prints the checksum that goes into
`Package.swift`.

```sh
brew install zig@0.15
xcodebuild -downloadComponent MetalToolchain
./build.sh 1.3.1
```

To release a new version: run the script, upload
`dist/GhosttyKit.xcframework.zip` to a GitHub release tagged with the Ghostty
version, update the URL and checksum in `Package.swift`, and tag that commit.

## License

Ghostty is MIT-licensed; see [LICENSE](LICENSE). This repository adds only the
packaging.
