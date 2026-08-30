# Release checklist

This checklist prepares both packages without coupling their publication.
Publishing either package, creating a Git tag, pushing commits, and creating a
GitHub release are deliberate manual actions.

## Prepare

1. Confirm the GitHub repository is public and its default branch is `main`.
2. Confirm `pubspec.yaml`, `package.json`, and `package-lock.json` use the same
   release version.
3. Move release notes from `Unreleased` to a dated changelog section.
4. Run `npm run generate` and confirm only expected generated data changes.
5. Run the complete verification suite:

   ```sh
   dart format --output=none --set-exit-if-changed .
   flutter analyze
   flutter test
   flutter test tool/world_hex_map_preview_test.dart
   dart doc
   npm ci
   npm run check
   dart pub publish --dry-run
   npm publish --dry-run
   ```

6. Review the pub.dev and npm file lists from the dry-runs.
7. Commit the release preparation and wait for both CI jobs to pass.

## Publish manually

When the release is approved, publish `world_hex_map` to pub.dev and
`world-hex-map` to npm, create the matching `vX.Y.Z` Git tag, and create the
GitHub release from the changelog notes. Verify both registry installation
commands from a clean temporary project afterward.
