# iOS Build Pipeline

Chrono Exponent is developed on Windows/GitHub and exported for iOS on a GitHub-hosted macOS runner.

## Current stage

The repository currently supports **project-only iOS export**:

```text
Godot project
   ↓
GitHub Actions / macOS
   ↓
Godot iOS exporter
   ↓
Xcode project
   ↓
GitHub Artifact
```

This stage intentionally does **not** create a signed IPA yet.

The goal is to prove that the Godot project can be exported cleanly to Apple's Xcode project format before adding certificates and provisioning profiles.

## Required repository secret

Create this GitHub Actions secret:

```text
IOS_TEAM_ID
```

Value: the 10-character Apple Developer Team ID associated with the Apple account used for signing.

The workflow refuses to run without it.

## Provisional bundle identifier

Current development bundle identifier:

```text
com.neyjealous.chronoexponent
```

This is provisional. Before signed device distribution, it must match the App ID / provisioning setup used in the Apple Developer account.

## Run the export

GitHub:

```text
Actions
→ iOS Xcode Export
→ Run workflow
```

The workflow:

1. checks out the project;
2. downloads Godot 4.7.2 for macOS;
3. installs the matching iOS export templates;
4. injects `IOS_TEAM_ID` into a temporary `export_presets.cfg`;
5. imports the project;
6. exports an Xcode project;
7. verifies an `.xcodeproj` exists;
8. uploads the result as `ChronoExponent-iOS-Xcode`.

The generated `export_presets.cfg` is not committed because it may contain machine/account-specific export configuration.

## Next stage — signed IPA

After project-only export is confirmed, the pipeline will be extended with:

- Apple Distribution / Development certificate import into a temporary keychain;
- provisioning profile installation;
- Xcode archive;
- `xcodebuild -exportArchive`;
- signed `.ipa` artifact;
- optional TestFlight upload later.

The signing material must be stored only in GitHub Actions secrets and must never be committed to the repository.

## Development rule

Do not mix gameplay work with signing failures.

The pipeline is intentionally staged:

```text
1. Godot validates
2. Godot exports Xcode project
3. Xcode builds
4. signing works
5. IPA installs on real iPhone
```

Each stage must pass before the next one is treated as stable.
