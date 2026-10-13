#!/bin/bash
# Builds dist/GhosttyKit.xcframework.zip — libghostty from a tagged Ghostty
# release, Release-optimized, macOS only (arm64 + x86_64) — and prints the
# checksum Package.swift needs.
#
# Requires:
#   brew install zig@0.15
#     Ghostty 1.3.x's minimum_zig_version is 0.15.2, and Homebrew's build is
#     patched to link against the macOS 26 SDK; the ziglang.org tarball is not.
#   xcodebuild -downloadComponent MetalToolchain
#     Ghostty compiles its Metal shaders at build time. An Xcode update drops
#     this component, so re-run it after every one.
#
# Usage: ./build.sh 1.3.1
set -euo pipefail

VERSION="${1:?usage: ./build.sh <ghostty version, e.g. 1.3.1>}"
ZIG=/opt/homebrew/opt/zig@0.15/bin/zig
REPO="$(cd "$(dirname "$0")" && pwd)"
OUT="$REPO/dist"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

git clone --quiet --depth 1 --branch "v$VERSION" \
  https://github.com/ghostty-org/ghostty.git "$WORK/ghostty"
cd "$WORK/ghostty"
echo "ghostty $(git rev-parse HEAD)"

# Upstream fixes from after the tag, each a verbatim `git format-patch` of a
# ghostty-org/ghostty commit — see patches/README.md for why each is here.
for patch in "$REPO/patches"/*.patch; do
  git apply "$patch"
  echo "applied $(basename "$patch")"
done

# ReleaseFast is the whole point of this repo: with no -Doptimize, zig build
# defaults to Debug, which renders noticeably slower and is several times the
# size. app-runtime=none and emit-macos-app=false build the embeddable library
# alone, without Ghostty's own app around it.
"$ZIG" build \
  -Doptimize=ReleaseFast \
  -Dapp-runtime=none \
  -Demit-xcframework=true \
  -Demit-macos-app=false

# Ghostty's xcframework also carries iOS and iOS Simulator slices. Only the
# macOS one is repackaged, which keeps every consumer's download to the part
# it can link.
rm -rf "$OUT" && mkdir -p "$OUT"
xcodebuild -create-xcframework \
  -library macos/GhosttyKit.xcframework/macos-arm64_x86_64/libghostty.a \
  -headers include \
  -output "$OUT/GhosttyKit.xcframework"

# Fail here, not at a consumer's link step, if the embedding API went missing —
# stripped, or dropped by libtool (see patches/README.md). Checked per
# architecture, since either slice can lose it on its own. No `grep -q`: it
# exits at the first match, and under pipefail nm's resulting SIGPIPE fails
# the check even though the symbol is there.
for arch in arm64 x86_64; do
  nm -gU -arch "$arch" "$OUT/GhosttyKit.xcframework/macos-arm64_x86_64/libghostty.a" 2>/dev/null \
    | grep ' _ghostty_surface_new$' >/dev/null \
    || { echo "libghostty.a ($arch) is missing the embedding API" >&2; exit 1; }
done

cd "$OUT"
# --norsrc: no AppleDouble `._` entries, which unzip as stray files that
# break code signing in whatever app embeds the result.
ditto -c -k --norsrc --keepParent GhosttyKit.xcframework GhosttyKit.xcframework.zip
echo "checksum $(shasum -a 256 GhosttyKit.xcframework.zip | cut -d' ' -f1)"
