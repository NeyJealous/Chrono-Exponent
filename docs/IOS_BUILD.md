# iOS Build Pipeline

Chrono Exponent is developed on Windows/GitHub and exported for iOS on a GitHub-hosted macOS runner.

## Current pipeline design

The pipeline is deliberately split into two signing-independent stages:

```text
Godot project
   ↓
GitHub Actions / macOS
   ↓
Godot iOS exporter
   ↓
Xcode project
   ↓
xcodebuild with code signing disabled
   ↓
unsigned .app
   ↓
Payload packaging
   ↓
unsigned .ipa
```

The unsigned IPA is a **build artifact, not a directly installable signed application**.

It can later be re-signed by a supported sideloading workflow or replaced by a properly signed archive once Apple signing credentials are configured.

## Why a Team ID placeholder is used

Godot 4.7 requires both an App Store Team ID and bundle identifier even when `application/export_project_only=true`. The exporter rejects a blank Team ID.

For unsigned CI validation only, the workflow therefore uses:

```text
AAAAAAAAAA
```

when the repository secret `IOS_TEAM_ID` is absent.

That placeholder exists only to let Godot generate the Xcode project. The subsequent Xcode build explicitly uses:

```text
CODE_SIGNING_ALLOWED=NO
CODE_SIGNING_REQUIRED=NO
DEVELOPMENT_TEAM=
```

so the placeholder is not treated as a real signing identity.

If `IOS_TEAM_ID` exists, it must be a 10-character alphanumeric Apple Team ID and is inserted into the generated project instead.

## Bundle identifier

Current development identifier:

```text
com.neyjealous.chronoexponent
```

Before normal Apple-signed device distribution, it must match the App ID/provisioning configuration used by the signing account.

## Automated validation

The workflow is:

```text
.github/workflows/ios-export.yml
```

It runs:

- manually through `workflow_dispatch`;
- automatically on same-repository pull requests that change the iOS workflow, export preset or `project.godot`.

External-fork pull requests do not execute the macOS build job.

The workflow verifies:

1. Xcode and the iPhoneOS SDK are available;
2. Godot 4.7.2 runs on the macOS runner;
3. matching iOS export templates are installed;
4. Godot imports the project without script errors;
5. Godot produces an Xcode project;
6. `xcodebuild -list` can read the project and expose a scheme;
7. Xcode compiles an unsigned Release build for `iphoneos`;
8. an `.app` bundle is created;
9. the bundle is packaged into `ChronoExponent-unsigned.ipa`.

Artifacts:

- `ChronoExponent-unsigned-IPA`
- `ChronoExponent-iOS-Xcode`

## Next stage — installable signed IPA

There are two separate routes.

### Personal sideload route

Use the unsigned IPA as input to a sideloading signer such as SideStore, AltStore or Sideloadly. That tool supplies a valid Apple signature during installation.

This route does not make the GitHub artifact directly installable by itself.

### Native Apple CI signing route

Extend GitHub Actions with:

- Apple Development or Distribution certificate;
- temporary macOS keychain;
- matching provisioning profile;
- real Team ID;
- Xcode archive;
- `xcodebuild -exportArchive`;
- signed IPA;
- optional TestFlight upload later.

Signing material must live only in repository secrets and must never be committed.

## Development rule

Do not mix gameplay correctness with signing correctness.

The gates remain:

```text
1. Linux Godot validation
2. Godot → Xcode export
3. unsigned Xcode iphoneos build
4. unsigned IPA packaging
5. signing
6. install on real iPhone
7. performance / battery / touch validation
```

Each stage must pass before the next stage is treated as stable.
