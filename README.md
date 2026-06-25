# Bevy Mobile Starter

A starter project for building mobile apps with [Bevy 0.19](https://bevyengine.org/), using the new `bsn!` macro for UI.

Think Flutter or React Native, but with Rust and Bevy's ECS. This isn't a game template — it's an app template. The window behaves like a normal mobile app (not fullscreen), the render loop respects your battery, and the binary is kept small.

## What you get

- **Bevy 0.19 with `bsn!`** — all UI defined declaratively, no manual entity spawning
- **Android & iOS** — native wrappers (Kotlin/Gradle for Android, Swift/Xcode for iOS)
- **Counter demo** — a floating action button that increments a counter, just enough to show how state, events, and UI updates wire together
- **Makefile** — one command per platform, no remembering CLI flags

## Quick start

### Desktop

```bash
make desktop-run
```

Opens a 390×844 window. Click the "+" button.

### Android

You need the Android SDK, NDK, JDK 17+, and a Rust Android target:

```bash
rustup target add aarch64-linux-android
cargo install cargo-ndk
```

Then plug in your phone and run:

```bash
make android-run          # debug build
make android-run-release  # release build (smaller APK)
```

### iOS

You need Xcode and the iOS Rust target:

```bash
rustup target add aarch64-apple-ios
make ios-build            # builds the static library
```

Then open `ios/App.xcodeproj` in Xcode and hit Run.

## Makefile reference

```
Desktop:
  make desktop-run              Build & run (debug)
  make desktop-run-release      Build & run (release)
  make desktop-check            Cargo check

Android:
  make android-build-rust       Rebuild only the .so (fast)
  make android-build            Build APK (debug)
  make android-build-release    Build APK (release, signed)
  make android-run              Build + install + launch (debug)
  make android-run-release      Build + install + launch (release)
  make android-check            Cargo check for aarch64-linux-android

iOS:
  make ios-build                Build .a (release)
  make ios-ipa                  Build .ipa via Xcode
  make ios-check                Cargo check for aarch64-apple-ios

General:
  make fmt                      cargo fmt --all
  make clippy                   cargo clippy
  make clean                    Wipe all build artifacts
```

## Project layout

```
src/
  main.rs             Desktop entry point
  lib.rs              Library root + Android/iOS FFI entry points
  app/plugin.rs       App setup (window, plugins, systems)
  ui/scenes.rs        All UI — defined with the bsn! macro
  resources/counter.rs ClickCounter resource
  systems/counter.rs  System that updates the counter text
android/              Android native wrapper (Gradle + NativeActivity)
ios/                  iOS native wrapper (Swift + Xcode project)
```

## Architecture

The app follows a few straightforward rules:

- **Single responsibility** — resources hold state, systems mutate it, scenes define layout. Each module has one job.
- **Dependency inversion** — the app depends on the `Plugin` trait, not concrete implementations. `build_app()` is the only wiring point.
- **All UI in `bsn!`** — the counter text, title, spacer nodes, and FAB button are all `bsn!` macro calls. The button's click observer lives inline in the scene definition.

There's no framework, no widget library, no abstraction layers. Just Bevy's ECS and the `bsn!` macro doing the heavy lifting.

## Keeping it light

- Feature flags: only `ui` and `bevy_scene` are enabled. No 3D renderer, no audio, no animation system.
- Release profile: `opt-level = "s"`, `lto = true`, `strip = true`, `panic = "abort"`.
- Battery: `PresentMode::AutoVsync`, change-detection-gated text updates, no continuous rendering when idle.

## License

See [LICENSE-MIT](LICENSE).

If you ship something built on this, a mention or link back is appreciated but not required.

## Contributing

Issues and PRs are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for the ground rules.

