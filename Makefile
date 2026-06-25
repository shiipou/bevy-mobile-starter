.PHONY: all help \
        desktop-build desktop-build-release desktop-run desktop-run-release desktop-check \
        android-build-rust android-build android-build-release \
        android-install-debug android-install-release \
        android-run android-run-release android-check android-clean \
        ios-build ios-build-release ios-check ios-ipa ios-clean \
        clean fmt clippy check

# ── Config ──────────────────────────────────────────────
APP_NAME        := bevy-mobile-starter
LIB_NAME        := bevy_mobile_starter
ANDROID_PKG     := com.bevy.mobile.starter
ANDROID_ACTIVITY := android.app.NativeActivity
ANDROID_ABI     := arm64-v8a
RUST_TARGET     := aarch64-linux-android
IOS_TARGET      := aarch64-apple-ios
JNILIB_DIR      := android/app/src/main/jniLibs

APK_DEBUG       := android/app/build/outputs/apk/debug/app-debug.apk
APK_RELEASE     := android/app/build/outputs/apk/release/app-release.apk

# ── Toolchain detection ─────────────────────────────────
ANDROID_HOME ?= /opt/homebrew/share/android-sdk
ANDROID_NDK  ?= /opt/homebrew/share/android-ndk
JAVA_HOME    ?= /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home

export ANDROID_HOME
export ANDROID_NDK_HOME := $(ANDROID_NDK)
export JAVA_HOME
export PATH := $(JAVA_HOME)/bin:$(PATH)

# ── Colors ──────────────────────────────────────────────
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
CYAN   := \033[0;36m
RESET  := \033[0m

# ══════════════════════════════════════════════════════════
#  Help
# ══════════════════════════════════════════════════════════
help:
	@echo "$(CYAN)Bevy Mobile Starter — Makefile$(RESET)"
	@echo ""
	@echo "$(GREEN)Desktop$(RESET)"
	@echo "  make desktop-build          Build (debug)"
	@echo "  make desktop-build-release  Build (release, optimized for size)"
	@echo "  make desktop-run            Build & run (debug)"
	@echo "  make desktop-run-release    Build & run (release)"
	@echo "  make desktop-check          Cargo check"
	@echo ""
	@echo "$(GREEN)Android$(RESET)"
	@echo "  make android-build-rust     Build Rust .so only (release)"
	@echo "  make android-build          Build APK (debug)"
	@echo "  make android-build-release  Build APK (release, optimized)"
	@echo "  make android-install-debug   Install debug APK on USB device"
	@echo "  make android-install-release Install release APK on USB device"
	@echo "  make android-run            Build (debug), install & launch"
	@echo "  make android-run-release    Build (release), install & launch"
	@echo "  make android-check          Cargo check for Android target"
	@echo "  make android-clean          Clean Android build artifacts"
	@echo ""
	@echo "$(GREEN)iOS$(RESET)"
	@echo "  make ios-build              Build .a for iOS (release)"
	@echo "  make ios-ipa                Build .ipa via Xcode"
	@echo "  make ios-check              Cargo check for iOS target"
	@echo "  make ios-clean              Clean iOS build artifacts"
	@echo ""
	@echo "$(GREEN)General$(RESET)"
	@echo "  make fmt                    Run cargo fmt"
	@echo "  make clippy                 Run cargo clippy"
	@echo "  make clean                  Clean all build artifacts"
	@echo ""

# ══════════════════════════════════════════════════════════
#  Desktop
# ══════════════════════════════════════════════════════════
desktop-build:
	cargo build

desktop-build-release:
	cargo build --release

desktop-run:
	cargo run

desktop-run-release:
	cargo run --release

desktop-check:
	cargo check

# ══════════════════════════════════════════════════════════
#  Android
# ══════════════════════════════════════════════════════════
_android-prereqs:
	@command -v cargo-ndk >/dev/null 2>&1 || { echo "$(RED)ERROR: cargo-ndk not found. Install with: cargo install cargo-ndk$(RESET)"; exit 1; }
	@command -v adb >/dev/null 2>&1 || { echo "$(RED)ERROR: adb not found. Install Android Platform Tools.$(RESET)"; exit 1; }
	@test -d "$(ANDROID_HOME)" || { echo "$(RED)ERROR: ANDROID_HOME=$(ANDROID_HOME) does not exist. Set ANDROID_HOME to your Android SDK path.$(RESET)"; exit 1; }
	@test -d "$(ANDROID_NDK)" || { echo "$(RED)ERROR: ANDROID_NDK=$(ANDROID_NDK) does not exist. Set ANDROID_NDK to your NDK path.$(RESET)"; exit 1; }
	@test -d "$(JAVA_HOME)" || { echo "$(RED)ERROR: JAVA_HOME=$(JAVA_HOME) does not exist. Install JDK 17+.$(RESET)"; exit 1; }
	@rustup target list --installed | grep -q "$(RUST_TARGET)" || { echo "$(RED)ERROR: Rust target $(RUST_TARGET) not installed. Run: rustup target add $(RUST_TARGET)$(RESET)"; exit 1; }

android-build-rust: _android-prereqs
	@echo "$(CYAN)Building Rust library for Android ($(ANDROID_ABI)) release...$(RESET)"
	cargo ndk -t $(ANDROID_ABI) -o $(JNILIB_DIR) build --release --features android

# Debug APK
android-build: android-build-rust
	@echo "$(CYAN)Building APK with Gradle (debug)...$(RESET)"
	cd android && ./gradlew assembleDebug
	@echo "$(GREEN)APK built: $(APK_DEBUG)$(RESET)"

# Release APK
android-build-release: android-build-rust
	@echo "$(CYAN)Building APK with Gradle (release, optimized)...$(RESET)"
	cd android && ./gradlew assembleRelease
	@echo "$(GREEN)APK built: $(APK_RELEASE)$(RESET)"

# Install debug APK
android-install-debug: _android-prereqs
	@adb devices | grep -q "device$$" || { echo "$(RED)ERROR: No Android device connected via USB.$(RESET)"; exit 1; }
	@test -f "$(APK_DEBUG)" || { echo "$(RED)ERROR: $(APK_DEBUG) not found. Run 'make android-build' first.$(RESET)"; exit 1; }
	@echo "$(CYAN)Installing $(APK_DEBUG)...$(RESET)"
	adb install -r "$(APK_DEBUG)"

# Install release APK
android-install-release: _android-prereqs
	@adb devices | grep -q "device$$" || { echo "$(RED)ERROR: No Android device connected via USB.$(RESET)"; exit 1; }
	@test -f "$(APK_RELEASE)" || { echo "$(RED)ERROR: $(APK_RELEASE) not found. Run 'make android-build-release' first.$(RESET)"; exit 1; }
	@echo "$(CYAN)Installing $(APK_RELEASE)...$(RESET)"
	adb install -r "$(APK_RELEASE)"

android-run: android-build android-install-debug
	@echo "$(CYAN)Launching app on device...$(RESET)"
	adb shell am start -n $(ANDROID_PKG)/$(ANDROID_ACTIVITY)
	@echo "$(GREEN)App launched (debug). Check your phone.$(RESET)"
	@echo "$(YELLOW)Logs: adb logcat -s $(APP_NAME):*$(RESET)"

android-run-release: android-build-release android-install-release
	@echo "$(CYAN)Launching app on device...$(RESET)"
	adb shell am start -n $(ANDROID_PKG)/$(ANDROID_ACTIVITY)
	@echo "$(GREEN)App launched (release). Check your phone.$(RESET)"
	@echo "$(YELLOW)Logs: adb logcat -s $(APP_NAME):*$(RESET)"

android-check: _android-prereqs
	cargo check --target $(RUST_TARGET) --features android

android-clean:
	cd android && ./gradlew clean 2>/dev/null || true
	rm -rf $(JNILIB_DIR)/*

# ══════════════════════════════════════════════════════════
#  iOS
# ══════════════════════════════════════════════════════════
_ios-prereqs:
	@rustup target list --installed | grep -q "$(IOS_TARGET)" || { echo "$(RED)ERROR: Rust target $(IOS_TARGET) not installed. Run: rustup target add $(IOS_TARGET)$(RESET)"; exit 1; }
	@command -v xcodebuild >/dev/null 2>&1 || { echo "$(RED)ERROR: xcodebuild not found. Install Xcode.$(RESET)"; exit 1; }

ios-build: _ios-prereqs
	@echo "$(CYAN)Building Rust library for iOS (release)...$(RESET)"
	cargo build --release --target $(IOS_TARGET)
	@echo "$(GREEN)Static library built: target/$(IOS_TARGET)/release/lib$(LIB_NAME).a$(RESET)"
	@echo "$(YELLOW)Open ios/App.xcodeproj in Xcode to build and run the .ipa$(RESET)"

ios-build-release: ios-build

ios-check: _ios-prereqs
	cargo check --target $(IOS_TARGET)

ios-ipa: ios-build
	@echo "$(CYAN)Building .ipa with Xcode...$(RESET)"
	cd ios && xcodebuild -project App.xcodeproj -scheme App -configuration Release -archivePath build/App.xcarchive archive 2>&1
	cd ios && xcodebuild -exportArchive -archivePath build/App.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath build
	@echo "$(GREEN).ipa built in ios/build/$(RESET)"

ios-clean:
	rm -rf ios/build
	cargo clean --target $(IOS_TARGET)

# ══════════════════════════════════════════════════════════
#  General
# ══════════════════════════════════════════════════════════
fmt:
	cargo fmt --all

clippy:
	cargo clippy -- -D warnings

check: desktop-check

clean:
	cargo clean
	rm -rf android/app/build android/build android/.gradle
	rm -rf ios/build
	rm -rf $(JNILIB_DIR)/*

# Default target
all: help
