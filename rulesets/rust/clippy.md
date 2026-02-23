# Rust Clippy 全局配置

> 所有 Rust 项目共享的 Clippy lint 级别配置。
> 使用方式：复制到项目根目录，或通过 symlink 引用。

## 使用方法

```bash
# 方式 1：复制到项目
cp .github/rulesets/rust/clippy.toml <project>/clippy.toml

# 方式 2：CI 中直接指定
cargo clippy --all-targets --all-features -- -D warnings
```

## 配置说明

以下为推荐的 Clippy lint 组策略，写在各项目 `Cargo.toml` 或 `lib.rs` 中：

```rust
// 在 lib.rs 或 main.rs 顶部
#![warn(clippy::all)]
#![warn(clippy::pedantic)]
#![warn(clippy::nursery)]
#![deny(clippy::unwrap_used)]
#![deny(clippy::expect_used)] // 库代码建议开启
#![allow(clippy::module_name_repetitions)]
#![allow(clippy::must_use_candidate)]
```

## lint 分级

| 级别                  | 策略      | 说明                       |
| --------------------- | --------- | -------------------------- |
| `clippy::all`         | warn      | 基线 lint                  |
| `clippy::pedantic`    | warn      | 更严格的代码风格           |
| `clippy::nursery`     | warn      | 实验性但有价值的 lint      |
| `clippy::unwrap_used` | **deny**  | 禁止裸 unwrap              |
| `clippy::expect_used` | warn/deny | 库代码 deny，应用代码 warn |
| `clippy::cargo`       | warn      | Cargo.toml 规范检查        |
