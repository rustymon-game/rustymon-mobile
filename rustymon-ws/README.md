# rustymon-ws

This is the client side connection for [rustymon-server](https://github.com/rustymon-game/rustymon-server).

## Compilation

As the project is compiled for android, `rustymon-ws` must also be cross compiled.

First, [download](https://github.com/android/ndk/wiki/Unsupported-Downloads) the android ndk `r22b`.

To support newer ndk versions:
- https://github.com/rust-lang/rust/issues/103673#user-content-fn-5-46272fa13fadf811b95d45ca6dfb7b76

Add the linker from the ndk as linkers for android targets:

`~/.cargo/config`

```toml
[target.aarch64-linux-android]
linker = "/path/to/android-ndk-r22b/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android29-clang++"

[target.armv7-linux-androideabi]
linker = "/path/to/android-ndk-r22b/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi29-clang++"

[target.x86_64-linux-android]
linker = "/path/to/android-ndk-r22b/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android29-clang++"

[target.i686-linux-android]
linker = "/path/to/android-ndk-r22b/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android29-clang++"
```

[Install](https://developer.android.com/about/versions/11/setup-sdk) the android-sdk.

To use the targets add them via `rustup`:

```bash
# 64 bit variants
rustup target add x86_64-linux-android aarch64-linux-android

# 32 bit variants
rustup target add armv7-linux-androideabi i686-linux-android
```

Finally, build the target:

```bash
ANDROID_SDK_ROOT=/path/to/android-sdk cargo build -r --target aarch64-linux-android
```
