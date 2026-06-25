# Contributing

Thanks for stopping by. This is a small project and every contribution helps.

## Ground rules

- **Keep it starter-like.** The goal is to be a launchpad, not a framework. If a change adds too many opinions or abstractions, it probably belongs in a fork or a separate crate.
- **No bloat.** Dependencies, binary size, and battery impact matter here. Run `make android-run-release` and check the APK size before and after your change.
- **Write things down.** If you touch the Makefile, update the README. If you add a new feature, explain what it does in a sentence.
- **Run the checks.** Before opening a PR, run `make fmt && make clippy`. The CI does the same and will fail if they don't pass.

## How to contribute

1. Fork the repo.
2. Create a branch off `main`.
3. Make your changes. Keep commits small and focused — each commit should do one thing.
4. Push and open a PR against `main`.

Your PR description should answer three questions: what you changed, why, and how to test it.

## Platform testing

If your change touches Android or iOS paths, the CI will `cargo check` for those targets but can't run the app. If you have a device, a quick smoke test is appreciated:

```bash
make android-run        # verify it launches on your phone
make ios-build          # verify it compiles for iOS
```

No device? That's fine. Just mention it in the PR and someone else can spot-check.

In that case you can just run `make desktop-run`.

## What we're looking for

Some ideas if you want to contribute but aren't sure where to start:

- **Better iOS integration** — the Xcode project is barebones. A smoother build pipeline or SwiftUI host would be great.
- **Android lifecycle fixes** — the current `NativeActivity` approach works but winit doesn't forward `onStop`/`onStart` properly. A `GameActivity`-based setup might be cleaner.
- **CI for APK/IPA artifacts** — the workflow only runs `cargo check`. Building actual APKs and IPAs in CI would catch integration issues.
- **Per-platform window config** — right now the Makefile branches on `cfg!(target_os)`. A plugin-based approach would be cleaner.
- **Examples** — a second screen, navigation, or a settings page that shows how to structure a real app.

If you're fixing a bug, include steps to reproduce. If you're adding a feature, open an issue first to talk it through.

## License

By contributing, you agree that your work will be licensed under MIT or Apache 2.0, at the user's option — same as the project.
