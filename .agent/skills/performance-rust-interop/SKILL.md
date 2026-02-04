---
name: performance-rust-interop
description: Bridging Dart and Rust for high-performance computing tasks using flutter_rust_bridge.
---

# 🦀 Performance Rust Interop

## 🚀 When to use Rust?
Dart is fast (AOT). but Rust is *system* fast.
- **Use Rust for:**
    - Cryptography / Hashing.
    - Image / Video processing (FFmpeg bindings).
    - Complex algorithms (Physics engines, Signal processing).
    - Large JSON parsing (in background threads).

## 🌉 flutter_rust_bridge (v2)
The standard way to glue them together.
- **Type Safety:** Automatically generates Dart code calling Rust code.
- **Async:** Rust `async fn` maps purely to Dart `Future`.
- **Zero-Copy:** Efficient memory transfer for large binary data.

## ⚠️ Trade-offs
- **Build Time:** Adds Cargo build steps to your Flutter build.
- **Complexity:** Requires Rust toolchain on dev machines and CI.
- **Recommendation:** Only introduce if Dart Isolate benchmarks prove insufficient.
