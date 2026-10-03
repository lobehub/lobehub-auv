# lobehub-auv

Builds and releases **LobeHub Computer Use.app**, the LobeHub-branded macOS
helper for [AUV](https://github.com/moeru-ai/auv).

AUV's macOS helper is a small signed Aqua agent that locks and unlocks an
existing console session for the Device API. Upstream ships it as
`AUV Helper.app`. LobeHub Desktop instead ships this build, which has the
LobeHub name, icon, bundle identifier, and Developer ID team.

| | |
| --- | --- |
| App name | `LobeHub Computer Use.app` |
| Bundle identifier | `com.lobehub.lobehub-desktop.computer-use` |
| Installed at | `~/Library/Application Support/com.lobehub.lobehub-desktop.computer-use/` |
| Version | Same as the AUV release it is built from |

## How LobeHub Desktop uses it

1. Desktop packaging downloads `LobeHub-Computer-Use-<auv version>-<arch>.zip`
   from this repository's release matching its `@auv-js/cli` version and
   embeds the unpacked, notarized app in `LobeHub.app`. The app must not be
   re-signed during packaging, which would discard its stapled ticket.
2. At runtime, Desktop sets `AUV_MACOS_HELPER_APP` to the embedded app's
   absolute path for the `auv` daemon and every `auv setup macos-helper` call.
3. `auv setup macos-helper install` reads the bundle identifier and Team ID
   from the app's signature, copies it to the install location above, and
   registers its LaunchAgent. The daemon trusts only that identity.

See AUV's
[helper setup reference](https://github.com/moeru-ai/auv/blob/main/docs/ai/references/session-api/2026-10-01-macos-helper-setup.md#shipped-helper-identity).

## Releasing

Run the **Release helper** workflow with the AUV version (for example
`0.0.25`). It checks out `moeru-ai/auv` at `v<version>`, builds the helper for
arm64 and x64 with AUV's `package.sh`, signs and notarizes it, and publishes
release `v<version>` with one zip and SHA-256 file per architecture.

Required repository secrets, the same as LobeHub Desktop's macOS release:

- `APPLE_CERTIFICATE_BASE64`, `APPLE_CERTIFICATE_PASSWORD`: Developer ID
  Application certificate (`.p12`).
- `APPLE_ID`, `APPLE_APP_SPECIFIC_PASSWORD`, `APPLE_TEAM_ID`: notarization.

## Icon

`icon/app-stable.embedded.svg` is the design export: the LobeHub app icon with
the AUV icon as a circular badge. `scripts/build-icon.sh` recomposes its two
embedded PNG layers at 1024px and builds the `.icns` used by the helper.

The LobeHub layer in that export is only 514px, so large icon sizes are
upscaled. A 1024px export, or separate layers for an Icon Composer `.icon`
document (which AUV's `package.sh` also accepts), would give a sharper,
Liquid Glass–native icon.

```sh
scripts/build-icon.sh build/icon
```
